import 'string_store.dart';

/// A local command journal. A queued command is not a cloud acknowledgement.
abstract interface class TransactionalStore implements StringStore {
  Future<List<PendingOperation>> pending();
  Future<int> pendingCount();
  Future<void> acknowledge(String operationId);
  Future<void> commit({
    required String key,
    required String value,
    required String operationId,
    required String action,
    required String payload,
  });
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
