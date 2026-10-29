import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/presentation/widgets/case_form_fields.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  testWidgets('desktop sidebar toggles without losing an unfinished case', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1440, 960);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    await tester.pumpWidget(
      NewCareApp(repository: repo, store: MemoryStringStore()),
    );
    await tester.pumpAndSettle();
    final fields = tester
        .widgetList<CaseFormFields>(find.byType(CaseFormFields))
        .firstWhere((f) => f.outside);
    fields.address.text = 'عنوان قبل إغلاق القائمة';
    final before = tester.getSize(find.byKey(const ValueKey('workspace-main'))).width;
    await tester.tap(find.byTooltip('إخفاء القائمة الجانبية'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byKey(const ValueKey('workspace-main'))).width,
      greaterThan(before),
    );
    await tester.tap(find.byTooltip('إظهار القائمة الجانبية'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<CaseFormFields>(find.byType(CaseFormFields))
          .firstWhere((f) => f.outside)
          .address
          .text,
      'عنوان قبل إغلاق القائمة',
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });

  testWidgets('phone navigation can be opened and explicitly closed', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final repo = LocalWorkspaceRepository(MemoryStringStore());
    await repo.initialize();
    await tester.pumpWidget(
      NewCareApp(repository: repo, store: MemoryStringStore()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('فتح القائمة'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold).first).isDrawerOpen,
      isTrue,
    );
    await tester.tap(find.byTooltip('إغلاق القائمة'));
    await tester.pumpAndSettle();
    expect(
      tester.state<ScaffoldState>(find.byType(Scaffold).first).isDrawerOpen,
      isFalse,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
}

