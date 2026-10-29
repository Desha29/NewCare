import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/cubit/action_cubit.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../data/models/case_record.dart';
import '../../data/models/case_line_item.dart';
import '../cubit/case_cubit.dart';
import '../models/case_draft.dart';
import '../widgets/case_form_fields.dart';
import '../widgets/catalogue_multi_picker.dart';
import '../widgets/case_bill_panel.dart';

class CaseFormScreen extends StatefulWidget {
  const CaseFormScreen({
    super.key,
    required this.outside,
    this.inDialog = false,
    this.compact = false,
    this.initial,
    this.onSaved,
    this.onCancel,
    this.header,
    this.minHeight = 0,
  });
  final bool outside, inDialog, compact;
  final CaseRecord? initial;
  final VoidCallback? onSaved, onCancel;
  final Widget? header;
  final double minHeight;
  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final form = GlobalKey<FormState>();
  late final CaseDraft draft;
  @override
  void initState() {
    super.initState();
    draft = CaseDraft(outside: widget.outside, initial: widget.initial);
  }

  @override
  void dispose() {
    draft.dispose();
    super.dispose();
  }

  void select(
    WorkspaceSnapshot data,
    Set<String> values, {
    bool supply = false,
  }) {
    setState(() {
      (supply ? draft.supplies : draft.procedures)
        ..clear()
        ..addAll(values);
      draft.updateSelectionTitle(
        data,
        Localizations.localeOf(context).languageCode,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final available = data.staff
        .where((n) => widget.initial != null || n.active)
        .map((n) => n.id)
        .toList();
    if (available.isEmpty) return NcEmpty(message: context.t('selectStaff'));
    final preferred = draft.staff ?? context.read<AppCubit>().state.staffId;
    draft.staff = available.contains(preferred) ? preferred : available.first;
    final items = draft.items(data),
        locale = Localizations.localeOf(context).languageCode;
    final procedureOptions = [
      for (final p in data.procedures.where(
        (p) => p.active || draft.procedures.contains(p.id),
      ))
        CatalogueOption(
          p.id,
          p.name(locale),
          items
                  .where(
                    (i) =>
                        i.kind == CaseItemKind.procedure &&
                        i.catalogueId == p.id,
                  )
                  .firstOrNull
                  ?.priceMinor ??
              p.priceMinor,
        ),
    ];
    final fields = CaseFormFields(
      workspace: data,
      compact: widget.compact,
      outside: draft.outside,
      title: draft.title,
      address: draft.address,
      phone: draft.phone,
      supplies: draft.notes,
      staffId: draft.staff,
      procedureId: draft.procedures.firstOrNull,
      memberIds: available,
      includeInactive: widget.initial != null,
      onStaff: (v) => setState(() => draft.staff = v),
      onProcedure: (v) => select(data, {?v}),
      procedurePicker: CatalogueMultiPicker(
        label: context.t('proceduresUsed'),
        compact: widget.compact,
        options: procedureOptions,
        selected: draft.procedures,
        required: true,
        onChanged: (v) => select(data, v),
      ),
    );
    final bill = CaseBillPanel(
      compact: widget.compact,
      amount: draft.amount,
      agreedTotal: draft.agreedTotal,
      previousReceipts: widget.initial == null
          ? 0
          : data.paidFor(widget.initial!) - widget.initial!.amountMinor,
      payment: draft.payment,
      onPayment: (v) => setState(() => draft.payment = v),
    );
    final content = LayoutBuilder(
      builder: (context, c) => c.maxWidth >= (widget.compact ? 600 : 760)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: widget.compact
                      ? fields
                      : NcCard(padding: 16, children: [fields]),
                ),
                SizedBox(width: widget.compact ? 12 : 20),
                Expanded(flex: 2, child: bill),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                fields,
                if (widget.compact)
                  const Divider(height: 16)
                else
                  const SizedBox(height: 20),
                bill,
              ],
            ),
    );
    final actions = NcActionRow(
      children: [
        BlocBuilder<CaseCubit, ActionState>(
          builder: (context, state) => NcButton(
            label: context.t('saveCase'),
            busy: state.busy,
            icon: Icons.check,
            onPressed: () async {
              if (!form.currentState!.validate()) return;
              final record = draft.record(data, ''),
                  cubit = context.read<CaseCubit>();
              final saved = widget.initial == null
                  ? await cubit.save(record)
                  : await cubit.update(record);
              if (saved && context.mounted) {
                if (widget.onSaved != null) {
                  widget.onSaved!();
                } else {
                  context.read<AppCubit>().showSaved();
                }
              }
            },
          ),
        ),
        NcButton(
          label: context.t('cancel'),
          secondary: true,
          onPressed:
              widget.onCancel ??
              () => context.read<AppCubit>().navigate(AppPage.activeShift),
        ),
      ],
    );
    final tabs = widget.inDialog
        ? DefaultTabController(
            length: 2,
            initialIndex: draft.outside ? 1 : 0,
            child: TabBar(
              onTap: (index) => setState(() => draft.outside = index == 1),
              tabs: const [
                Tab(child: NcStatusBadge('inside')),
                Tab(child: NcStatusBadge('outside')),
              ],
            ),
          )
        : const SizedBox.shrink();
    final formWidget = Form(
      key: form,
      child: widget.inDialog
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: tabs,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: NcPageColumn(
                        children: [const OperationError<CaseCubit>(), content],
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  child: actions,
                ),
              ],
            )
          : NcPageColumn(
              maxWidth: 1100,
              minHeight: widget.minHeight,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: widget.compact ? 10 : 16,
              children: [
                NcPageColumn(
                  spacing: widget.compact ? 12 : 16,
                  children: [
                    if (widget.header != null) widget.header!,
                    if (!widget.compact ||
                        context.watch<CaseCubit>().state.error != null)
                      const OperationError<CaseCubit>(),
                    content,
                  ],
                ),
                actions,
              ],
            ),
    );
    if (!widget.compact) return formWidget;
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
      ),
      child: formWidget,
    );
  }
}
