import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/debug/device_preview_panel.dart';
import 'package:newcare/l10n/app_localizations.dart';

class PreviewControllerFake implements DevicePreviewController {
  @override
  DeviceSimulation? simulation;
  DevicePreset? selected;
  @override
  Future<void> applyPreset(
    DevicePreset preset, {
    Orientation orientation = Orientation.portrait,
    bool resetOverrides = false,
  }) async {
    selected = preset;
  }

  @override
  Future<void> update(
    DeviceSimulation Function(DeviceSimulation) mutate,
  ) async {
    simulation = mutate(simulation ?? const DeviceSimulation());
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  for (final size in [const Size(320, 568), const Size(1024, 1024)]) {
    testWidgets(
      'debug preview controls select square preset and font scale at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final controller = PreviewControllerFake();
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  child: const Text('Open'),
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => DevicePreviewPanel(controller: controller),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        final square = find.text('شاشة مربعة 1024 × 1024');
        await tester.ensureVisible(square);
        await tester.tap(square);
        await tester.pumpAndSettle();
        expect(controller.selected?.portraitSize, const Size(1024, 1024));
        expect(find.byType(Dialog), findsNothing);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('200%'));
        await tester.tap(find.text('200%'));
        await tester.pumpAndSettle();
        expect(controller.simulation?.textScaleFactor, 2);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
