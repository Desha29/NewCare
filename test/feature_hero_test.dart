import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_detail_page.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets(
    'feature details fly from unique sources and preserve the source page',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore();
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
      app.unlock('newcare-demo');
      for (final page in [
        AppPage.shiftCases,
        AppPage.nursing,
        AppPage.catalogue,
        AppPage.transactions,
      ]) {
        app.navigate(page);
        await tester.pumpAndSettle();
        final title = find.byType(NcHeroTitle).first;
        await tester.ensureVisible(title);
        await tester.tap(title);
        await tester.pumpAndSettle();
        expect(find.byType(NcDetailPage), findsOneWidget, reason: page.name);
        expect(tester.takeException(), isNull, reason: page.name);
        await tester.tap(find.byType(BackButton).first);
        await tester.pumpAndSettle();
        expect(app.state.page, page);
        expect(tester.takeException(), isNull, reason: page.name);
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
