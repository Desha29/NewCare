import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/core/widgets/nc_field.dart';
import 'package:newcare/features/drawer/presentation/widgets/drawer_handover_panel.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';
import 'package:newcare/features/staff/data/models/nursing_member.dart';

void main() {
  testWidgets('a single available person cannot receive their own drawer', (
    tester,
  ) async {
    final store = MemoryStringStore();
    await store.write('newcare.locale', 'en');
    final repo = LocalWorkspaceRepository(store, seedDemo: false);
    await repo.initialize();
    await repo.addStaff(const NursingMember(id: 'only', name: 'محمود'));
    await repo.saveSettings(setupDone: true);
    await tester.pumpWidget(NewCareApp(repository: repo, store: store));
    await tester.pumpAndSettle();
    DrawerHandoverPanel.open(tester.element(find.byType(Scaffold).first));
    await tester.pumpAndSettle();
    final selects = find.descendant(
      of: find.byType(DrawerHandoverPanel),
      matching: find.byType(NcSelect<String>),
    );
    tester.widgetList<NcSelect<String>>(selects).first.onChanged('only');
    await tester.pumpAndSettle();
    expect(tester.widgetList<NcSelect<String>>(selects).last.items, isEmpty);
    expect(
      find.text(
        'Another person is needed to receive the drawer. The sender cannot receive it from themselves.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Confirm drawer handover'),
          )
          .onPressed,
      isNull,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await repo.dispose();
  });
  testWidgets(
    'receiver excludes sender and clears when sender changes to the chosen receiver',
    (tester) async {
      final store = MemoryStringStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();
      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();
      DrawerHandoverPanel.open(tester.element(find.byType(Scaffold).first));
      await tester.pumpAndSettle();
      Finder selects() => find.descendant(
        of: find.byType(DrawerHandoverPanel),
        matching: find.byType(NcSelect<String>),
      );
      var fields = tester.widgetList<NcSelect<String>>(selects()).toList();
      fields.first.onChanged('n1');
      await tester.pumpAndSettle();
      fields = tester.widgetList<NcSelect<String>>(selects()).toList();
      expect(fields.last.items.map((i) => i.value), isNot(contains('n1')));
      fields.last.onChanged('n2');
      await tester.pumpAndSettle();
      fields = tester.widgetList<NcSelect<String>>(selects()).toList();
      fields.first.onChanged('n2');
      await tester.pumpAndSettle();
      fields = tester.widgetList<NcSelect<String>>(selects()).toList();
      expect(fields.last.value, isNull);
      expect(fields.last.items.map((i) => i.value), isNot(contains('n2')));
      final confirm = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Confirm drawer handover'),
      );
      expect(confirm.onPressed, isNull);
      expect(repo.current.handovers, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await repo.dispose();
    },
  );
}
