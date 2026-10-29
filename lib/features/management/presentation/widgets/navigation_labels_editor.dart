import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/cubit/app_cubit.dart';
import '../../../../app/navigation/app_page.dart';
import '../../../../app/widgets/workspace_sidebar.dart';
import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_button.dart';
import '../../../../core/widgets/nc_card.dart';
import '../../../../core/widgets/nc_field.dart';

class NavigationLabelsEditor extends StatefulWidget {
  const NavigationLabelsEditor({super.key});
  @override
  State<NavigationLabelsEditor> createState() => _NavigationLabelsEditorState();
}

class _NavigationLabelsEditorState extends State<NavigationLabelsEditor> {
  final fields = <AppPage, TextEditingController>{};
  String? language, error;
  bool saving = false;
  final form = GlobalKey<FormState>();
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (language == locale) return;
    language = locale;
    for (final field in fields.values) {
      field.dispose();
    }
    fields.clear();
    final app = context.read<AppCubit>();
    for (final page in {
      ...nurseNavigation,
      ...managerNavigation,
      AppPage.insideCaseBook,
      AppPage.outsideCaseBook,
    }) {
      fields[page] = TextEditingController(
        text: app.navigationLabel(page) ?? '',
      );
    }
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> save({bool reset = false}) async {
    if (!reset && !form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    try {
      await context.read<AppCubit>().saveNavigationLabels({
        for (final entry in fields.entries)
          entry.key: reset ? '' : entry.value.text,
      });
      if (!mounted) return;
      if (reset) {
        for (final field in fields.values) {
          field.clear();
        }
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(context.t('savedNote'))));
    } catch (_) {
      if (mounted) setState(() => error = 'settingsSaveFailed');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Form(
    key: form,
    child: NcCard(
      title: context.t('navigationLabels'),
      children: [
        Text(context.t('navigationLabelsHelp')),
        if (error != null)
          Text(
            context.t(error!),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        LayoutBuilder(
          builder: (context, constraints) => Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final entry in fields.entries)
                SizedBox(
                  width: constraints.maxWidth >= 600
                      ? (constraints.maxWidth - 12) / 2
                      : constraints.maxWidth,
                  child: NcField(
                    label: context.t(entry.key.labelKey),
                    controller: entry.value,
                    validator: (v) => (v?.trim().length ?? 0) > 40
                        ? context.t('navigationLabelTooLong')
                        : null,
                  ),
                ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            NcButton(label: context.t('save'), onPressed: saving ? null : save),
            TextButton(
              onPressed: saving ? null : () => save(reset: true),
              child: Text(context.t('restoreNavigationLabels')),
            ),
          ],
        ),
      ],
    ),
  );
}
