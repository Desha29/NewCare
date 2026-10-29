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
    ('desktop-settings', const Size(1440, 960), AppPage.permissions),
    ('desktop-outgoings', const Size(1440, 960), AppPage.cashMovement),
    ('mobile-outgoings', const Size(390, 844), AppPage.cashMovement),
    ('desktop-person-outgoing', const Size(1440, 960), AppPage.cashMovement),
    ('mobile-person-outgoing', const Size(390, 844), AppPage.cashMovement),
    ('mobile-nursing', const Size(390, 844), AppPage.activeShift),
    ('tablet-nursing', const Size(1024, 900), AppPage.activeShift),
    ('desktop-manager', const Size(1440, 960), AppPage.overview),
    ('mobile-manager', const Size(390, 844), AppPage.overview),
    ('square-drawer', const Size(1024, 1024), AppPage.shifts),
    ('small-square-drawer', const Size(768, 768), AppPage.shifts),
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
    ('mobile-case-book', const Size(390, 844), AppPage.shiftCases),
    ('desktop-case-book', const Size(1440, 960), AppPage.shiftCases),
    ('desktop-outside-case-book', const Size(1440, 960), AppPage.outsideCaseBook),
    ('mobile-outside-case-book', const Size(390, 844), AppPage.outsideCaseBook),
    ('case-book-square', const Size(1024, 1024), AppPage.shiftCases),
    ('mobile-case-register-outside', const Size(390, 844), AppPage.activeShift),
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
      if (example.$1 == 'mobile-case-register-outside') {
        await tester.tap(find.byType(Tab).last);
        await tester.pumpAndSettle();
      }
      if (example.$1.contains('person-outgoing')) {
        await tester.tap(find.widgetWithText(ChoiceChip, 'خوارج أشخاص'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ChoiceChip, 'سلفة'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(ChoiceChip, 'شخص آخر'));
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
