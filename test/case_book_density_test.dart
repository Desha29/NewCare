import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/widgets/workspace_header.dart';
import 'package:newcare/core/widgets/nc_logo.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

void main() {
  setUpAll(() async {
    final font = FontLoader('Cairo')
      ..addFont(rootBundle.load('assets/fonts/Cairo-Bold.ttf'));
    await font.load();
  });
  testWidgets(
    'case book keeps tables near the top and removes repeated header branding',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 960);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final store = MemoryStringStore(),
          repo = LocalWorkspaceRepository(MemoryStringStore());
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      tester
          .element(find.byType(Scaffold).first)
          .read<AppCubit>()
          .navigate(AppPage.shiftCases);
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(WorkspaceHeader),
          matching: find.byType(NcLogo),
        ),
        findsNothing,
      );
      expect(tester.getTopLeft(find.byType(DataTable).first).dy, lessThan(240));
      expect(
        tester.widget<DataTable>(find.byType(DataTable).first).headingRowHeight,
        38,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
