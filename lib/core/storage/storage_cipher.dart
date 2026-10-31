import 'dart:convert';

import 'package:cryptography/cryptography.dart';

/// Authenticated payload encryption; SQLite metadata is not encrypted.
class StorageCipher {
  StorageCipher(List<int> key) : _key = SecretKey(List<int>.of(key)) {
    if (key.length != 32) throw ArgumentError('A 256-bit key is required');
  }

  final SecretKey _key;
  final _algorithm = AesGcm.with256bits();

  Future<String> encrypt(String value, {required String context}) async {
    final box = await _algorithm.encrypt(
      utf8.encode(value),
      secretKey: _key,
      aad: utf8.encode(context),
    );
    return jsonEncode({
      'v': 1,
      'n': base64Encode(box.nonce),
      'c': base64Encode(box.cipherText),
      'm': base64Encode(box.mac.bytes),
    });
  }

  Future<String> decrypt(String envelope, {required String context}) async {
    final data = jsonDecode(envelope) as Map<String, dynamic>;
    if (data['v'] != 1) throw StateError('Unsupported encryption version');
    final clear = await _algorithm.decrypt(
      SecretBox(
        base64Decode(data['c'] as String),
        nonce: base64Decode(data['n'] as String),
        mac: Mac(base64Decode(data['m'] as String)),
      ),
      secretKey: _key,
      aad: utf8.encode(context),
    );
    return utf8.decode(clear);
  }
}
