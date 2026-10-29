import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/presentation/screens/case_form_screen.dart';
import 'package:newcare/features/cases/presentation/widgets/case_form_fields.dart';
import 'package:newcare/features/cases/presentation/widgets/case_ledger_section.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await font.load();
  });
  for (final size in [const Size(1440, 900), const Size(1024, 900)]) {
    testWidgets(
      'registration shows both complete forms without case tables at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repo = LocalWorkspaceRepository(MemoryStringStore());
        await repo.initialize();
        await tester.pumpWidget(
          NewCareApp(repository: repo, store: MemoryStringStore()),
        );
        await tester.pumpAndSettle();
        expect(find.byType(CaseLedgerSection), findsNothing);
        final forms = find.byType(CaseFormScreen);
        expect(forms, findsNWidgets(2));
        for (final form in forms.evaluate()) {
          expect(
            tester.getBottomLeft(find.byWidget(form.widget)).dy,
            lessThan(size.height - 12),
          );
          expect(
            tester.getBottomLeft(find.byWidget(form.widget)).dy,
            greaterThan(size.height - 60),
            reason: 'Both desktop cards should use the available page height',
          );
        }
        expect(
          tester.getBottomLeft(forms.first).dy,
          closeTo(tester.getBottomLeft(forms.last).dy, 1),
        );
        final app = tester
            .element(find.byType(Scaffold).first)
            .read<AppCubit>();
        app.navigate(AppPage.shiftCases);
        await tester.pumpAndSettle();
        expect(find.byType(CaseLedgerSection), findsOneWidget);
        expect(repo.current.cases, hasLength(12));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await repo.dispose();
      },
    );
  }
  testWidgets(
    'outside draft survives changing from desktop columns to mobile tabs',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(
        NewCareApp(repository: repo, store: MemoryStringStore()),
      );
      await tester.pumpAndSettle();
      tester
              .widgetList<CaseFormFields>(find.byType(CaseFormFields))
              .firstWhere((f) => f.outside)
              .address
              .text =
          'عنوان لم يتم حفظه';
      tester.view.physicalSize = const Size(390, 844);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();
      expect(
        tester.widget<CaseFormFields>(find.byType(CaseFormFields)).address.text,
        'عنوان لم يتم حفظه',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
