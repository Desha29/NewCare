import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/theme/app_theme.dart';
import 'package:newcare/features/auth/data/models/manager_identity.dart';
import 'package:newcare/features/auth/data/repositories/center_setup_gateway.dart';
import 'package:newcare/features/auth/presentation/screens/cloud_setup_screen.dart';
import 'package:newcare/l10n/app_localizations.dart';

class FakeSetup implements CenterSetupGateway {
  int requests = 0;
  bool fail = false;
  Completer<void>? waiting;
  @override
  Future<void> requestFirstManager(String username, String password) async {
    requests++;
    if (fail) throw const ManagerAuthException('cloudSetupFailed');
    await waiting?.future;
  }

  @override
  Future<ManagerIdentity> activateFirstManager({
    required String username,
    required String name,
    required String email,
    required String password,
  }) async => ManagerIdentity(
    id: 'm',
    centerId: 'c',
    username: username,
    name: name,
    email: email,
    manageAccounts: true,
    viewDiagnostics: true,
  );
}

Widget setupApp(
  FakeSetup gateway, {
  String locale = 'ar',
  Future<void> Function(ManagerIdentity)? ready,
}) => MaterialApp(
  theme: AppTheme.light(),
  locale: Locale(locale),
  debugShowCheckedModeBanner: false,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: CloudSetupScreen(runtime: gateway, onReady: ready ?? (_) async {}),
);

void main() {
  for (final locale in ['ar', 'en']) {
    for (final size in [
      const Size(320, 568),
      const Size(390, 844),
      const Size(1024, 1024),
      const Size(1440, 900),
    ]) {
      testWidgets('setup fits $size $locale and validates before creating', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final gateway = FakeSetup();
        await tester.pumpWidget(setupApp(gateway, locale: locale));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.byIcon(Icons.menu), findsNothing);
        expect(find.byType(TextFormField), findsNWidgets(4));
        final create = find.byType(FilledButton);
        await tester.ensureVisible(create);
        await tester.tap(create);
        await tester.pumpAndSettle();
        expect(gateway.requests, 0);
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.byType(TextButton));
        await tester.tap(find.byType(TextButton));
        await tester.pumpAndSettle();
        expect(find.byType(TextFormField), findsNWidgets(2));
        expect(tester.takeException(), isNull);
      });
    }
  }
  testWidgets(
    'setup retains values after failure and prevents duplicate submits',
    (tester) async {
      final gateway = FakeSetup()..fail = true;
      var completed = false;
      await tester.pumpWidget(
        setupApp(
          gateway,
          ready: (_) async {
            completed = true;
          },
        ),
      );
      await tester.pumpAndSettle();
      for (final entry in [
        'مدير تجريبي',
        'manager_test',
        'contact@example.invalid',
        'not-a-real-password',
      ].asMap().entries) {
        await tester.enterText(
          find.byType(TextFormField).at(entry.key),
          entry.value,
        );
      }
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pumpAndSettle();
      expect(gateway.requests, 1);
      expect(completed, isFalse);
      expect(
        tester
            .widget<TextFormField>(find.byType(TextFormField).at(0))
            .controller!
            .text,
        'مدير تجريبي',
      );
      gateway.fail = false;
      gateway.waiting = Completer<void>();
      await tester.ensureVisible(find.byType(FilledButton));
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(
        tester.widget<TextButton>(find.byType(TextButton)).onPressed,
        isNull,
      );
      gateway.waiting!.complete();
      await tester.pumpAndSettle();
      expect(gateway.requests, 2);
      expect(completed, isTrue);
    },
  );
}
