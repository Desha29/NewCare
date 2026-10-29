import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../app/navigation/navigation_label.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../analytics/presentation/widgets/period_filter.dart';
import '../../../analytics/data/models/report_summary.dart';
import '../../data/models/case_record.dart';
import '../widgets/case_ledger_section.dart';

class CaseBookScreen extends StatefulWidget {
  const CaseBookScreen({super.key, this.location = CaseLocation.inside});
  final CaseLocation location;
  @override
  State<CaseBookScreen> createState() => _CaseBookScreenState();
}

class _CaseBookScreenState extends State<CaseBookScreen> {
  String query = '';
  bool owing = false;
  PaymentMethod? payment;
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final range = PeriodFilter.range(context);
    // Outstanding balances remain findable across dates for subsequent receipts.
    final source = owing
        ? data.cases
        : ReportSummary.forRange(data, range.start, range.end).cases;
    final records =
        source
            .where(
              (c) =>
                  c.location == widget.location &&
                  (payment == null || c.payment == payment) &&
                  (!owing || data.remainingFor(c) > 0) &&
                  '${c.title} ${c.address} ${c.phone} ${c.id} ${data.staff.where((n) => n.id == c.staffId).firstOrNull?.name ?? ''}'
                      .toLowerCase()
                      .contains(query.trim().toLowerCase()),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return NcPageColumn(
      spacing: 8,
      children: [
        if (MediaQuery.sizeOf(context).width < 960)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final location in CaseLocation.values)
                ChoiceChip(
                  label: Text(
                    context.pageLabel(
                      location == CaseLocation.inside
                          ? AppPage.insideCaseBook
                          : AppPage.outsideCaseBook,
                    ),
                  ),
                  selected: location == widget.location,
                  onSelected: (_) => context.read<AppCubit>().navigate(
                    location == CaseLocation.inside
                        ? AppPage.insideCaseBook
                        : AppPage.outsideCaseBook,
                  ),
                ),
            ],
          ),
        LayoutBuilder(
          builder: (context, c) => Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: c.maxWidth >= 600 ? 450 : c.maxWidth,
                child: const PeriodFilter(),
              ),
              SizedBox(
                width: c.maxWidth >= 900
                    ? (c.maxWidth - 800).clamp(200, double.infinity)
                    : c.maxWidth >= 340
                    ? c.maxWidth - 170
                    : c.maxWidth,
                child: Semantics(
                  label: context.t('searchCaseBook'),
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 9,
                      ),
                      hintText: context.t('searchCaseBook'),
                      prefixIcon: const Icon(Icons.search, size: 17),
                      prefixIconConstraints: const BoxConstraints(minWidth: 34),
                    ),
                  ),
                ),
              ),
              FilterChip(
                label: Text(
                  context.t('outstandingCases'),
                  style: const TextStyle(fontSize: 11),
                ),
                selected: owing,
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onSelected: (v) => setState(() => owing = v),
              ),
              SizedBox(
                width: c.maxWidth < 340 ? c.maxWidth : 144,
                child: Theme(
                  data: Theme.of(context).copyWith(
                    inputDecorationTheme: Theme.of(context).inputDecorationTheme
                        .copyWith(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                        ),
                  ),
                  child: NcSelect<String>(
                    label: context.t('paymentMethod'),
                    value: payment?.name ?? 'all',
                    items: [
                      DropdownMenuItem(
                        value: 'all',
                        child: Text(context.t('allPaymentMethods')),
                      ),
                      for (final method in PaymentMethod.values)
                        DropdownMenuItem(
                          value: method.name,
                          child: Text(
                            context.t(method.name),
                            style: TextStyle(
                              color: NcStatusBadge.colors(method.name).$2,
                            ),
                          ),
                        ),
                    ],
                    onChanged: (value) => setState(
                      () => payment = value == null || value == 'all'
                          ? null
                          : PaymentMethod.values.byName(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (owing)
          Text(
            context.t('outstandingAllDates'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        CaseLedgerSection(
          location: widget.location,
          records: records,
          data: data,
        ),
      ],
    );
  }
}
