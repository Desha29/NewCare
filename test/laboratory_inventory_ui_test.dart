import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/app/cubit/app_cubit.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/app/newcare_app.dart';
import 'package:newcare/core/storage/string_store.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/inventory/data/models/case_stock_usage.dart';
import 'package:newcare/features/inventory/data/models/stock_item.dart';
import 'package:newcare/features/laboratory/data/models/lab_order.dart';
import 'package:newcare/features/laboratory/data/models/lab_order_item.dart';
import 'package:newcare/features/laboratory/data/models/lab_test.dart';
import 'package:newcare/features/laboratory/presentation/screens/laboratory_screen.dart';
import 'package:newcare/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:newcare/features/workspace/data/repositories/local_workspace_repository.dart';

class _FailingStore extends MemoryStringStore {
  bool fail = false;
  @override
  Future<void> write(String key, String value) async {
    if (fail) throw StateError('Storage unavailable');
    await super.write(key, value);
  }
}

void main() {
  testWidgets(
    'inventory page is manager-guarded and allows manager stock management',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = _FailingStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();

      await repo.saveStockItem(
        const StockItem(id: 'stock-1', name: 'Syringe 5ml', quantity: 50),
      );

      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();

      final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
      app.navigate(AppPage.inventory);
      await tester.pumpAndSettle();

      // Guarded: redirected to login
      expect(app.state.page, AppPage.login);

      // Unlock as manager
      app.unlock('newcare-demo');
      await tester.pumpAndSettle();

      expect(find.byType(InventoryScreen), findsOneWidget);
      expect(find.text('Syringe 5ml'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);

      expect(find.byTooltip('Archive'), findsNothing);
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await tester.pumpAndSettle();
      expect(repo.current.stockItems, hasLength(1));
      store.fail = true;
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(repo.current.stockItems, hasLength(1));
      store.fail = false;
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();
      expect(repo.current.stockItems, isEmpty);
      expect(find.text('Syringe 5ml'), findsNothing);

      await repo.dispose();
    },
  );

  testWidgets(
    'nurse can access laboratory orders and see result status independent of payment',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = MemoryStringStore();
      await store.write('newcare.locale', 'en');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();

      await repo.saveLabTest(
        const LabTest(id: 't1', name: 'CBC Blood Test', priceMinor: 15000),
      );

      final order = LabOrder(
        id: 'order-1',
        patientName: 'John Doe',
        patientAge: 35,
        ageUnit: 'year',
        staffId: repo.current.staff.first.id,
        createdAt: DateTime.now(),
        items: const [
          LabOrderItem(testId: 't1', name: 'CBC Blood Test', priceMinor: 15000),
        ],
        received: false,
      );
      await repo.addLabOrder(order);

      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();

      final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
      // Nurse access (no unlock needed)
      app.navigate(AppPage.laboratory);
      await tester.pumpAndSettle();

      expect(find.byType(LaboratoryScreen), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('CBC Blood Test'), findsOneWidget);

      // Unpaid, pending result
      expect(find.text('Pending result'), findsOneWidget);

      // Mark result delivered without payment
      await repo.setLabReceived(
        'order-1',
        repo.current.staff.first.id,
        received: true,
      );
      await tester.pumpAndSettle();

      expect(find.text('Result delivered'), findsOneWidget);
      // Still unpaid
      expect(repo.current.remainingForLab(order), 15000);

      await repo.dispose();
    },
  );

  testWidgets(
    'case form records stock usage and details screen displays used supplies',
    (tester) async {
      tester.view.physicalSize = const Size(1024, 1024);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final store = MemoryStringStore();
      await store.write('newcare.locale', 'ar');
      final repo = LocalWorkspaceRepository(store);
      await repo.initialize();

      await repo.saveStockItem(
        const StockItem(id: 's-gauze', name: 'شاش معقم', quantity: 100),
      );

      final procId = repo.current.procedures.first.id;
      final staffId = repo.current.staff.first.id;

      // Create a case record with stock usage
      final caseRecord = CaseRecord(
        id: 'c-stock-test',
        shiftId: 'shift-1',
        staffId: staffId,
        title: 'خياطة جرح',
        procedureId: procId,
        supplies: const [],
        amountMinor: 20000,
        payment: PaymentMethod.cash,
        location: CaseLocation.inside,
        createdAt: DateTime.now(),
        stockUsages: const [
          CaseStockUsage(stockItemId: 's-gauze', name: 'شاش معقم', quantity: 3),
        ],
      );
      await repo.addCase(caseRecord);

      await tester.pumpWidget(NewCareApp(repository: repo, store: store));
      await tester.pumpAndSettle();

      final app = tester.element(find.byType(Scaffold).first).read<AppCubit>();
      app.selectCase('c-stock-test');
      app.navigate(AppPage.caseDetails);
      await tester.pumpAndSettle();

      // Verify used supplies in case details
      expect(find.text('شاش معقم × 3'), findsOneWidget);

      // Verify used supplies in case book table
      app.navigate(AppPage.insideCaseBook);
      await tester.pumpAndSettle();
      expect(find.text('شاش معقم × 3'), findsOneWidget);

      // Verify used supplies in manager case history (cards and table)
      app.unlock('newcare-demo');
      app.navigate(AppPage.caseLog);
      await tester.pumpAndSettle();

      // In card grid
      expect(find.text('شاش معقم × 3'), findsOneWidget);

      // Switch to table view
      await tester.tap(find.byIcon(Icons.table_rows_outlined));
      await tester.pumpAndSettle();
      expect(find.text('شاش معقم × 3'), findsOneWidget);

      await repo.dispose();
    },
  );
}
