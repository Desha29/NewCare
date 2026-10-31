import 'string_store.dart';

/// A local command journal. A queued command is not a cloud acknowledgement.
abstract interface class TransactionalStore implements StringStore {
  Future<int> pendingCount();
  Future<void> commit({
    required String key,
    required String value,
    required String operationId,
    required String action,
    required String payload,
  });
}
