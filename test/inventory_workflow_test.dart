import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/catalogue/data/models/procedure.dart';
import 'package:newcare/features/inventory/data/models/stock_item.dart';
import 'package:newcare/features/inventory/data/models/case_stock_usage.dart';
import 'package:newcare/features/management/data/managed_record_kind.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/workspace/data/repositories/workspace_repository.dart';

class _Store extends MemoryStringStore {
  bool fail=false;
  @override
  Future<void> write(String key,String value) async {
    if(fail) throw StateError('unavailable');
    await super.write(key,value);
  }
}
void main() {
  late _Store store;
  late LocalWorkspaceRepository repo;
  CaseRecord record({String id='case-1',int quantity=2,List<CaseStockUsage>? usages})=>CaseRecord(
    id:id,shiftId:'',staffId:'n',title:'Procedure',procedureId:'p',supplies:[],
    amountMinor:10000,agreedTotalMinor:10000,payment:PaymentMethod.cash,
    location:CaseLocation.inside,createdAt:DateTime.utc(2026,10,31,12),
    stockUsages:usages??[CaseStockUsage(stockItemId:'s',name:'Gauze',quantity:quantity)]);
  setUp(()async {
    store=_Store();repo=LocalWorkspaceRepository(store,seedDemo:false);
    await repo.initialize();
    await repo.addStaff(const NursingMember(id:'n',name:'Nurse'));
    await repo.addProcedure(const Procedure(id:'p',nameAr:'Procedure',nameEn:'Procedure'));
    await repo.saveStockItem(const StockItem(id:'s',name:'Gauze',quantity:10));
  });
  tearDown(()async=>repo.dispose());
  test('case save consumes stock once, price edit does not consume again',()async {
    await repo.addCase(record());await repo.addCase(record());
    expect(repo.current.stockItems.single.quantity,8);
    expect(repo.current.stockMovements,hasLength(2)); // initial stock + consumption
    await repo.updateRecord(ManagedRecordKind.caseRecord,'case-1',{'agreedTotal':12000},'price correction');
    expect(repo.current.stockItems.single.quantity,8);
    expect(repo.current.stockMovements,hasLength(2));
  });
  test('insufficient multi-item usage and failed persistence leave all sources unchanged',()async {
    final before=repo.current;
    await expectLater(repo.addCase(record(usages:[
      const CaseStockUsage(stockItemId:'s',name:'Gauze',quantity:2),
      const CaseStockUsage(stockItemId:'unknown',name:'Unknown',quantity:1),
    ])),throwsA(isA<WorkspaceException>()));
    expect(identical(repo.current,before),isTrue);
    store.fail=true;
    await expectLater(repo.addCase(record()),throwsStateError);
    expect(identical(repo.current,before),isTrue);
    store.fail=false;await repo.addCase(record());
    expect(repo.current.stockItems.single.quantity,8);
  });
  test('usage correction applies delta and deletion does not restock consumed material',()async {
    await repo.addCase(record());
    await repo.updateRecord(ManagedRecordKind.caseRecord,'case-1',{
      'stockUsages':[const CaseStockUsage(stockItemId:'s',name:'Gauze',quantity:3).toJson()],
    },'usage correction');
    expect(repo.current.stockItems.single.quantity,7);
    await repo.deleteRecord(ManagedRecordKind.caseRecord,'case-1','wrong record');
    expect(repo.current.stockItems.single.quantity,7);
  });
  test('exhausted historical usage is retained but archived stock cannot increase',()async {
    await repo.addCase(record(quantity:10));
    await repo.archiveStockItem('s');
    await repo.updateRecord(ManagedRecordKind.caseRecord,'case-1',{'agreedTotal':12000},'price');
    expect(repo.current.stockItems.single.quantity,0);
    await expectLater(repo.updateRecord(ManagedRecordKind.caseRecord,'case-1',{
      'stockUsages':[const CaseStockUsage(stockItemId:'s',name:'Gauze',quantity:11).toJson()],
    },'usage'),throwsA(isA<WorkspaceException>()));
    expect(repo.current.stockItems.single.quantity,0);
  });
  test('old cases have no invented stock quantities and new state reopens',()async {
    final json=record().toJson()..remove('stockUsages');
    expect(CaseRecord.fromJson(json).stockUsages,isEmpty);
    await repo.addCase(record());
    final reopened=LocalWorkspaceRepository(store,seedDemo:false);
    await reopened.initialize();
    expect(reopened.current.stockItems.single.quantity,8);
    expect(reopened.current.cases.single.stockUsages.single.quantity,2);
    await reopened.dispose();
  });
}
