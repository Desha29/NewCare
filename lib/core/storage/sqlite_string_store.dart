import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:sqlite3/sqlite3.dart';

import 'storage_cipher.dart';
import 'transactional_store.dart';

class StorageDurability {
  const StorageDurability(
    this.journalMode,
    this.synchronous,
    this.sqliteVersion,
  );
  final String journalMode;
  final int synchronous;
  final String sqliteVersion;
  bool get hasRequiredWalFix {
    final parts = sqliteVersion.split('.').map(int.parse).toList();
    if (parts[0] != 3) return parts[0] > 3;
    return parts[1] > 51 || (parts[1] == 51 && parts[2] >= 3);
  }
}

class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.action,
    required this.payload,
    required this.sequence,
  });
  final String id, action, payload;
  final int sequence;
}

/// Owns one native SQLite connection in a worker isolate.
/// Never falls back to an empty database on a read/decryption error.
class SqliteStringStore implements TransactionalStore {
  SqliteStringStore._(this._worker, this._cipher, this.durability);
  final SendPort _worker;
  final StorageCipher _cipher;
  final StorageDurability durability;
  Future<void> _tail = Future.value();
  bool _closed = false;

  static Future<SqliteStringStore> open({
    required String path,
    required StorageCipher cipher,
  }) async {
    await File(path).parent.create(recursive: true);
    final ready = ReceivePort();
    await Isolate.spawn(_serve, (path, ready.sendPort));
    final response = await ready.first as List<Object?>;
    ready.close();
    if (response[0] != 'ready') throw StateError('${response[1]}');
    return SqliteStringStore._(
      response[1] as SendPort,
      cipher,
      StorageDurability(
        response[2] as String,
        response[3] as int,
        response[4] as String,
      ),
    );
  }

  Future<T> _serialized<T>(Future<T> Function() work) {
    if (_closed) return Future.error(StateError('Storage is closed'));
    final result = _tail.then((_) => work());
    _tail = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<Object?> _request(String command, List<Object?> args) async {
    final reply = ReceivePort();
    _worker.send([command, args, reply.sendPort]);
    final response = await reply.first as List<Object?>;
    reply.close();
    if (response[0] != true) throw StateError('${response[1]}');
    return response[1];
  }

  @override
  Future<String?> read(String key) => _serialized(() async {
    final value = await _request('read', [key]) as String?;
    return value == null ? null : _cipher.decrypt(value, context: 'value:$key');
  });

  @override
  Future<void> write(String key, String value) => _serialized(() async {
    final encrypted = await _cipher.encrypt(value, context: 'value:$key');
    await _request('write', [key, encrypted]);
  });

  @override
  Future<void> commit({
    required String key,
    required String value,
    required String operationId,
    required String action,
    required String payload,
  }) => _serialized(() async {
    final encryptedValue = await _cipher.encrypt(value, context: 'value:$key');
    final encryptedPayload = await _cipher.encrypt(
      payload,
      context: 'operation:$operationId:$action',
    );
    await _request('commit', [
      key,
      encryptedValue,
      operationId,
      action,
      encryptedPayload,
    ]);
  });

  Future<List<PendingOperation>> pending() => _serialized(() async {
    final rows = await _request('pending', []) as List;
    final result = <PendingOperation>[];
    for (final row in rows.cast<List>()) {
      result.add(
        PendingOperation(
          sequence: row[0] as int,
          id: row[1] as String,
          action: row[2] as String,
          payload: await _cipher.decrypt(
            row[3] as String,
            context: 'operation:${row[1]}:${row[2]}',
          ),
        ),
      );
    }
    return result;
  });

  @override
  Future<int> pendingCount() =>
      _serialized(() async => await _request('pendingCount', []) as int);

  /// Call only after the server confirms this exact operation ID committed.
  Future<void> acknowledge(String operationId) => _serialized(() async {
    await _request('acknowledge', [operationId]);
  });

  /// Creates a consistent SQLite snapshot, including pending operations.
  /// The destination must be new; a backup never overwrites an older copy.
  /// Keep a separate protected recovery copy of the encryption key.
  Future<void> createBackup(String destination) => _serialized(() async {
    await File(destination).parent.create(recursive: true);
    await _request('backup', [destination]);
  });

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    await _tail;
    await _request('close', []);
  }
}

