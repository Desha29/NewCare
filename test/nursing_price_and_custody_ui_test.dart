import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/cases/presentation/widgets/case_price_dialog.dart';
import 'package:newcare/features/cases/presentation/widgets/case_payment_dialog.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_handover_panel.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'nursing changes saved price, receives a part, and hands over only the drawer',
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
      final context = tester.element(find.byType(Scaffold).first);
      final app = context.read<AppCubit>();
      final original = repo.current.cases.first,
          before = repo.current.drawerBalance;
      expect(app.state.managerUnlocked, false);
      CasePriceDialog.open(context, original);
      await tester.pumpAndSettle();
      final total = tester
          .widgetList<NcField>(
            find.descendant(
              of: find.byType(CasePriceDialog),
              matching: find.byType(NcField),
            ),
          )
          .firstWhere((f) => f.label == 'Case total');
      total.controller.text = ((repo.current.paidFor(original) + 10000) / 100)
          .toStringAsFixed(2);
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();
      expect(find.byType(CasePriceDialog), findsNothing);
      final priced = repo.current.cases.first;
      expect(repo.current.remainingFor(priced), 10000);
      expect(repo.current.drawerBalance, before);
      CasePaymentDialog.open(
        tester.element(find.byType(Scaffold).first),
        priced.id,
      );
      await tester.pumpAndSettle();
      tester
          .widget<NcSelect<String>>(
            find.descendant(
              of: find.byType(CasePaymentDialog),
              matching: find.byType(NcSelect<String>),
            ),
          )
          .onChanged('n1');
      tester
              .widget<NcField>(
                find.descendant(
                  of: find.byType(CasePaymentDialog),
                  matching: find.byType(NcField),
                ),
              )
              .controller
              .text =
          '25';
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save payment'));
      await tester.pumpAndSettle();
      expect(repo.current.remainingFor(repo.current.cases.first), 7500);
      expect(repo.current.drawerBalance, before + 2500);
      app.navigate(AppPage.cashMovement);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.widgetWithText(FilledButton, 'Hand over drawer'),
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Hand over drawer'));
      await tester.pumpAndSettle();
      expect(find.byType(DrawerHandoverPanel), findsOneWidget);
      final selects = tester
          .widgetList<NcSelect<String>>(
            find.descendant(
              of: find.byType(DrawerHandoverPanel),
              matching: find.byType(NcSelect<String>),
            ),
          )
          .toList();
      selects.first.onChanged('n1');
      selects.last.onChanged('n2');
      await tester.pumpAndSettle();
      tester
          .widgetList<NcField>(
            find.descendant(
              of: find.byType(DrawerHandoverPanel),
              matching: find.byType(NcField),
            ),
          )
          .firstWhere((f) => f.label == 'Counted cash')
          .controller
          .text = ((before + 2500) / 100).toStringAsFixed(
        2,
      );
      final confirm = find.widgetWithText(
        FilledButton,
        'Confirm drawer handover',
      );
      await tester.ensureVisible(confirm);
      await tester.tap(confirm);
      await tester.pumpAndSettle();
      expect(repo.current.drawerHolder, 'n2');
      expect(repo.current.handovers.single.statusKey, 'drawerMatched');
      expect(find.byType(Dialog), findsNothing);
      expect(app.state.managerUnlocked, false);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
