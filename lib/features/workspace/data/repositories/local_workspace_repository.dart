import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../../../../core/storage/string_store.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../../catalogue/data/models/procedure.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../shifts/data/models/shift_record.dart';
import '../models/workspace_snapshot.dart';
import '../models/audit_entry.dart';
import '../sources/demo_workspace.dart';
import 'workspace_repository.dart';
import '../../../catalogue/data/models/supply_item.dart';

/// Serialized repository writes prevent lost updates and confirm durable storage
/// before publishing a new snapshot. This adapter is local preview storage.
class LocalWorkspaceRepository implements WorkspaceRepository {
  LocalWorkspaceRepository(this.store,{this.seedDemo=true});
  final StringStore store;
  final bool seedDemo;
  static const storageKey='newcare.workspace.v1';
  final _controller=StreamController<WorkspaceSnapshot>.broadcast();
  final _uuid=const Uuid();
  WorkspaceSnapshot _current=WorkspaceSnapshot();
  Future<void> _tail=Future<void>.value();
  @override WorkspaceSnapshot get current=>_current;
  @override Stream<WorkspaceSnapshot> get changes=>_controller.stream;
  @override Future<void> initialize()async{
    final raw=await store.read(storageKey);
    if(raw!=null){_current=WorkspaceSnapshot.fromJson(jsonDecode(raw) as Map<String,dynamic>);}
    else{_current=seedDemo?demoWorkspace():WorkspaceSnapshot();await store.write(storageKey,jsonEncode(_current.toJson()));}
  }
  Future<void> _update(String action,WorkspaceSnapshot Function(WorkspaceSnapshot) change,{String detail=''}) {
    final operation=_tail.then((_)async{
      final next=change(_current);
      if(identical(next,_current))return;
      final recorded=next.copyWith(audit:[...next.audit,AuditEntry(id:_uuid.v4(),action:action,at:DateTime.now(),detail:detail)]);
      await store.write(storageKey,jsonEncode(recorded.toJson()));
      _current=recorded;
      if(!_controller.isClosed)_controller.add(recorded);
    });
    _tail=operation.then((_) {},onError:(Object _,StackTrace __){});
    return operation;
  }
  void _member(WorkspaceSnapshot s,String id){
    if(!s.staff.any((n)=>n.id==id&&n.active))throw const WorkspaceException('unknownStaff');
  }
  @override Future<void> startShift(String staffId,int countedMinor,{String reason=''})=>_update('handoverRecorded',(s){
    if(s.activeShift!=null)throw const WorkspaceException('shiftAlreadyOpen');
    _member(s,staffId);
    if(countedMinor<0)throw const WorkspaceException('invalidAmount');
    final expected=s.shifts.isEmpty?s.openingMinor:s.expectedCash(s.shifts.last);
    if(expected!=countedMinor&&reason.trim().isEmpty)throw const WorkspaceException('reasonRequired');
    return s.copyWith(shifts:[...s.shifts,ShiftRecord(id:_uuid.v4(),openedAt:DateTime.now(),memberIds:List.unmodifiable([staffId]),openingMinor:countedMinor,note:reason.trim())]);
  },detail:reason);
  @override Future<void> joinShift(String staffId)=>_update('staffJoined',(s){
    _member(s,staffId);final shift=s.activeShift;if(shift==null)throw const WorkspaceException('noOpenShift');
    if(shift.memberIds.contains(staffId))return s;
    return s.copyWith(shifts:s.shifts.map((x)=>x.id==shift.id?x.copyWith(memberIds:List.unmodifiable([...x.memberIds,staffId])):x).toList());
  });
  @override Future<void> endShift(String note)=>_update('shiftEnded',(s){
    final shift=s.activeShift;if(shift==null)throw const WorkspaceException('noOpenToClose');
    return s.copyWith(shifts:s.shifts.map((x)=>x.id==shift.id?x.copyWith(closedAt:DateTime.now(),note:note):x).toList());
  });
  @override Future<void> addCase(CaseRecord record)=>_update('caseAdded',(s){
    if(s.cases.any((x)=>x.id==record.id))return s;
    final shift=s.activeShift;if(shift==null||shift.id!=record.shiftId)throw const WorkspaceException('noOpenShift');
    if(!shift.memberIds.contains(record.staffId))throw const WorkspaceException('staffNotInShift');
    if(record.location==CaseLocation.outside&&record.address.trim().isEmpty)throw const WorkspaceException('addressRequired');
    if(record.title.trim().isEmpty)throw const WorkspaceException('requiredField');
    if(record.amountMinor<0)throw const WorkspaceException('invalidAmount');
    if(!s.procedures.any((x)=>x.id==record.procedureId))throw const WorkspaceException('invalidProcedure');
    return s.copyWith(cases:[...s.cases,record]);
  },detail:record.id);
  @override Future<void> addMovement(CashMovement movement)=>_update('cashAdded',(s){
    if(s.movements.any((x)=>x.id==movement.id))return s;
    final shift=s.activeShift;if(shift==null||shift.id!=movement.shiftId)throw const WorkspaceException('noOpenShift');
    if(!shift.memberIds.contains(movement.staffId))throw const WorkspaceException('staffNotInShift');
    if(movement.amountMinor<=0)throw const WorkspaceException('invalidAmount');
    if(movement.reason.trim().isEmpty)throw const WorkspaceException('requiredField');
    return s.copyWith(movements:[...s.movements,movement]);
  },detail:movement.id);
  @override Future<void> addStaff(NursingMember member)=>_update('staffAdded',(s){
    if(member.name.trim().isEmpty)throw const WorkspaceException('requiredField');
    if(s.staff.any((x)=>x.id==member.id))return s;
    return s.copyWith(staff:[...s.staff,member]);
  });
  @override Future<void> addProcedure(Procedure procedure)=>_update('procedureAdded',(s){
    if(procedure.nameAr.trim().isEmpty||procedure.nameEn.trim().isEmpty)throw const WorkspaceException('requiredField');
    if(procedure.priceMinor<0)throw const WorkspaceException('invalidAmount');
    return s.copyWith(procedures:[...s.procedures,procedure]);
  });
  @override Future<void> saveSettings({String? managerName,String? managerEmail,int? openingMinor,Map<String,List<String>>? permissions,bool? setupDone})=>_update('settingsSaved',(s){
    if(openingMinor!=null&&s.shifts.isNotEmpty)throw const WorkspaceException('shiftAlreadyOpen');
    if(openingMinor!=null&&openingMinor<0)throw const WorkspaceException('invalidAmount');
    return s.copyWith(managerName:managerName,managerEmail:managerEmail,openingMinor:openingMinor,permissions:permissions,setupDone:setupDone);
  });
  @override Future<void> addSupply(SupplyItem supply)=>_update('procedureAdded',(s){
    if(supply.nameAr.trim().isEmpty||supply.nameEn.trim().isEmpty)throw const WorkspaceException('requiredField');
    return s.copyWith(supplies:[...s.supplies,supply]);
  });
  @override Future<void> dispose()async{await _tail;await _controller.close();}
}

