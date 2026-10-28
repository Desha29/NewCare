import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/features/transactions/data/models/transaction_entry.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/workspace/data/models/workspace_snapshot.dart';
import 'package:newcare/core/utils/center_clock.dart';

void main() {
  test(
    'ledger combines payments once, separates wallet and signs outgoings',
    () {
      final at = CenterClock.at(DateTime(2026, 10, 28), 12, 0);
      final data = WorkspaceSnapshot(
        cases: [
          for (final payment in PaymentMethod.values)
            CaseRecord(
              id: payment.name,
              shiftId: 's',
              staffId: 'n',
              title: 'Payment',
              procedureId: 'p',
              supplies: [],
              amountMinor: 10000,
              payment: payment,
              location: CaseLocation.inside,
              createdAt: at,
            ),
        ],
        movements: [
          for (final kind in CashKind.values)
            CashMovement(
              id: kind.name,
              shiftId: 's',
              staffId: 'n',
              kind: kind,
              amountMinor: 1000,
              reason: 'Movement',
              createdAt: at,
            ),
        ],
      );
      final rows = TransactionEntry.forRange(
        data,
        DateTime(2026, 10, 28),
        DateTime(2026, 10, 28),
      );
      expect(rows.length, 6);
      final totals = TransactionTotals(rows);
      expect(totals.cashIn, 11000);
      expect(totals.cashOut, 3000);
      expect(totals.walletIn, 10000);
      expect(totals.netCash, 8000);
      expect(
        rows.singleWhere((r) => r.kind == TransactionKind.advance).signedMinor,
        -1000,
      );
      expect(
        TransactionEntry.forRange(
          data,
          DateTime(2026, 10, 29),
          DateTime(2026, 10, 29),
        ),
        isEmpty,
      );
    },
  );
}
