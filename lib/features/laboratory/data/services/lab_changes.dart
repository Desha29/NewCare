import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../../workspace/data/repositories/workspace_repository.dart';
import '../models/lab_order.dart';
import '../models/lab_payment.dart';
import '../models/lab_test.dart';

abstract final class LabChanges {
  static WorkspaceSnapshot saveTest(WorkspaceSnapshot data, LabTest test) {
    if (test.name.trim().isEmpty) {
      throw const WorkspaceException('requiredField');
    }
    if (test.priceMinor < 0) {
      throw const WorkspaceException('invalidAmount');
    }
    final old = data.labTests.where((t) => t.id == test.id).firstOrNull;
    if (old != null && old.version != test.version) {
      throw const WorkspaceException('labTestChanged');
    }
    final normalized = test.name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    final duplicate = data.labTests.where((t) {
      if (t.id == test.id || !t.active) return false;
      return t.name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase() == normalized;
    }).firstOrNull;
    if (duplicate != null) {
      throw const WorkspaceException('duplicateName');
    }
    final updated = old == null
        ? test.copyWith(version: 1)
        : test.copyWith(version: old.version + 1);
    final list = data.labTests.any((t) => t.id == test.id)
        ? data.labTests.map((t) => t.id == test.id ? updated : t).toList()
        : [...data.labTests, updated];
    return data.copyWith(labTests: list);
  }

  static WorkspaceSnapshot archiveTest(WorkspaceSnapshot data, String id) {
    final old = data.labTests.where((t) => t.id == id).firstOrNull;
    if (old == null) throw const WorkspaceException('testNotFound');
    if (!old.active) return data;
    return data.copyWith(
      labTests: data.labTests
          .map((t) => t.id == id ? t.copyWith(active: false, version: t.version + 1) : t)
          .toList(),
    );
  }

  static WorkspaceSnapshot addOrder(
    WorkspaceSnapshot data,
    LabOrder order, {
    LabPayment? initialPayment,
  }) {
    if (order.patientName.trim().isEmpty) {
      throw const WorkspaceException('requiredField');
    }
    if (order.patientAge < 0) {
      throw const WorkspaceException('invalidAge');
    }
    if (!data.staff.any((s) => s.id == order.staffId)) {
      throw const WorkspaceException('unknownStaff');
    }
    if (order.items.isEmpty) {
      throw const WorkspaceException('itemsRequired');
    }
    for (final item in order.items) {
      final catalogTest = data.labTests.where((t) => t.id == item.testId).firstOrNull;
      if (catalogTest == null || !catalogTest.active) {
        throw const WorkspaceException('testNotFound');
      }
      if (catalogTest.priceMinor != item.priceMinor) {
        throw const WorkspaceException('stalePrice');
      }
    }
    if (data.labOrders.any((o) => o.id == order.id)) {
      // Idempotent order addition
      return data;
    }

    final newPayments = [...data.labPayments];
    if (initialPayment != null) {
      if (initialPayment.amountMinor <= 0 ||
          initialPayment.amountMinor > order.totalMinor) {
        throw const WorkspaceException('invalidPaymentAmount');
      }
      if (!data.staff.any((s) => s.id == initialPayment.staffId)) {
        throw const WorkspaceException('unknownStaff');
      }
      if (!newPayments.any((p) => p.id == initialPayment.id)) {
        newPayments.add(initialPayment);
      }
    }

    return data.copyWith(
      labOrders: [...data.labOrders, order],
      labPayments: newPayments,
    );
  }

  static WorkspaceSnapshot addPayment(WorkspaceSnapshot data, LabPayment payment) {
    if (payment.amountMinor <= 0) {
      throw const WorkspaceException('invalidPaymentAmount');
    }
    final order = data.labOrders.where((o) => o.id == payment.orderId).firstOrNull;
    if (order == null) throw const WorkspaceException('orderNotFound');
    if (!data.staff.any((s) => s.id == payment.staffId)) {
      throw const WorkspaceException('unknownStaff');
    }
    if (data.labPayments.any((p) => p.id == payment.id)) {
      // Idempotent payment
      return data;
    }
    final remaining = data.remainingForLab(order);
    if (payment.amountMinor > remaining) {
      throw const WorkspaceException('invalidPaymentAmount');
    }
    return data.copyWith(
      labPayments: [...data.labPayments, payment],
    );
  }

  static WorkspaceSnapshot setReceived(
    WorkspaceSnapshot data,
    String orderId,
    String staffId, {
    required bool received,
    String? reason,
  }) {
    final order = data.labOrders.where((o) => o.id == orderId).firstOrNull;
    if (order == null) throw const WorkspaceException('orderNotFound');
    if (!data.staff.any((s) => s.id == staffId)) {
      throw const WorkspaceException('unknownStaff');
    }
    if (order.received == received) {
      // Idempotent: do not touch receivedAt or duplicate
      return data;
    }
    final updated = order.copyWith(
      received: received,
      receivedAt: received ? (order.receivedAt ?? DateTime.now()) : null,
      receivedBy: received ? staffId : null,
      resultReason: reason,
      version: order.version + 1,
    );
    return data.copyWith(
      labOrders: data.labOrders.map((o) => o.id == orderId ? updated : o).toList(),
    );
  }
}

