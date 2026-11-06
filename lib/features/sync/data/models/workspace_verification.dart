import '../../../workspace/data/models/workspace_snapshot.dart';
import 'reconciliation.dart';

class WorkspaceVerification {
  const WorkspaceVerification(this.status, {this.remoteCounts = const {}});
  final ReconciliationStatus status;
  final Map<String, int> remoteCounts;
}

Map<String, int> workspaceCounts(WorkspaceSnapshot s) => {
  'cases': s.cases.length,
  'nursing': s.staff.length,
  'procedure': s.procedures.length,
  'transactions': s.movements.length,
  'diagnosticsPayments': s.payments.length,
  'drawerHandoverHistory': s.handovers.length,
  'inventory': s.stockItems.length,
  'stockMovements': s.stockMovements.length,
  'labCatalogue': s.labTests.length,
  'labOrders': s.labOrders.length,
  'labReceipt': s.labPayments.length,
  'audit': s.audit.length,
};
