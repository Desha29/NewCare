import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/action_cubit.dart';
import '../localization/localization_extensions.dart';
import 'nc_notice.dart';

class OperationError<C extends ActionCubit> extends StatelessWidget {
  const OperationError({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<C, ActionState>(
    builder: (context, state) => state.error == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NcNotice(
              title: context.t(state.error!),
              tone: NoticeTone.danger,
            ),
          ),
  );
}
