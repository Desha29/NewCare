import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/l10n/app_localizations.dart';
import 'package:newcare/features/launch/presentation/screens/splash_screen.dart';

void main() {
  Widget root(Widget child) => MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: child,
  );
  testWidgets('splash fades in and completes exactly once', (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      root(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: false),
          child: SplashScreen(onCompleted: () => completed++),
        ),
      ),
    );
    expect(
      tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byType(SplashScreen),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value,
      0,
    );
    await tester.pump(const Duration(milliseconds: 600));
    expect(
      tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byType(SplashScreen),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value,
      greaterThan(0),
    );
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 650));
    expect(completed, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(completed, 1);
  });
  testWidgets('splash respects reduced motion', (tester) async {
    var completed = 0;
    await tester.pumpWidget(
      root(
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SplashScreen(onCompleted: () => completed++),
        ),
      ),
    );
    await tester.pump();
    expect(completed, 1);
    expect(
      tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: find.byType(SplashScreen),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value,
      1,
    );
  });
}
