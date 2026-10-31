import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/utils/center_clock.dart';
import 'package:newcare/core/utils/operational_day.dart';
import 'package:newcare/features/cases/data/models/case_payment.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/drawer/data/models/drawer_handover.dart';
import 'package:newcare/features/drawer/data/models/operational_day_summary.dart';
import 'package:newcare/features/laboratory/data/models/lab_payment.dart';
import 'package:newcare/features/workspace/data/models/workspace_snapshot.dart';
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(() {
    // initialize timezone
    CenterClock.now();
  });

  test('07:59:59 Cairo belongs to previous day and 08:00:00 belongs to new day', () {
    final loc = CenterClock.location;

    // 2026-10-31 07:59:59 Cairo
    final before8 = tz.TZDateTime(loc, 2026, 10, 31, 7, 59, 59);
    final dayBefore8 = OperationalDay.containing(before8);

    expect(dayBefore8.start, tz.TZDateTime(loc, 2026, 10, 30, 8, 0, 0));
    expect(dayBefore8.end, tz.TZDateTime(loc, 2026, 10, 31, 8, 0, 0));
    expect(dayBefore8.contains(before8), isTrue);

    // 2026-10-31 08:00:00 Cairo
    final at8 = tz.TZDateTime(loc, 2026, 10, 31, 8, 0, 0);
    final dayAt8 = OperationalDay.containing(at8);

    expect(dayAt8.start, tz.TZDateTime(loc, 2026, 10, 31, 8, 0, 0));
    expect(dayAt8.end, tz.TZDateTime(loc, 2026, 11, 1, 8, 0, 0));
    expect(dayAt8.contains(at8), isTrue);
    expect(dayBefore8.contains(at8), isFalse);
  });

  test('operational day boundary handles DST transitions without crashing', () {
    final loc = CenterClock.location;
    // Egypt DST transition in late April or late October
    final dstDate = tz.TZDateTime(loc, 2026, 4, 24, 10, 0, 0);
    final day = OperationalDay.containing(dstDate);

    expect(day.start.hour, 8);
    expect(day.end.hour, 8);
    expect(day.contains(dstDate), isTrue);
  });

  test('day summary scopes daily counter without touching custody physical expected cash', () {
    final loc = CenterClock.location;
    final day = OperationalDay.containing(tz.TZDateTime(loc, 2026, 10, 31, 12, 0, 0));

    // Carried over custody: 5000 EGP opening
    final snapshot = WorkspaceSnapshot(
      openingMinor: 500000,
      cases: [
        // Case created yesterday before 8:00
        CaseRecord(
          id: 'c-old',
          shiftId: '',
          staffId: 'nurse-1',
          title: 'Old case',
          procedureId: 'p1',
          supplies: const [],
          location: CaseLocation.inside,
          amountMinor: 20000,
          payment: PaymentMethod.cash,
          createdAt: tz.TZDateTime(loc, 2026, 10, 30, 15, 0, 0),
        ),
        // Case created today inside day
        CaseRecord(
          id: 'c-today',
          shiftId: '',
          staffId: 'nurse-1',
          title: 'Today case',
          procedureId: 'p1',
          supplies: const [],
          location: CaseLocation.inside,
          amountMinor: 30000,
          payment: PaymentMethod.cash,
          createdAt: tz.TZDateTime(loc, 2026, 10, 31, 10, 0, 0),
        ),
        // Wallet case today
        CaseRecord(
          id: 'c-wallet',
          shiftId: '',
          staffId: 'nurse-1',
          title: 'Wallet case',
          procedureId: 'p1',
          supplies: const [],
          location: CaseLocation.inside,
          amountMinor: 15000,
          payment: PaymentMethod.wallet,
          createdAt: tz.TZDateTime(loc, 2026, 10, 31, 11, 0, 0),
        ),
      ],
      payments: [
        // Later installment for old case, paid today in cash
        CasePayment(
          id: 'p-today',
          caseId: 'c-old',
          amountMinor: 10000,
          method: PaymentMethod.cash,
          staffId: 'nurse-1',
          paidAt: tz.TZDateTime(loc, 2026, 10, 31, 13, 0, 0),
        ),
      ],
      labPayments: [
        // Lab payment today in cash
        LabPayment(
          id: 'lp-today',
          orderId: 'o1',
          amountMinor: 8000,
          method: PaymentMethod.cash,
          staffId: 'nurse-1',
          createdAt: tz.TZDateTime(loc, 2026, 10, 31, 14, 0, 0),
        ),
      ],
      movements: [
        // Expense today
        CashMovement(
          id: 'm-today',
          shiftId: '',
          staffId: 'nurse-1',
          reason: 'Supplies expense',
          amountMinor: 5000,
          kind: CashKind.expense,
          createdAt: tz.TZDateTime(loc, 2026, 10, 31, 16, 0, 0),
        ),
      ],
      handovers: [
        // Handover today
        DrawerHandover(
          id: 'h-today',
          fromStaffId: 'nurse-1',
          toStaffId: 'nurse-2',
          countedMinor: 563000,
          expectedMinor: 563000,
          at: tz.TZDateTime(loc, 2026, 10, 31, 17, 0, 0),
        ),
      ],
    );

    final summary = OperationalDaySummary.forDay(snapshot, day);

    // Today cash in: 30000 (c-today) + 10000 (p-today) + 8000 (lp-today) = 48000
    expect(summary.cashInMinor, 48000);
    // Today cash out: 5000 (expense)
    expect(summary.cashOutMinor, 5000);
    // Net cash: 48000 - 5000 = 43000
    expect(summary.netCashMinor, 43000);
    // Wallet today: 15000 (c-wallet)
    expect(summary.walletMinor, 15000);
    // Handovers list has 1 item
    expect(summary.handovers, hasLength(1));

    // Full physical expected cash retains all custody:
    // opening (500000) + c-old (20000) + c-today (30000) + p-today (10000) + lp-today (8000) - expense (5000) = 563000
    expect(summary.physicalExpectedCash, 563000);
    expect(snapshot.drawerBalance, 563000);
  });
}
