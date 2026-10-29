import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/cases/data/services/case_pricing.dart';
import 'package:newcare/features/catalogue/data/models/supply_item.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';

void main() {
  test(
    'multiple procedures and supplies total once and retain historic prices',
    () async {
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await repo.addSupply(
        const SupplyItem(
          id: 's1',
          nameAr: 'كانولا',
          nameEn: 'Cannula',
          priceMinor: 2500,
        ),
      );
      final lines = CasePricing.lines(repo.current, {'p1', 'p2'}, {'s1'});
      expect(lines.fold<int>(0, (sum, line) => sum + line.priceMinor), 45500);
      final c = CaseRecord(
        id: 'priced',
        shiftId: 'shift-demo',
        staffId: 'n1',
        title: 'Two procedures',
        procedureId: 'p1',
        supplies: ['كانولا'],
        amountMinor: 45500,
        payment: PaymentMethod.cash,
        location: CaseLocation.inside,
        createdAt: DateTime.now(),
        lineItems: lines,
      );
      await repo.addCase(c);
      expect(c.effectiveProcedureIds, ['p1', 'p2']);
      expect(CaseRecord.fromJson(c.toJson()).totalMinor, 45500);
      expect(CaseRecord.fromJson(c.toJson()).lineItems.last.priceMinor, 2500);
      await repo.dispose();
    },
  );
}
