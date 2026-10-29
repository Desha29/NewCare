import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/utils/formatters.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/cases/data/models/case_payment.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_balance_card.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_handover_button.dart';
import 'package:newcare/features/drawer/presentation/widgets/movement_form.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'drawer balance reacts to cash receipts and outgoings but excludes wallets',
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
      final context = tester.element(find.byType(Scaffold).first);
      context.read<AppCubit>().navigate(AppPage.cashMovement);
      await tester.pumpAndSettle();
      final before = repo.current.drawerBalance;
      void expectBalance(int value) => expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('live-drawer-balance')))
            .data,
        context.money(value),
      );
      expectBalance(before);
      expect(
        tester.getCenter(find.byType(MovementForm)).dx,
        greaterThan(tester.getCenter(find.byType(DrawerBalanceCard)).dx),
      );
      expect(
        tester.getTopLeft(find.byType(DrawerHandoverButton)).dy,
        greaterThan(tester.getBottomLeft(find.byType(DrawerBalanceCard)).dy),
      );
      CaseRecord record(String id, PaymentMethod method) => CaseRecord(
        id: id,
        shiftId: '',
        staffId: repo.current.staff.first.id,
        title: repo.current.procedures.first.nameAr,
        procedureId: repo.current.procedures.first.id,
        supplies: const [],
        amountMinor: 10000,
        agreedTotalMinor: 50000,
        payment: method,
        location: CaseLocation.inside,
        createdAt: DateTime.now(),
      );
      await repo.addCase(record('cash-live', PaymentMethod.cash));
      await tester.pumpAndSettle();
      expectBalance(before + 10000);
      await repo.addCase(record('wallet-live', PaymentMethod.wallet));
      await tester.pumpAndSettle();
      expectBalance(before + 10000);
      for (final method in PaymentMethod.values) {
        await repo.addCasePayment(
          CasePayment(
            id: 'part-${method.name}',
            caseId: 'cash-live',
            staffId: repo.current.staff.first.id,
            amountMinor: 3000,
            method: method,
            paidAt: DateTime.now(),
          ),
        );
        await tester.pumpAndSettle();
        expectBalance(before + 13000);
      }
      await repo.addMovement(
        CashMovement(
          id: 'center-live',
          shiftId: '',
          staffId: repo.current.staff.first.id,
          kind: CashKind.expense,
          amountMinor: 2500,
          reason: 'كهرباء',
          createdAt: DateTime.now(),
        ),
      );
      await tester.pumpAndSettle();
      expectBalance(before + 10500);
      await repo.addMovement(
        CashMovement(
          id: 'advance-live',
          shiftId: '',
          staffId: repo.current.staff.first.id,
          kind: CashKind.advance,
          amountMinor: 1000,
          recipient: repo.current.staff.first.name,
          reason: 'سلفة',
          createdAt: DateTime.now(),
        ),
      );
      await tester.pumpAndSettle();
      expectBalance(before + 9500);
      final draft = tester
          .widgetList<NcField>(
            find.descendant(
              of: find.byType(MovementForm),
              matching: find.byType(NcField),
            ),
          )
          .firstWhere((field) => field.label.contains('المبلغ'));
      draft.controller.text = '42';
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(find.byType(DrawerBalanceCard)).dy,
        greaterThan(tester.getBottomLeft(find.byType(MovementForm)).dy),
      );
      expect(
        tester
            .widgetList<NcField>(
              find.descendant(
                of: find.byType(MovementForm),
                matching: find.byType(NcField),
              ),
            )
            .firstWhere((field) => field.label.contains('المبلغ'))
            .controller
            .text,
        '42',
      );
      expectBalance(before + 9500);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
