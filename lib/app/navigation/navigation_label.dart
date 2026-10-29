import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/localization/localization_extensions.dart';
import '../cubit/app_cubit.dart';
import 'app_page.dart';

extension NavigationLabel on BuildContext {
  String pageLabel(AppPage page) =>
      read<AppCubit>().navigationLabel(page) ?? t(page.labelKey);
}
