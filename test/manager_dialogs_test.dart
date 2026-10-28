import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/localization/localization_extensions.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/management/presentation/widgets/catalogue_editor.dart';
import 'package:newcare/features/management/presentation/widgets/salary_editor.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(1024, 1024)]) {
    testWidgets(
      'manager forms are dialogs and Arabic procedure needs only name and price at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = MemoryStringStore();
        await store.write('newcare.locale', 'en');
        final repo = LocalWorkspaceRepository(store);
        await repo.initialize();
        await tester.pumpWidget(NewCareApp(repository: repo, store: store));
        await tester.pumpAndSettle();
        final context = tester.element(find.byType(Scaffold).first),
            app = context.read<AppCubit>();
        app.unlock('newcare-demo');
        app.navigate(AppPage.catalogue);
        await tester.pumpAndSettle();
        expect(find.byType(CatalogueEditor), findsNothing);
        await tester.tap(
          find.widgetWithText(FilledButton, context.t('addProcedure')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(TextFormField), findsNWidgets(2));
        final fields = tester
            .widgetList<NcField>(find.byType(NcField))
            .toList();
        fields.first.controller.text = 'قياس ضغط';
        fields.last.controller.text = '50';
        await tester.tap(find.widgetWithText(FilledButton, context.t('add')));
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(repo.current.procedures.last.nameAr, 'قياس ضغط');
        expect(repo.current.procedures.last.priceMinor, 5000);
        app.navigate(AppPage.payroll);
        await tester.pumpAndSettle();
        expect(find.byType(SalaryEditor), findsNothing);
        await tester.tap(
          find.widgetWithText(FilledButton, context.t('setSalary')),
        );
        await tester.pumpAndSettle();
        tester
            .widget<NcSelect<String>>(find.byType(NcSelect<String>))
            .onChanged('n1');
        await tester.pumpAndSettle();
        final salaryFields = tester
            .widgetList<NcField>(find.byType(NcField))
            .toList();
        salaryFields.first.controller.text = '6500';
        expect(salaryFields.length, 1);
        final save = find.widgetWithText(FilledButton, context.t('save'));
        await tester.ensureVisible(save);
        await tester.tap(save);
        await tester.pumpAndSettle();
        expect(find.byType(Dialog), findsNothing);
        expect(repo.current.staff.first.salaryMinor, 650000);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await repo.dispose();
      },
    );
  }
}
