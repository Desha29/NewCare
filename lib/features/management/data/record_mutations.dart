import '../../workspace/data/models/workspace_snapshot.dart';
import '../../workspace/data/repositories/workspace_repository.dart';
import '../../cases/data/models/case_record.dart';
import '../../staff/data/models/nursing_member.dart';
import '../../catalogue/data/models/procedure.dart';
import '../../catalogue/data/models/supply_item.dart';
import '../../drawer/data/models/cash_movement.dart';
import '../../shifts/data/models/shift_record.dart';
import 'managed_record_kind.dart';

/// Data-layer transformations keep record editing separate from storage.
abstract final class RecordMutations {
  static Map<String, dynamic> read(
    WorkspaceSnapshot data,
    ManagedRecordKind kind,
    String id,
  ) {
    Map<String, dynamic>? result;
    switch (kind) {
      case ManagedRecordKind.caseRecord:
        result = data.cases.where((x) => x.id == id).firstOrNull?.toJson();
      case ManagedRecordKind.nursing:
        result = data.staff.where((x) => x.id == id).firstOrNull?.toJson();
      case ManagedRecordKind.procedure:
        result = data.procedures.where((x) => x.id == id).firstOrNull?.toJson();
      case ManagedRecordKind.supply:
        result = data.supplies.where((x) => x.id == id).firstOrNull?.toJson();
      case ManagedRecordKind.movement:
        result = data.movements.where((x) => x.id == id).firstOrNull?.toJson();
      case ManagedRecordKind.shift:
        result = data.shifts.where((x) => x.id == id).firstOrNull?.toJson();
    }
    if (result == null) throw const WorkspaceException('recordNotFound');
    return result;
  }

  static WorkspaceSnapshot update(
    WorkspaceSnapshot data,
    ManagedRecordKind kind,
    String id,
    Map<String, dynamic> fields,
  ) {
    final before = read(data, kind, id);
    final json = {...before, ...fields, 'id': id};
    switch (kind) {
      case ManagedRecordKind.caseRecord:
        json['shift'] = before['shift'];
        final value = CaseRecord.fromJson(json);
        if (value.title.trim().isEmpty) {
          throw const WorkspaceException('requiredField');
        }
        if (value.amountMinor < 0) {
          throw const WorkspaceException('invalidAmount');
        }
        if (value.location == CaseLocation.outside &&
            value.address.trim().isEmpty) {
          throw const WorkspaceException('addressRequired');
        }
        if (!data.procedures.any((p) => p.id == value.procedureId)) {
          throw const WorkspaceException('invalidProcedure');
        }
        final shift = data.shifts
            .where((s) => s.id == value.shiftId)
            .firstOrNull;
        if (shift == null || !shift.memberIds.contains(value.staffId)) {
          throw const WorkspaceException('staffNotInShift');
        }
        return data.copyWith(
          cases: data.cases.map((x) => x.id == id ? value : x).toList(),
        );
      case ManagedRecordKind.nursing:
        final value = NursingMember.fromJson(json);
        if (value.salaryMinor < 0) {
          throw const WorkspaceException('invalidAmount');
        }
        if (value.name.trim().isEmpty) {
          throw const WorkspaceException('requiredField');
        }
        return data.copyWith(
          staff: data.staff.map((x) => x.id == id ? value : x).toList(),
        );
      case ManagedRecordKind.procedure:
        if (fields.containsKey('ar')) json['en'] = fields['ar'];
        final value = Procedure.fromJson(json);
        if (value.nameAr.trim().isEmpty || value.nameEn.trim().isEmpty) {
          throw const WorkspaceException('requiredField');
        }
        if (value.priceMinor < 0) {
          throw const WorkspaceException('invalidAmount');
        }
        return data.copyWith(
          procedures: data.procedures
              .map((x) => x.id == id ? value : x)
              .toList(),
        );
      case ManagedRecordKind.supply:
        if (fields.containsKey('ar')) json['en'] = fields['ar'];
        final value = SupplyItem.fromJson(json);
        if (value.nameAr.trim().isEmpty || value.nameEn.trim().isEmpty) {
          throw const WorkspaceException('requiredField');
        }
        return data.copyWith(
          supplies: data.supplies.map((x) => x.id == id ? value : x).toList(),
        );
      case ManagedRecordKind.movement:
        json['shift'] = before['shift'];
        final value = CashMovement.fromJson(json);
        if (!data.staff.any((n) => n.id == value.staffId)) {
          throw const WorkspaceException('unknownStaff');
        }
        if (value.amountMinor <= 0) {
          throw const WorkspaceException('invalidAmount');
        }
        if (value.reason.trim().isEmpty) {
          throw const WorkspaceException('requiredField');
        }
        if (value.kind != CashKind.advance &&
            value.kind != CashKind.award &&
            !data.shifts.any(
              (s) =>
                  s.id == value.shiftId && s.memberIds.contains(value.staffId),
            )) {
          throw const WorkspaceException('staffNotInShift');
        }
        return data.copyWith(
          movements: data.movements.map((x) => x.id == id ? value : x).toList(),
        );
      case ManagedRecordKind.shift:
        final value = ShiftRecord.fromJson(json);
        if (value.openingMinor < 0) {
          throw const WorkspaceException('invalidAmount');
        }
        if (value.closedAt != null &&
            value.closedAt!.isBefore(value.openedAt)) {
          throw const WorkspaceException('invalidDates');
        }
        if (value.isOpen && data.shifts.any((s) => s.id != id && s.isOpen)) {
          throw const WorkspaceException('shiftAlreadyOpen');
        }
        return data.copyWith(
          shifts: data.shifts.map((x) => x.id == id ? value : x).toList(),
        );
    }
  }

  static WorkspaceSnapshot delete(
    WorkspaceSnapshot data,
    ManagedRecordKind kind,
    String id,
  ) {
    final before = read(data, kind, id);
    return switch (kind) {
      ManagedRecordKind.caseRecord => data.copyWith(
        cases: data.cases.where((x) => x.id != id).toList(),
      ),
      ManagedRecordKind.nursing => data.copyWith(
        staff: data.staff
            .map(
              (x) => x.id == id
                  ? NursingMember.fromJson({...before, 'active': false})
                  : x,
            )
            .toList(),
      ),
      ManagedRecordKind.procedure => data.copyWith(
        procedures: data.procedures
            .map(
              (x) => x.id == id
                  ? Procedure.fromJson({...before, 'active': false})
                  : x,
            )
            .toList(),
      ),
      ManagedRecordKind.supply => data.copyWith(
        supplies: data.supplies.where((x) => x.id != id).toList(),
      ),
      ManagedRecordKind.movement => data.copyWith(
        movements: data.movements.where((x) => x.id != id).toList(),
      ),
      ManagedRecordKind.shift => data.copyWith(
        shifts: data.shifts
            .map(
              (x) => x.id == id
                  ? x.copyWith(
                      archived: true,
                      closedAt: x.closedAt ?? DateTime.now(),
                    )
                  : x,
            )
            .toList(),
      ),
    };
  }
}
