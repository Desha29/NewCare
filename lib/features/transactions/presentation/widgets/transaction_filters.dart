import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../cases/data/models/case_record.dart';
import '../../../staff/data/models/nursing_member.dart';
import '../../data/models/transaction_entry.dart';

class TransactionFilters extends StatelessWidget {
  const TransactionFilters({
    super.key,
    required this.staff,
    required this.kind,
    required this.payment,
    required this.member,
    required this.onQuery,
    required this.onKind,
    required this.onPayment,
    required this.onMember,
  });
  final List<NursingMember> staff;
  final String kind, payment, member;
  final ValueChanged<String> onQuery, onKind, onPayment, onMember;
  @override
  Widget build(BuildContext context) => NcCard(
    children: [
      TextField(
        onChanged: onQuery,
        decoration: InputDecoration(
          labelText: context.t('searchTransactions'),
          prefixIcon: const Icon(Icons.search, size: 20),
        ),
      ),
      LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth < 600 ? c.maxWidth : (c.maxWidth - 24) / 3;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              SizedBox(
                width: width,
                child: NcSelect<String>(
                  label: context.t('movementKind'),
                  value: kind,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(context.t('allTransactions')),
                    ),
                    for (final k in TransactionEntry.categoryKeys)
                      DropdownMenuItem(value: k, child: Text(context.t(k))),
                  ],
                  onChanged: (v) => onKind(v!),
                ),
              ),
              SizedBox(
                width: width,
                child: NcSelect<String>(
                  label: context.t('paymentMethod'),
                  value: payment,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(context.t('allPayments')),
                    ),
                    for (final p in PaymentMethod.values)
                      DropdownMenuItem(
                        value: p.name,
                        child: Text(context.t(p.name)),
                      ),
                  ],
                  onChanged: (v) => onPayment(v!),
                ),
              ),
              SizedBox(
                width: width,
                child: NcSelect<String>(
                  label: context.t('nursing'),
                  value: member,
                  items: [
                    DropdownMenuItem(
                      value: 'all',
                      child: Text(context.t('allNursing')),
                    ),
                    for (final n in staff)
                      DropdownMenuItem(
                        value: n.id,
                        child: Text(
                          '${n.name}${n.isManager ? ' · ${context.t('manager')}' : ''}',
                        ),
                      ),
                  ],
                  onChanged: (v) => onMember(v!),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}
