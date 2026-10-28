import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/utils/formatters.dart';
import 'package:newcare/core/widgets/nc_metric_grid.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  Future<(LocalWorkspaceRepository, AppCubit)> boot(
    WidgetTester tester, {
    bool closed = false,
  }) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryStringStore();
    await store.write('newcare.locale', 'en');
    final repo = LocalWorkspaceRepository(store);
    await repo.initialize();
    if (closed) await repo.endShift('');
    await tester.pumpWidget(NewCareApp(repository: repo, store: store));
    await tester.pumpAndSettle();
    final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
    app.unlock('newcare-demo');
    app.navigate(AppPage.overview);
    await tester.pumpAndSettle();
    return (repo, app);
  }

  testWidgets('changing custom date range recalculates dashboard metrics', (
    tester,
  ) async {
    final (repo, app) = await boot(tester);
    expect(
      tester.widget<NcMetricGrid>(find.byType(NcMetricGrid)).items.first.value,
      contains('2,720'),
    );
    app.setRange(
      DateTimeRange(start: DateTime(2000, 1, 1), end: DateTime(2000, 1, 2)),
    );
    await tester.pumpAndSettle();
    expect(
      tester.widget<NcMetricGrid>(find.byType(NcMetricGrid)).items.first.value,
      contains('0'),
    );
    expect(
      tester.widget<NcMetricGrid>(find.byType(NcMetricGrid)).items.first.value,
      isNot(contains('2,720')),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
  testWidgets('closed shift keeps its final expected drawer cash', (
    tester,
  ) async {
    final (repo, _) = await boot(tester, closed: true);
    expect(
      tester.widget<NcMetricGrid>(find.byType(NcMetricGrid)).items.last.value,
      contains('4,150'),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
  testWidgets('timestamp formatter uses Cairo even for UTC records', (
    tester,
  ) async {
    final (repo, _) = await boot(tester);
    final context = tester.element(find.byType(NcMetricGrid));
    expect(context.time(DateTime.utc(2026, 10, 27, 22, 30)), contains('1:30'));
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
}
