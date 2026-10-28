import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  for (final config in [
    (const Size(390, 844), 'ar'),
    (const Size(1024, 900), 'ar'),
    (const Size(1440, 960), 'ar'),
    (const Size(390, 844), 'en'),
    (const Size(1024, 1024), 'ar'),
    (const Size(1280, 1024), 'ar'),
    (const Size(768, 768), 'ar'),
  ]) {
    testWidgets('all routes fit ${config.$1} ${config.$2}', (tester) async {
      tester.view.physicalSize = config.$1;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      await store.write('newcare.locale', config.$2);
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(Scaffold).first);
      final app = context.read<AppCubit>();
      app.selectCase('case-demo-0');
      app.unlock('newcare-demo');
      for (final page in AppPage.values) {
        app.navigate(page);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: '${page.name} at ${config.$1} ${config.$2}',
        );
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    });
  }
}
