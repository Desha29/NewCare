import '../../../../core/utils/operational_day.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../drawer/data/models/cash_movement.dart';
import '../../../drawer/data/models/drawer_handover.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';

class OperationalDaySummary {
  const OperationalDaySummary({
    required this.day,
    required this.cashInMinor,
    required this.cashOutMinor,
    required this.netCashMinor,
    required this.walletMinor,
    required this.physicalExpectedCash,
    required this.handovers,
  });

  final OperationalDay day;
  final int cashInMinor;
  final int cashOutMinor;
  final int netCashMinor;
  final int walletMinor;
  final int physicalExpectedCash;
  final List<DrawerHandover> handovers;

  factory OperationalDaySummary.forDay(
    WorkspaceSnapshot snapshot,
    OperationalDay day,
  ) {
    int cashIn = 0;
    int wallet = 0;

    for (final c in snapshot.cases) {
      if (day.contains(c.createdAt) && c.amountMinor > 0) {
        if (c.payment == PaymentMethod.cash) {
          cashIn += c.amountMinor;
        } else if (c.payment == PaymentMethod.wallet) {
          wallet += c.amountMinor;
        }
      }
    }

    for (final p in snapshot.payments) {
      if (day.contains(p.paidAt) && p.amountMinor > 0) {
        if (p.method == PaymentMethod.cash) {
          cashIn += p.amountMinor;
        } else if (p.method == PaymentMethod.wallet) {
          wallet += p.amountMinor;
        }
      }
    }

    for (final lp in snapshot.labPayments) {
      if (day.contains(lp.createdAt) && lp.amountMinor > 0) {
        if (lp.method == PaymentMethod.cash) {
          cashIn += lp.amountMinor;
        } else if (lp.method == PaymentMethod.wallet) {
          wallet += lp.amountMinor;
        }
      }
    }

    int cashOut = 0;
    for (final m in snapshot.movements) {
      if (day.contains(m.createdAt)) {
        if (m.kind == CashKind.income) {
          cashIn += m.amountMinor;
        } else {
          cashOut += m.amountMinor;
        }
      }
    }

    final dayHandovers =
        snapshot.handovers.where((h) => day.contains(h.at)).toList();

    return OperationalDaySummary(
      day: day,
      cashInMinor: cashIn,
      cashOutMinor: cashOut,
      netCashMinor: cashIn - cashOut,
      walletMinor: wallet,
      physicalExpectedCash: snapshot.drawerBalance,
      handovers: List.unmodifiable(dayHandovers),
    );
  }
}
