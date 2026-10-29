import 'dart:math' as math;

import 'case_location_heading.dart';
import 'case_price_dialog.dart';

import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/nc_adaptive_table.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_detail_page.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../data/models/case_record.dart';
import '../screens/case_details_screen.dart';
import 'case_payment_dialog.dart';

class CaseLedgerSection extends StatelessWidget {
  const CaseLedgerSection({
    super.key,
    required this.location,
    required this.records,
    required this.data,
  });
  final CaseLocation location;
  final List<CaseRecord> records;
  final WorkspaceSnapshot data;
  int get moneyStart => location == CaseLocation.outside ? 2 : 1;
  Color moneyColor(int column) => switch (column - moneyStart) {
    0 => AppColors.navy,
    1 => const Color(0xFF216B42),
    _ => const Color(0xFFB54708),
  };
  String label(CaseRecord c) =>
      '${c.id.length > 6 ? c.id.substring(c.id.length - 6) : c.id} · ${location == CaseLocation.outside ? c.address : c.title}';
  @override
  Widget build(BuildContext context) => NcCard(
    padding: 12,
    children: [
      Row(
        children: [
          Expanded(
            child: CaseLocationHeading(location: location, compact: true),
          ),
          const SizedBox(width: 10),
          Text('${records.length}'),
        ],
      ),
      LayoutBuilder(
        builder: (context, constraints) => NcAdaptiveTable(
          columnWidths: [
            if (location == CaseLocation.outside) ...[
              math.max(140.0, (constraints.maxWidth - 610) * .55),
              math.max(140.0, (constraints.maxWidth - 610) * .45),
            ] else
              math.max(140.0, constraints.maxWidth - 596),
            70,
            70,
            70,
            90,
            112,
          ],
          dense: true,
          alwaysTable: true,
          headers: [
            context.t(
              location == CaseLocation.outside ? 'address' : 'proceduresUsed',
            ),
            if (location == CaseLocation.outside) context.t('proceduresUsed'),
            context.t('agreedPrice'),
            context.t('paidTotal'),
            context.t('remainingAmount'),
            context.t('paymentMethod'),
            context.t('caseAddedAt'),
          ],
          rows: [
            for (final c in records)
              [
                label(c),
                if (location == CaseLocation.outside) c.title,
                context.money(c.invoiceMinor),
                context.money(data.paidFor(c)),
                context.money(data.remainingFor(c)),
                c.payment.name,
                '${context.shortDate(c.createdAt)}\n${context.time(c.createdAt)}',
              ],
          ],
          headerBuilder: (column, label) =>
              column < moneyStart || column > moneyStart + 2
              ? Text(label, softWrap: true)
              : Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: moneyColor(column).withValues(alpha: .09),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    softWrap: true,
                    style: TextStyle(
                      color: moneyColor(column),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                ),
          cellBuilder: (i, column, value) => column == 0
              ? NcHeroTitle(
                  tag: 'ledger-${location.name}-${records[i].id}',
                  title: value,
                )
              : column == moneyStart + 3
              ? NcStatusBadge(records[i].payment.name)
              : column == moneyStart + 4
              ? Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: column < moneyStart
                        ? null
                        : column == moneyStart + 2 &&
                              data.remainingFor(records[i]) == 0
                        ? AppColors.muted
                        : moneyColor(column),
                  ),
                ),
          emptyLabel: context.t('noCases'),
          onRowTap: (i) {
            final c = records[i];
            NcDetailPage.open(
              context,
              tag: 'ledger-${location.name}-${c.id}',
              title: label(c),
              child: CaseDetailsScreen(
                caseId: c.id,
                onBack: () => Navigator.pop(context),
              ),
            );
          },
          actions: (i) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: context.t('editCasePrice'),
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => CasePriceDialog.open(context, records[i]),
              ),
              if (data.remainingFor(records[i]) > 0)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: context.t('receivePayment'),
                  icon: const Icon(Icons.add_card, color: Color(0xFF216B42)),
                  onPressed: () =>
                      CasePaymentDialog.open(context, records[i].id),
                ),
            ],
          ),
        ),
      ),
    ],
  );
}

class CaseBookColumns extends StatelessWidget {
  const CaseBookColumns({
    super.key,
    required this.inside,
    required this.outside,
  });
  final Widget inside, outside;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => c.maxWidth >= 720
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: inside),
              const SizedBox(width: 16),
              Expanded(child: outside),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [inside, const SizedBox(height: 16), outside],
          ),
  );
}
