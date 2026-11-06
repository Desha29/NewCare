import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test/cloud_setup_screen_test.dart' show FakeSetup, setupApp;

void main() {
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
  for (final example in [
    ('desktop', const Size(1440, 900)),
    ('mobile', const Size(390, 844)),
    ('square', const Size(1024, 1024)),
  ]) {
    testWidgets('capture setup ${example.$1}', (tester) async {
      tester.view.physicalSize = example.$2;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(key: boundary, child: setupApp(FakeSetup())),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => precacheImage(
          const AssetImage('assets/branding/newcare-icon.png'),
          tester.element(find.byType(Scaffold).first),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await expectLater(
        find.byKey(boundary),
        matchesGoldenFile(
          Uri.file(
            'C:/Users/Desha/Documents/Codex/2026-10-28/newcare-nursing-center-last-updatedoct-28/outputs/newcare-startup-${example.$1}.png',
          ),
        ),
      );
    });
  }
}
