import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../localization/localization_extensions.dart';
import '../widgets/nc_card.dart';

/// Development controls are reached only when the debug binding is active.
class DevicePreviewPanel extends StatelessWidget {
  const DevicePreviewPanel({super.key, required this.controller});
  final DevicePreviewController controller;

  static Future<void> open(BuildContext context) {
    final controller = kDebugMode ? DevicePreview.maybeController : null;
    if (controller == null) return Future.value();
    return showDialog<void>(
      context: context,
      builder: (_) => DevicePreviewPanel(controller: controller),
    );
  }

  Future<void> apply(
    BuildContext context,
    Future<void> Function() change,
  ) async {
    final messenger = ScaffoldMessenger.of(context),
        message = context.t('previewFailed');
    Navigator.pop(context);
    try {
      await change();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final simulation = controller.simulation;
    final presets = [
      DevicePresets.iPhoneSe3,
      DevicePresets.iPhone16,
      DevicePresets.pixel9,
      DevicePresets.iPad10,
      DevicePresets.galaxyTabS11,
      DevicePresets.smallDesktopWindow,
      DevicePresets.largeDesktopWindow,
      DevicePreset(
        id: 'newcare-square',
        name: context.t('squareMonitor'),
        platform: TargetPlatform.windows,
        portraitSize: const Size(1024, 1024),
        devicePixelRatio: 1,
        kind: DeviceKind.desktop,
      ),
    ];
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: MediaQuery.sizeOf(context).height * .85,
        ),
        child: SingleChildScrollView(
          child: NcCard(
            title: context.t('devicePreview'),
            padding: 16,
            children: [
              Text(
                context.t('previewDebugOnly'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                context.t('previewDevice'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in presets)
                    ActionChip(
                      label: Text(preset.name),
                      onPressed: () => apply(
                        context,
                        () => controller.applyPreset(
                          preset,
                          resetOverrides: true,
                        ),
                      ),
                    ),
                ],
              ),
              DropdownButtonFormField<TargetPlatform>(
                initialValue:
                    simulation?.targetPlatform ?? defaultTargetPlatform,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: context.t('previewPlatform'),
                ),
                items: [
                  for (final platform in TargetPlatform.values)
                    DropdownMenuItem(
                      value: platform,
                      child: Text(context.t('platform${platform.name}')),
                    ),
                ],
                onChanged: (platform) {
                  if (platform != null) {
                    apply(
                      context,
                      () => controller.update(
                        (s) => s.copyWith(targetPlatform: platform),
                      ),
                    );
                  }
                },
              ),
              Text(
                context.t('previewTextScale'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final scale in [1.0, 1.3, 2.0])
                    ActionChip(
                      label: Text('${(scale * 100).round()}%'),
                      onPressed: () => apply(
                        context,
                        () => controller.update(
                          (s) => s.copyWith(textScaleFactor: scale),
                        ),
                      ),
                    ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.screen_rotation, size: 18),
                    label: Text(context.t('previewRotate')),
                    onPressed: () => apply(
                      context,
                      () => controller.setOrientation(
                        simulation?.orientation == Orientation.landscape
                            ? Orientation.portrait
                            : Orientation.landscape,
                      ),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.keyboard_outlined, size: 18),
                    label: Text(context.t('previewKeyboard')),
                    onPressed: () => apply(
                      context,
                      () => controller.update(
                        (s) => s.copyWith(
                          keyboardInset: (s.keyboardInset ?? 0) > 0 ? 0 : 300,
                        ),
                      ),
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.restart_alt, size: 18),
                    label: Text(context.t('previewReset')),
                    onPressed: () => apply(context, controller.reset),
                  ),
                ],
              ),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.t('close')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
