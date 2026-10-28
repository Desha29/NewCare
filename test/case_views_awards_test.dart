import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/localization/localization_extensions.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/cases/presentation/widgets/case_card_grid.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'shift cases support eight cards per desktop row and table toggle',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore(),
          repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).first);
      context.read<AppCubit>().navigate(AppPage.shiftCases);
      await tester.pumpAndSettle();
      final grid = tester.widget<CaseCardGrid>(find.byType(CaseCardGrid));
      final y = tester
          .getTopLeft(
            find.byKey(ValueKey('case-card-${grid.records.first.id}')),
          )
          .dy;
      for (final r in grid.records.take(8)) {
        expect(
          tester.getTopLeft(find.byKey(ValueKey('case-card-${r.id}'))).dy,
          y,
        );
      }
      expect(
        tester
            .getTopLeft(find.byKey(ValueKey('case-card-${grid.records[8].id}')))
            .dy,
        greaterThan(y),
      );
      await tester.tap(find.text(context.t('tableView')));
      await tester.pumpAndSettle();
      expect(find.byType(CaseCardGrid), findsNothing);
      expect(find.byType(DataTable), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
  testWidgets(
    'manager pays nursing award without reason and drawer cash decreases once',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      final before = repo.current.expectedCash(repo.current.activeShift!);
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).first),
          app = context.read<AppCubit>();
      app.unlock('newcare-demo');
      app.navigate(AppPage.payroll);
      await tester.pumpAndSettle();
      final add = find.widgetWithText(OutlinedButton, context.t('newAward'));
      await tester.ensureVisible(add);
      await tester.tap(add);
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      final fields = tester.widgetList<NcField>(find.byType(NcField)).toList();
      expect(fields.length, 1);
      fields.single.controller.text = '200';
      tester
          .widget<NcSelect<String>>(find.byType(NcSelect<String>))
          .onChanged('n3');
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(FilledButton, context.t('saveAward')),
      );
      await tester.pumpAndSettle();
      expect(repo.current.movements.single.kind, CashKind.award);
      expect(
        repo.current.expectedCash(repo.current.activeShift!),
        before - 20000,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
