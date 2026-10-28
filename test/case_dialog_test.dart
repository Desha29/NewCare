import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/presentation/widgets/add_case_dialog.dart';
import 'package:newcare/features/cases/presentation/widgets/case_form_fields.dart';
import 'package:newcare/features/shifts/presentation/widgets/shift_nursing_grid.dart';
import 'package:newcare/features/shifts/presentation/widgets/recent_cases_table.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'single add-case dialog switches tabs and saves outside address on mobile',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      expect(find.byType(ShiftNursingGrid), findsOneWidget);
      expect(find.byType(RecentCasesTable), findsOneWidget);
      expect(find.text('Add case'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Add case'));
      await tester.pumpAndSettle();
      expect(find.byType(AddCaseDialog), findsOneWidget);
      expect(find.byType(Tab), findsNWidgets(2));
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();
      final fields = tester.widget<CaseFormFields>(find.byType(CaseFormFields));
      expect(fields.outside, isTrue);
      fields.title.text = 'Home dressing';
      fields.onProcedure('p2');
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, 'Save case');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.current.cases.length, 12);
      expect(find.byType(AddCaseDialog), findsOneWidget);
      fields.address.text = '12 Test Street';
      final amountField = tester
          .widgetList<NcField>(find.byType(NcField))
          .firstWhere((f) => f.label.contains('Amount'));
      amountField.controller.text = '180';
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.byType(AddCaseDialog), findsNothing);
      expect(repo.current.cases.length, 13);
      expect(repo.current.cases.last.location, CaseLocation.outside);
      expect(repo.current.cases.last.address, '12 Test Street');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
