import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../core/cubit/action_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/money.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../../core/widgets/nc_action_row.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_empty.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/case_record.dart';
import '../cubit/case_cubit.dart';
import '../widgets/case_form_fields.dart';

class CaseFormScreen extends StatefulWidget {
  const CaseFormScreen({
    super.key,
    required this.outside,
    this.inDialog = false,
    this.onSaved,
    this.onCancel,
  });
  final bool outside;
  final bool inDialog;
  final VoidCallback? onSaved, onCancel;
  @override
  State<CaseFormScreen> createState() => _CaseFormScreenState();
}

class _CaseFormScreenState extends State<CaseFormScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      address = TextEditingController(),
      phone = TextEditingController(),
      supplies = TextEditingController(),
      amount = TextEditingController();
  final id = const Uuid().v4();
  String? staff, procedure;
  PaymentMethod payment = PaymentMethod.cash;
  late bool outside;
  @override
  void initState() {
    super.initState();
    outside = widget.outside;
  }

  @override
  void dispose() {
    for (final c in [title, address, phone, supplies, amount]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final shift = data.activeShift;
    if (shift == null) {
      return NcEmpty(
        message: context.t('noOpenShift'),
        action: NcButton(
          label: context.t('startShift'),
          onPressed: () =>
              context.read<AppCubit>().navigate(AppPage.startShift),
        ),
      );
    }
    final available = data.staff
        .where((n) => n.active && shift.memberIds.contains(n.id))
        .map((n) => n.id)
        .toList();
    if (available.isEmpty) {
      return NcEmpty(
        message: context.t('selectStaff'),
        action: NcButton(
          label: context.t('joinShift'),
          onPressed: () => context.read<AppCubit>().navigate(AppPage.joinShift),
        ),
      );
    }
    final preferred = staff ?? context.read<AppCubit>().state.staffId;
    staff = available.contains(preferred) ? preferred : available.first;
    return Form(
      key: form,
      child: NcPageColumn(
        maxWidth: 900,
        children: [
          if (widget.inDialog)
            DefaultTabController(
              length: 2,
              child: TabBar(
                onTap: (index) => setState(() => outside = index == 1),
                tabs: [
                  const Tab(child: NcStatusBadge('inside')),
                  const Tab(child: NcStatusBadge('outside')),
                ],
              ),
            ),
          const OperationError<CaseCubit>(),
          NcCard(
            title: widget.inDialog
                ? null
                : context.t(outside ? 'outsideCase' : 'insideCase'),
            children: [
              CaseFormFields(
                workspace: data,
                outside: outside,
                title: title,
                address: address,
                phone: phone,
                supplies: supplies,
                staffId: staff,
                procedureId: procedure,
                onStaff: (v) => setState(() => staff = v),
                onProcedure: (v) {
                  setState(() => procedure = v);
                  final p = data.procedures.firstWhere((p) => p.id == v);
                  amount.text = (p.priceMinor / 100).toStringAsFixed(2);
                  if (title.text.isEmpty) {
                    title.text = p.name(
                      Localizations.localeOf(context).languageCode,
                    );
                  }
                },
              ),
              PaymentFields(
                amount: amount,
                method: payment,
                onMethod: (v) => setState(() => payment = v),
              ),
            ],
          ),
          NcActionRow(
            children: [
              BlocBuilder<CaseCubit, ActionState>(
                builder: (context, state) => NcButton(
                  label: context.t('saveCase'),
                  busy: state.busy,
                  onPressed: () async {
                    if (!form.currentState!.validate()) return;
                    final record = CaseRecord(
                      id: id,
                      shiftId: shift.id,
                      staffId: staff!,
                      title: title.text.trim(),
                      procedureId: procedure!,
                      supplies: supplies.text
                          .split('\n')
                          .where((s) => s.trim().isNotEmpty)
                          .map((s) => s.trim())
                          .toList(),
                      amountMinor: Money.parse(amount.text),
                      payment: payment,
                      location: outside
                          ? CaseLocation.outside
                          : CaseLocation.inside,
                      createdAt: CenterClock.now(),
                      address: outside ? address.text.trim() : '',
                      phone: outside ? phone.text.trim() : '',
                    );
                    if (await context.read<CaseCubit>().save(record) &&
                        context.mounted) {
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
                    () =>
                        context.read<AppCubit>().navigate(AppPage.activeShift),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
