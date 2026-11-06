import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/storage/transactional_store.dart';

abstract interface class WorkspaceSyncGateway {
  Future<void> ensureDevice();
  Future<void> push(String centerId, PendingOperation operation);
  Future<List<Map<String, dynamic>>> pull(String centerId, int after);
}

class SupabaseWorkspaceSyncGateway implements WorkspaceSyncGateway {
  SupabaseWorkspaceSyncGateway(this.client);
  final SupabaseClient client;
  static const requestTimeout = Duration(seconds: 15);
  @override
  Future<void> ensureDevice() async {
    if (client.auth.currentUser == null) {
      await client.auth.signInAnonymously().timeout(requestTimeout);
    }
    if (client.auth.currentUser?.isAnonymous != true) {
      throw StateError('Cloud sync requires the enrolled device session');
    }
  }

  @override
  Future<void> push(String centerId, PendingOperation operation) async {
    await client
        .rpc(
          'push_workspace_operation',
          params: {
            'p_center_id': centerId,
            'p_operation_id': operation.id,
            'p_action': operation.action,
            'p_payload': jsonDecode(operation.payload),
          },
        )
        .timeout(requestTimeout);
  }

  @override
  Future<List<Map<String, dynamic>>> pull(String centerId, int after) async {
    final rows =
        await client
                .rpc(
                  'pull_workspace_operations',
                  params: {'p_center_id': centerId, 'p_after_sequence': after},
                )
                .timeout(requestTimeout)
            as List;
    return rows.map((r) => Map<String, dynamic>.from(r as Map)).toList();
  }
}
