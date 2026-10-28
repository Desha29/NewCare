import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/launch/presentation/screens/splash_screen.dart';
import 'package:newcare/core/theme/app_theme.dart';
import 'package:newcare/l10n/app_localizations.dart';
import 'package:newcare/features/cases/presentation/widgets/add_case_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final font = FontLoader('Cairo');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(rootBundle.load('assets/fonts/Cairo-$weight.ttf'));
    }
    await font.load();
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  final examples = [
    ('mobile-nursing', const Size(390, 844), AppPage.activeShift),
    ('tablet-nursing', const Size(1024, 900), AppPage.activeShift),
    ('desktop-manager', const Size(1440, 960), AppPage.overview),
    ('mobile-manager', const Size(390, 844), AppPage.overview),
    ('square-shifts', const Size(1024, 1024), AppPage.shifts),
    ('small-square-shifts', const Size(768, 768), AppPage.shifts),
    ('desktop-transactions', const Size(1440, 960), AppPage.transactions),
    ('mobile-transactions', const Size(390, 844), AppPage.transactions),
    ('manager-login', const Size(1024, 1024), AppPage.login),
    ('mobile-login', const Size(390, 844), AppPage.login),
    ('desktop-nursing', const Size(1440, 960), AppPage.activeShift),
    ('nursing-cards', const Size(1440, 960), AppPage.nursing),
    ('mobile-nursing-cards', const Size(390, 844), AppPage.nursing),
    ('payroll', const Size(1440, 960), AppPage.payroll),
    ('catalogue', const Size(1440, 960), AppPage.catalogue),
    ('cases-cards', const Size(1440, 960), AppPage.caseLog),
    ('mobile-case-cards', const Size(390, 844), AppPage.shiftCases),
    ('shift-cases-table', const Size(1024, 1024), AppPage.shiftCases),
    ('mobile-case-dialog', const Size(390, 844), AppPage.activeShift),
    ('mobile-splash', const Size(390, 844), null),
  ];
  for (final example in examples) {
    testWidgets('render ${example.$1}', (tester) async {
      tester.view.physicalSize = example.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore(), repoStore = MemoryStringStore();
      final repo = LocalWorkspaceRepository(repoStore);
      await repo.initialize();
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: NewCareApp(repository: repo, store: store),
        ),
      );
      await tester.pumpAndSettle();
      if (example.$3 != null) {
        final app = tester
            .element(find.byType(Scaffold).first)
            .read<AppCubit>();
        app.unlock('newcare-demo');
        app.navigate(example.$3!);
        await tester.pumpAndSettle();
      } else {
        await tester.pumpWidget(
          RepaintBoundary(
            key: boundary,
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              locale: const Locale('ar'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              home: const SplashScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/branding/newcare-icon.png'),
          tester.element(find.byType(Scaffold).first),
        ),
      );
      await tester.pumpAndSettle();
      if (example.$1 == 'mobile-case-dialog') {
        await tester.tap(find.widgetWithText(FilledButton, 'إضافة حالة'));
        await tester.pumpAndSettle();
        expect(find.byType(AddCaseDialog), findsOneWidget);
      }
      if (example.$1 == 'shift-cases-table') {
        await tester.tap(find.text('جدول'));
        await tester.pumpAndSettle();
      }
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile(
          Uri.file(
            'C:/Users/Desha/Documents/Codex/2026-10-28/newcare-nursing-center-last-updatedoct-28/outputs/newcare-${example.$1}.png',
          ),
        ),
      );
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    });
  }
}
