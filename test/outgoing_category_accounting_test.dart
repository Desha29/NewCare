import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/utils/center_clock.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/workspace/data/models/workspace_snapshot.dart';
import 'package:newcare/features/transactions/data/models/transaction_entry.dart';
import 'package:newcare/features/analytics/data/models/report_summary.dart';

void main() {
  test(
    'center/person grouping preserves legacy advances, payroll and cash totals',
    () {
      final day = DateTime(2026, 10, 29),
          at = CenterClock.at(DateTime(2026, 10, 29), 12, 0);
      CashMovement movement(
        String id,
        CashKind kind,
        int amount, {
        String recipient = '',
        String reason = 'بيان',
      }) => CashMovement(
        id: id,
        shiftId: '',
        staffId: 'n1',
        kind: kind,
        amountMinor: amount,
        recipient: recipient,
        reason: reason,
        createdAt: at,
      );
      final data = WorkspaceSnapshot(
        movements: [
          movement('center', CashKind.expense, 1000),
          movement('nursing', CashKind.advance, 2000),
          movement(
            'legacy',
            CashKind.externalAdvance,
            3000,
            recipient: 'أحمد',
            reason: 'سلفة لشخص خارجي',
          ),
          movement('award', CashKind.award, 500),
          movement('person', CashKind.expense, 700, recipient: 'شخص آخر'),
          movement('income', CashKind.income, 10000),
        ],
      );
      final before = data.toJson().toString();
      final rows = TransactionEntry.forRange(data, day, day),
          totals = TransactionTotals(TransactionEntry.forRange(data, day, day));
      expect(totals.amountForCategory('centerExpense'), 1000);
      expect(totals.amountForCategory('personOutgoings'), 6200);
      expect(totals.cashOut, 7200);
      expect(totals.netCash, 2800);
      expect(data.drawerBalance, 2800);
      final legacy = rows.firstWhere((r) => r.id == 'legacy');
      expect(legacy.categoryKey, 'personOutgoings');
      expect(legacy.purposeKey, 'advance');
      expect(legacy.descriptionKey, 'advance');
      expect(ReportSummary.forRange(data, day, day).advanceMinor, 2000);
      expect(data.toJson().toString(), before);
    },
  );
}
