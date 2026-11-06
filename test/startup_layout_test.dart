import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/widgets/nc_auth_layout.dart';
import 'package:newcare/l10n/app_localizations.dart';

void main() {
  testWidgets('first-run auth layout works before workspace providers exist', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: NcAuthLayout(child: Text('Setup')),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.byIcon(Icons.menu), findsNothing);
  });
}
