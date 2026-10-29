import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/management/presentation/widgets/navigation_labels_editor.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  test(
    'password replacement persists and old password stops unlocking',
    () async {
      final store = MemoryStringStore();
      final app = AppCubit(store);
      expect(
        app.unlock('newcare-demo'),
        isFalse,
        reason: 'Settings must load first',
      );
      await app.loadLocale();
      expect(
        await app.changePassword('newcare-demo', 'next-password'),
        'wrongPassword',
      );
      expect(app.unlock('newcare-demo'), isTrue);
      expect(
        await app.changePassword('incorrect', 'next-password'),
        'wrongPassword',
      );
      expect(
        await app.changePassword('newcare-demo', 'short'),
        'passwordTooShort',
      );
      expect(await app.changePassword('newcare-demo', 'next-password'), isNull);
      final stored = await store.read('newcare.managerPassword');
      expect(stored, isNot(contains('next-password')));
      app.lock();
      expect(app.unlock('newcare-demo'), isFalse);
      expect(app.unlock('next-password'), isTrue);
      await app.close();
      final restored = AppCubit(store);
      await restored.loadLocale();
      expect(restored.unlock('newcare-demo'), isFalse);
      expect(restored.unlock('next-password'), isTrue);
      await restored.close();
    },
  );

  test(
    'navigation labels are manager-only, persisted and language-specific',
    () async {
      final store = MemoryStringStore();
      final app = AppCubit(store);
      await app.loadLocale();
      await expectLater(
        app.saveNavigationLabels({AppPage.overview: 'ملخص المركز'}),
        throwsStateError,
      );
      app.unlock('newcare-demo');
      await app.saveNavigationLabels({AppPage.overview: 'ملخص المركز'});
      await app.toggleLocale();
      expect(app.navigationLabel(AppPage.overview), isNull);
      await app.saveNavigationLabels({AppPage.overview: 'Center summary'});
      await app.close();
      final restored = AppCubit(store);
      await restored.loadLocale();
      expect(restored.navigationLabel(AppPage.overview), 'Center summary');
      await restored.toggleLocale();
      expect(restored.navigationLabel(AppPage.overview), 'ملخص المركز');
      restored.unlock('newcare-demo');
      await restored.saveNavigationLabels({AppPage.overview: ''});
      expect(restored.navigationLabel(AppPage.overview), isNull);
      await restored.close();
    },
  );

  testWidgets('edited section name updates both sidebar and header', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = MemoryStringStore(),
        repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    await tester.pumpWidget(NewCareApp(repository: repo, store: store));
    await tester.pumpAndSettle();
    final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
    app.unlock('newcare-demo');
    app.navigate(AppPage.permissions);
    await tester.pumpAndSettle();
    final editor = find.byType(NavigationLabelsEditor);
    final input = find
        .descendant(of: editor, matching: find.byType(TextFormField))
        .at(3);
    await tester.ensureVisible(input);
    await tester.enterText(input, 'ملخص المركز');
    final save = find.descendant(of: editor, matching: find.text('حفظ'));
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    app.navigate(AppPage.overview);
    await tester.pumpAndSettle();
    expect(find.text('ملخص المركز'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
}
