import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/widgets/workspace_header.dart';
import 'package:newcare/core/localization/localization_extensions.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/l10n/app_localizations.dart';

import 'cloud_sync_service_test.dart' show JournalStore, FakeCloud;

void main() {
  for (final width in [320.0, 1024.0]) {
    testWidgets('header keeps online/offline text visible and live at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = JournalStore();
      final repo = LocalWorkspaceRepository(store, seedDemo: false);
      await repo.initialize();
      final gateway = FakeCloud()..offline = true;
      final sync = CloudSyncService(
        gateway: gateway,
        centerId: 'c',
        store: store,
        repository: repo,
        keyStore: store,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WorkspaceHeader(onMenu: () {}, syncService: sync),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(WorkspaceHeader));
      expect(find.text(context.t('syncOffline')), findsOneWidget);
      gateway.offline = false;
      await sync.sync();
      await tester.pumpAndSettle();
      expect(find.text(context.t('syncOnline')), findsOneWidget);
      gateway.offline = true;
      await sync.sync();
      await tester.pumpAndSettle();
      expect(find.text(context.t('syncOffline')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      sync.dispose();
      await repo.dispose();
    });
  }
}
