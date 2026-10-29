import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/widgets/case_book_navigation_entry.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/core/widgets/nc_adaptive_table.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/presentation/widgets/case_ledger_section.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'sidebar opens separate full-width ledgers containing only their location',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(
        NewCareApp(repository: repo, store: MemoryStringStore()),
      );
      await tester.pumpAndSettle();
      final entry = find.byType(CaseBookNavigationEntry);
      await tester.tap(
        find.descendant(of: entry, matching: find.text('دفتر الحالات')),
      );
      await tester.pumpAndSettle();
      for (final location in CaseLocation.values) {
        await tester.tap(
          find.descendant(
            of: entry,
            matching: find.text(
              location == CaseLocation.inside ? 'داخل المركز' : 'خارج المركز',
            ),
          ),
        );
        await tester.pumpAndSettle();
        final ledger = find.byType(CaseLedgerSection);
        expect(ledger, findsOneWidget);
        final section = tester.widget<CaseLedgerSection>(ledger);
        expect(section.location, location);
        expect(section.records, isNotEmpty);
        expect(section.records.every((c) => c.location == location), isTrue);
        expect(
          section.records.length,
          repo.current.cases.where((c) => c.location == location).length,
        );
        expect(tester.getSize(ledger).width, greaterThan(1100));
        expect(
          tester.widget<NcAdaptiveTable>(find.byType(NcAdaptiveTable)).headers,
          contains('طريقة الدفع'),
        );
        final filter = tester.widget<NcSelect<String>>(
          find.byType(NcSelect<String>),
        );
        for (final method in PaymentMethod.values) {
          filter.onChanged(method.name);
          await tester.pumpAndSettle();
          final filtered = tester.widget<CaseLedgerSection>(ledger).records;
          expect(
            filtered.length,
            repo.current.cases
                .where((c) => c.location == location && c.payment == method)
                .length,
          );
          expect(filtered.every((c) => c.payment == method), isTrue);
        }
        filter.onChanged('all');
        await tester.pumpAndSettle();
      }
      final selected = tester
          .widget<CaseLedgerSection>(find.byType(CaseLedgerSection))
          .records
          .first;
      await tester.enterText(find.byType(TextField).first, selected.id);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CaseLedgerSection>(find.byType(CaseLedgerSection))
            .records
            .map((c) => c.id),
        [selected.id],
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );

  testWidgets(
    'phone can switch ledgers while the case-book destination stays selected',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(
        NewCareApp(repository: repo, store: MemoryStringStore()),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('دفتر الحالات'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'خارج المركز'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CaseLedgerSection>(find.byType(CaseLedgerSection))
            .location,
        CaseLocation.outside,
      );
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
