import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/features/sync/data/repositories/cloud_sync_service.dart';
import 'package:newcare/features/sync/presentation/cubit/diagnostics_cubit.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

import 'cloud_sync_service_test.dart' show FakeCloud, JournalStore;

void main() {
  testWidgets('diagnostics opens with an attached cloud sync service', (
    tester,
  ) async {
    final store = JournalStore();
    final repository = LocalWorkspaceRepository(store);
    await repository.initialize();
    final sync = CloudSyncService(
      gateway: FakeCloud()..offline = true,
      centerId: 'c',
      store: store,
      repository: repository,
      keyStore: store,
    );
    await tester.pumpWidget(
      NewCareApp(repository: repository, store: store, syncService: sync),
    );
    await tester.pumpAndSettle();

    final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
    expect(app.unlock('newcare-demo'), isTrue);
    app.navigate(AppPage.developerDiagnostics);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final diagnostics = tester
        .element(find.byType(BlocBuilder<DiagnosticsCubit, DiagnosticsState>))
        .read<DiagnosticsCubit>();
    expect(diagnostics.sync, same(sync));
    await tester.pumpWidget(const SizedBox.shrink());
    sync.dispose();
    await repository.dispose();
  });
}
