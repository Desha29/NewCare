import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';
import '../../../../core/widgets/nc_notice.dart';
import '../../../../core/widgets/nc_page_column.dart';
import '../../../../core/widgets/operation_error.dart';
import '../../../workspace/presentation/cubit/workspace_cubit.dart';
import '../cubit/management_cubit.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});
  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  String role = 'financeManager';
  Set<String>? selected;
  bool saved = false;
  static const keys = [
    'viewTotals',
    'managePayroll',
    'manageNursing',
    'editClosedShifts',
    'manageManagers',
  ];
  @override
  Widget build(BuildContext context) {
    final data = context.watch<WorkspaceCubit>().state;
    selected ??= (data.permissions[role] ?? []).toSet();
    return NcPageColumn(
      maxWidth: 900,
      children: [
        const OperationError<ManagementCubit>(),
        NcNotice(title: context.t('permissionsNote'), tone: NoticeTone.warning),
        if (saved)
          NcNotice(title: context.t('savedNote'), tone: NoticeTone.success),
        NcCard(
          title: context.t('role'),
          children: [
            NcSelect<String>(
              label: context.t('role'),
              value: role,
              items: [
                for (final key in [
                  'chiefManager',
                  'financeManager',
                  'operationsManager',
                ])
                  DropdownMenuItem(value: key, child: Text(context.t(key))),
              ],
              onChanged: (v) => setState(() {
                role = v!;
                selected = (data.permissions[role] ?? []).toSet();
                saved = false;
              }),
            ),
            for (final key in keys)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  context.t(key),
                  style: const TextStyle(fontSize: 13),
                ),
                value: selected!.contains(key),
                onChanged: role == 'chiefManager'
                    ? null
                    : (v) => setState(() {
                        if (v ?? false) {
                          selected!.add(key);
                        } else {
                          selected!.remove(key);
                        }
                      }),
              ),
          ],
        ),
        NcButton(
          label: context.t('savePermissions'),
          onPressed: () async {
            final updated = {...data.permissions, role: selected!.toList()};
            if (await context.read<ManagementCubit>().settings(
                  permissions: updated,
                ) &&
                context.mounted) {
              setState(() => saved = true);
            }
          },
        ),
      ],
    );
  }
}
