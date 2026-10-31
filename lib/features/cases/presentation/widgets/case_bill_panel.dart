import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/models/case_record.dart';
import 'case_form_fields.dart';

class CaseBillPanel extends StatelessWidget {
  const CaseBillPanel({
    super.key,
    required this.amount,
    required this.agreedTotal,
    required this.payment,
    required this.onPayment,
    this.previousReceipts = 0,
    this.compact = false,
  });
  final TextEditingController amount, agreedTotal;
  final PaymentMethod payment;
  final ValueChanged<PaymentMethod> onPayment;
  final int previousReceipts;
  final bool compact;
  int parse(String text) {
    try {
      return Money.parse(text);
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = NcField(
      label: context.t('agreedPrice'),
      controller: agreedTotal,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        try {
          return Money.parse(v ?? '') < previousReceipts
              ? context.t('invalidPaymentAmount')
              : null;
        } catch (_) {
          return context.t('invalidAmount');
        }
      },
    );
    final remaining = ListenableBuilder(
      listenable: Listenable.merge([amount, agreedTotal]),
      builder: (context, _) {
        final value =
            parse(agreedTotal.text) - parse(amount.text) - previousReceipts;
        return Container(
          padding: EdgeInsets.all(compact ? 10 : 12),
          decoration: BoxDecoration(
            color: value > 0 ? AppColors.warningBg : AppColors.tealLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.t('remainingAmount'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    context.money(value),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 18 : 20,
                      color: value > 0 ? AppColors.warning : AppColors.teal,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (compact) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    context.t('priceBreakdown'),
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (previousReceipts > 0)
                  Text(
                    '${context.t('laterPayments')}: ${context.money(previousReceipts)}',
                    style:
                        const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            PaymentFields(
              amount: amount,
              method: payment,
              onMethod: onPayment,
              compact: true,
              leadingField: total,
              amountLabel: context.t('paidNow'),
              amountValidator: (v) {
                try {
                  final paid = Money.parse(v ?? ''),
                      tot = Money.parse(agreedTotal.text);
                  return paid < 0 || paid + previousReceipts > tot
                      ? context.t('invalidPaymentAmount')
                      : null;
                } catch (_) {
                  return context.t('invalidAmount');
                }
              },
            ),
            const SizedBox(height: 8),
            remaining,
          ],
        ),
      );
    }

    final children = <Widget>[
      total,
      PaymentFields(
        amount: amount,
        method: payment,
        onMethod: onPayment,
        compact: false,
        amountLabel: context.t('paidNow'),
        amountValidator: (v) {
          try {
            final paid = Money.parse(v ?? ''),
                tot = Money.parse(agreedTotal.text);
            return paid < 0 || paid + previousReceipts > tot
                ? context.t('invalidPaymentAmount')
                : null;
          } catch (_) {
            return context.t('invalidAmount');
          }
        },
      ),
      if (previousReceipts > 0)
        Text(
          '${context.t('laterPayments')}: ${context.money(previousReceipts)}',
        ),
      remaining,
    ];
    return NcCard(
      title: context.t('priceBreakdown'),
      padding: 16,
      children: children,
    );
  }
}
