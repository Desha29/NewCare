import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/management/presentation/widgets/delete_record_dialog.dart';
import 'package:newcare/features/management/presentation/widgets/record_editor_dialog.dart';
import 'package:newcare/features/management/presentation/widgets/record_actions.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'manager can search, edit and delete transaction source with reason',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      await repo.addMovement(
        CashMovement(
          id: 'ui-movement',
          shiftId: 'shift-demo',
          staffId: 'n1',
          kind: CashKind.expense,
          amountMinor: 15000,
          reason: 'Supply receipt',
          createdAt: DateTime.now(),
        ),
      );
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
      app.navigate(AppPage.transactions);
      await tester.pumpAndSettle();
      expect(app.state.page, AppPage.login);
      app.unlock('newcare-demo');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'Supply receipt');
      await tester.pumpAndSettle();
      final actions = find.byType(RecordActions);
      expect(actions, findsOneWidget);
      await tester.ensureVisible(actions);
      await tester.tap(
        find.descendant(of: actions, matching: find.byTooltip('Edit')),
      );
      await tester.pumpAndSettle();
      final editor = find.byType(RecordEditorDialog);
      expect(editor, findsOneWidget);
      final fields = find.descendant(
        of: editor,
        matching: find.byType(TextFormField),
      );
      await tester.enterText(fields.first, '175');
      await tester.enterText(fields.last, 'Correct receipt amount');
      final save = find.widgetWithText(FilledButton, 'Save');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.current.movements.single.amountMinor, 17500);
      await tester.ensureVisible(actions);
      await tester.tap(
        find.descendant(of: actions, matching: find.byTooltip('Delete')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DeleteRecordDialog), findsOneWidget);
      await tester.enterText(
        find.descendant(
          of: find.byType(DeleteRecordDialog),
          matching: find.byType(TextFormField),
        ),
        'Duplicate receipt',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(repo.current.movements, isEmpty);
      expect(repo.current.audit.last.detail, contains('Duplicate receipt'));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
