import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../../data/models/lab_order.dart';
import '../cubit/laboratory_cubit.dart';

class LabResultDialog extends StatefulWidget {
  const LabResultDialog({super.key, required this.order, this.onSaved});
  final LabOrder order;
  final VoidCallback? onSaved;

  @override
  State<LabResultDialog> createState() => _LabResultDialogState();
}

class _LabResultDialogState extends State<LabResultDialog> {
  String? staffId;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    final activeStaff = data.staff.where((s) => s.active).toList();
    staffId ??= activeStaff.firstOrNull?.id;

    return NcCard(
      title: context.t('markResultReceived'),
      children: [
        const OperationError<LaboratoryCubit>(),
        Text(
          '${widget.order.patientName} (${widget.order.patientAge} ${context.t('${widget.order.ageUnit}Unit')})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          widget.order.items.map((i) => i.name).join(' · '),
          style: TextStyle(color: Theme.of(context).hintColor),
        ),
        const SizedBox(height: 16),
        if (activeStaff.isNotEmpty) ...[
          DropdownButtonFormField<String>(
            initialValue: staffId,
            decoration: InputDecoration(
              labelText: context.t('recordedBy'),
              border: const OutlineInputBorder(),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            items: [
              for (final s in activeStaff)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (v) => setState(() => staffId = v),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.t('cancel')),
            ),
            const SizedBox(width: 8),
            NcButton(
              label: context.t('markResultReceived'),
              icon: Icons.check_circle_outline,
              onPressed: () async {
                if (staffId == null) return;
                final success = await context.read<LaboratoryCubit>().setReceived(
                      widget.order.id,
                      staffId!,
                      received: true,
                    );
                if (success && mounted) {
                  widget.onSaved?.call();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