void _serve((String, SendPort) startup) {
  final (path, ready) = startup;
  Database? db;
  try {
    db = sqlite3.open(path);
    db.execute('PRAGMA journal_mode = WAL');
    db.execute('PRAGMA synchronous = FULL');
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('PRAGMA busy_timeout = 5000');
    final version =
        db.select('SELECT sqlite_version() AS version').single['version']
            as String;
    if (!StorageDurability('wal', 2, version).hasRequiredWalFix) {
      throw StateError('SQLite runtime must include the required WAL fix');
    }
    if (db.userVersion > 1) throw StateError('Database requires a newer app');
    db.execute('BEGIN IMMEDIATE');
    try {
      db.execute(
        'CREATE TABLE IF NOT EXISTS stored_values ('
        'key TEXT PRIMARY KEY, value TEXT NOT NULL)',
      );
      db.execute(
        'CREATE TABLE IF NOT EXISTS pending_operations ('
        'sequence INTEGER PRIMARY KEY AUTOINCREMENT, '
        'id TEXT NOT NULL UNIQUE, action TEXT NOT NULL, payload TEXT NOT NULL)',
      );
      db.userVersion = 1;
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
    final inbox = ReceivePort();
    ready.send([
      'ready',
      inbox.sendPort,
      db.select('PRAGMA journal_mode').single.values.single,
      db.select('PRAGMA synchronous').single.values.single,
      version,
    ]);
    final database = db;
    inbox.listen((message) {
      final request = message as List;
      final command = request[0] as String;
      final args = request[1] as List;
      final reply = request[2] as SendPort;
      try {
        Object? result;
        switch (command) {
          case 'read':
            result = database.select(
              'SELECT value FROM stored_values WHERE key = ?',
              [args[0]],
            ).firstOrNull?['value'];
          case 'write':
            database.execute(
              'INSERT INTO stored_values(key,value) VALUES (?,?) '
              'ON CONFLICT(key) DO UPDATE SET value=excluded.value',
              args,
            );
          case 'commit':
            database.execute('BEGIN IMMEDIATE');
            try {
              database.execute(
                'INSERT INTO stored_values(key,value) VALUES (?,?) '
                'ON CONFLICT(key) DO UPDATE SET value=excluded.value',
                args.take(2).toList(),
              );
              database.execute(
                'INSERT INTO pending_operations(id,action,payload) VALUES (?,?,?)',
                args.skip(2).toList(),
              );
              database.execute('COMMIT');
            } catch (_) {
              database.execute('ROLLBACK');
              rethrow;
            }
          case 'pending':
            result = database
                .select(
                  'SELECT sequence,id,action,payload '
                  'FROM pending_operations ORDER BY sequence',
                )
                .map((r) => r.values.toList())
                .toList();
          case 'pendingCount':
            result = database
                .select('SELECT count(*) AS total FROM pending_operations')
                .single['total'];
          case 'acknowledge':
            database.execute(
              'DELETE FROM pending_operations WHERE id = ?',
              args,
            );
          case 'backup':
            database.execute('VACUUM INTO ?', args);
          case 'close':
            database.close();
            inbox.close();
          default:
            throw StateError('Unknown storage command');
        }
        reply.send([true, result]);
      } catch (_) {
        // Do not include SQL parameters, patient data or key material in errors.
        reply.send([false, 'Local storage operation failed: $command']);
      }
    });
  } catch (_) {
    db?.close();
    ready.send(['error', 'Unable to open the local database']);
  }
}
