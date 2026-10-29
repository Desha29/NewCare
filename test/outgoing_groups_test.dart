import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/drawer/presentation/widgets/movement_form.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_handover_button.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_balance_card.dart';
import 'package:newcare/core/theme/app_colors.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(1024, 1024)]) {
    testWidgets('two outgoing groups contain person advances at $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore(),
          repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      tester
          .element(find.byType(Scaffold).first)
          .read<AppCubit>()
          .navigate(AppPage.cashMovement);
      await tester.pumpAndSettle();
      final form = find.byType(MovementForm);
      final handover = find.byType(DrawerHandoverButton);
      expect(
        tester.getTopLeft(handover).dy,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byType(DrawerBalanceCard)).dy,
        ),
      );
      expect(tester.getSize(handover).height, greaterThanOrEqualTo(60));
      final handoverButton = tester.widget<FilledButton>(
        find.descendant(of: handover, matching: find.byType(FilledButton)),
      );
      expect(
        handoverButton.style!.backgroundColor!.resolve({}),
        AppColors.teal,
      );
      expect(
        find.descendant(of: form, matching: find.byType(NcSelect<CashKind>)),
        findsNothing,
      );
      expect(find.widgetWithText(ChoiceChip, 'خوارج المركز'), findsOneWidget);
      final people = find.widgetWithText(ChoiceChip, 'خوارج أشخاص');
      expect(people, findsOneWidget);
      await tester.tap(people);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(ChoiceChip, 'سلفة'), findsOneWidget);
      await tester.tap(find.widgetWithText(ChoiceChip, 'سلفة'));
      await tester.pumpAndSettle();
      expect(find.text('سلفة لشخص خارجي'), findsNothing);
      await tester.tap(find.widgetWithText(ChoiceChip, 'شخص آخر'));
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<NcField>(
            find.descendant(of: form, matching: find.byType(NcField)),
          )
          .toList();
      fields.firstWhere((f) => f.label.contains('المبلغ')).controller.text =
          '50';
      fields.firstWhere((f) => f.label == 'اسم الشخص').controller.text = 'أحمد';
      tester
          .widget<NcSelect<String>>(
            find.descendant(of: form, matching: find.byType(NcSelect<String>)),
          )
          .onChanged('n1');
      await tester.pumpAndSettle();
      final save = find.widgetWithText(FilledButton, 'حفظ الخارج');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.current.movements.single.kind, CashKind.externalAdvance);
      expect(repo.current.movements.single.recipient, 'أحمد');
      expect(repo.current.movements.single.amountMinor, 5000);
      expect(repo.current.movements.single.reason, 'سلفة');
      final otherPayment = find.widgetWithText(ChoiceChip, 'صرف آخر');
      await tester.ensureVisible(otherPayment);
      await tester.tap(otherPayment);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, 'التمريض'));
      await tester.pumpAndSettle();
      final otherFields = tester
          .widgetList<NcField>(
            find.descendant(of: form, matching: find.byType(NcField)),
          )
          .toList();
      otherFields
              .firstWhere((f) => f.label.contains('المبلغ'))
              .controller
              .text =
          '40';
      otherFields.firstWhere((f) => f.label == 'البيان').controller.text =
          'رد مبلغ';
      tester
          .widget<NcSelect<String>>(
            find.descendant(of: form, matching: find.byType(NcSelect<String>)),
          )
          .onChanged('n2');
      await tester.pumpAndSettle();
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(repo.current.movements.last.kind, CashKind.expense);
      expect(repo.current.movements.last.categoryKey, 'personOutgoings');
      expect(
        repo.current.movements.last.recipient,
        repo.current.staff.firstWhere((n) => n.id == 'n2').name,
      );
      expect(repo.current.movements, hasLength(2));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    });
  }
}
