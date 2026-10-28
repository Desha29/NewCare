import '../../../catalogue/data/models/supply_item.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../shifts/data/models/shift_record.dart';
import 'audit_entry.dart';

class WorkspaceSnapshot {
  WorkspaceSnapshot({List<NursingMember> staff=const [],List<Procedure> procedures=const [],List<SupplyItem> supplies=const [],List<ShiftRecord> shifts=const [],List<CaseRecord> cases=const [],List<CashMovement> movements=const [],List<AuditEntry> audit=const [], this.openingMinor=0,this.setupDone=false,this.managerName='',this.managerEmail='',Map<String,List<String>> permissions=const {}})
      : staff=List.unmodifiable(staff),procedures=List.unmodifiable(procedures),supplies=List.unmodifiable(supplies),shifts=List.unmodifiable(shifts),cases=List.unmodifiable(cases),movements=List.unmodifiable(movements),audit=List.unmodifiable(audit),permissions=Map.unmodifiable(permissions.map((k,v)=>MapEntry(k,List<String>.unmodifiable(v))));
  final List<NursingMember> staff;
  final List<Procedure> procedures;
  final List<SupplyItem> supplies;
  final List<ShiftRecord> shifts;
  final List<CaseRecord> cases;
  final List<CashMovement> movements;
  final List<AuditEntry> audit;
  final int openingMinor;
  final bool setupDone;
  final String managerName,managerEmail;
  final Map<String,List<String>> permissions;
  ShiftRecord? get activeShift { for(final shift in shifts.reversed){if(shift.isOpen)return shift;} return null; }
  int expectedCash(ShiftRecord shift)=>shift.openingMinor + cases.where((c)=>c.shiftId==shift.id&&c.payment==PaymentMethod.cash).fold<int>(0,(s,c)=>s+c.amountMinor) + movements.where((m)=>m.shiftId==shift.id).fold<int>(0,(s,m)=>s+m.signedMinor);
  WorkspaceSnapshot copyWith({List<NursingMember>? staff,List<Procedure>? procedures,List<SupplyItem>? supplies,List<ShiftRecord>? shifts,List<CaseRecord>? cases,List<CashMovement>? movements,List<AuditEntry>? audit,int? openingMinor,bool? setupDone,String? managerName,String? managerEmail,Map<String,List<String>>? permissions})=>WorkspaceSnapshot(staff:staff??this.staff,procedures:procedures??this.procedures,supplies:supplies??this.supplies,shifts:shifts??this.shifts,cases:cases??this.cases,movements:movements??this.movements,audit:audit??this.audit,openingMinor:openingMinor??this.openingMinor,setupDone:setupDone??this.setupDone,managerName:managerName??this.managerName,managerEmail:managerEmail??this.managerEmail,permissions:permissions??this.permissions);
  Map<String,dynamic> toJson()=>{'version':1,'supplies':supplies.map((x)=>x.toJson()).toList(),'staff':staff.map((x)=>x.toJson()).toList(),'procedures':procedures.map((x)=>x.toJson()).toList(),'shifts':shifts.map((x)=>x.toJson()).toList(),'cases':cases.map((x)=>x.toJson()).toList(),'movements':movements.map((x)=>x.toJson()).toList(),'audit':audit.map((x)=>x.toJson()).toList(),'opening':openingMinor,'setupDone':setupDone,'managerName':managerName,'managerEmail':managerEmail,'permissions':permissions};
  factory WorkspaceSnapshot.fromJson(Map<String,dynamic> j)=>WorkspaceSnapshot(supplies:((j['supplies'] as List?)??[]).map((x)=>SupplyItem.fromJson(Map<String,dynamic>.from(x as Map))).toList(),staff:(j['staff'] as List).map((x)=>NursingMember.fromJson(Map<String,dynamic>.from(x as Map))).toList(),procedures:(j['procedures'] as List).map((x)=>Procedure.fromJson(Map<String,dynamic>.from(x as Map))).toList(),shifts:(j['shifts'] as List).map((x)=>ShiftRecord.fromJson(Map<String,dynamic>.from(x as Map))).toList(),cases:(j['cases'] as List).map((x)=>CaseRecord.fromJson(Map<String,dynamic>.from(x as Map))).toList(),movements:(j['movements'] as List).map((x)=>CashMovement.fromJson(Map<String,dynamic>.from(x as Map))).toList(),audit:(j['audit'] as List).map((x)=>AuditEntry.fromJson(Map<String,dynamic>.from(x as Map))).toList(),openingMinor:j['opening'] as int,setupDone:j['setupDone'] as bool,managerName:j['managerName'] as String,managerEmail:j['managerEmail'] as String,permissions:(j['permissions'] as Map? ?? {}).map((k,v)=>MapEntry(k as String,List<String>.from(v as List))));
}

