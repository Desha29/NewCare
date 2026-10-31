import '../../../../core/cubit/action_cubit.dart';
import '../../data/models/lab_order.dart';
import '../../data/models/lab_payment.dart';
import '../../data/models/lab_test.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';

class LaboratoryCubit extends ActionCubit {
  LaboratoryCubit(this.repository);
  final WorkspaceRepository repository;

  Future<bool> saveTest(LabTest test) =>
      execute(() => repository.saveLabTest(test));

  Future<bool> archiveTest(String id) =>
      execute(() => repository.archiveLabTest(id));

  Future<bool> addOrder(LabOrder order, {LabPayment? initialPayment}) =>
      execute(() => repository.addLabOrder(order, initialPayment: initialPayment));

  Future<bool> addPayment(LabPayment payment) =>
      execute(() => repository.addLabPayment(payment));

  Future<bool> setReceived(
    String orderId,
    String staffId, {
    required bool received,
    String? reason,
  }) =>
      execute(() => repository.setLabReceived(
            orderId,
            staffId,
            received: received,
            reason: reason,
          ));
}

