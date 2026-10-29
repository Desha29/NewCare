import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/presentation/widgets/add_case_dialog.dart';
import 'package:newcare/features/cases/presentation/widgets/case_form_fields.dart';
import 'package:newcare/features/cases/presentation/widgets/catalogue_multi_picker.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'inline outside case requires address and saves negotiated partial payment',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      final before = repo.current.drawerBalance;
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      expect(find.byType(AddCaseDialog), findsNothing);
      expect(find.text('Add case'), findsNothing);
      expect(find.text('Start shift'), findsNothing);
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();
      final fields = tester.widget<CaseFormFields>(find.byType(CaseFormFields));
      expect(fields.outside, isTrue);
      tester
          .widget<CatalogueMultiPicker>(find.byType(CatalogueMultiPicker).first)
          .onChanged({'p1', 'p2'});
      await tester.pumpAndSettle();
      final inputs = tester.widgetList<NcField>(find.byType(NcField)).toList();
      expect(find.text('Supplies'), findsNothing);
      expect(inputs.where((f) => f.label.endsWith('· Price')), isEmpty);
      inputs.firstWhere((f) => f.label == 'Case total').controller.text = '175';
      inputs
              .firstWhere((f) => f.label.contains('Paid at registration'))
              .controller
              .text =
          '50';
      final save = find.widgetWithText(FilledButton, 'Save case');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.current.cases, hasLength(12));
      fields.address.text = '12 Test Street';
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      final record = repo.current.cases.last;
      expect(record.location, CaseLocation.outside);
      expect(record.address, '12 Test Street');
      expect(record.phone, isEmpty);
      expect(record.effectiveProcedureIds, ['p1', 'p2']);
      expect(record.invoiceMinor, 17500);
      expect(record.lineItems.every((i) => i.priceMinor == 0), isTrue);
      expect(repo.current.remainingFor(record), 12500);
      expect(repo.current.drawerBalance, before + 5000);
      expect(record.shiftId, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
