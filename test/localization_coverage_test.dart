import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:newcare/core/localization/localization_extensions.dart';
import 'package:newcare/l10n/app_localizations.dart';
import 'package:newcare/app/navigation/app_page.dart';
import 'package:newcare/features/cases/data/models/case_record.dart';
import 'package:newcare/features/drawer/data/models/cash_movement.dart';
import 'package:newcare/features/transactions/data/models/transaction_entry.dart';

void main() {
  Map<String, dynamic> arb(String locale) =>
      jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
          as Map<String, dynamic>;

  test('all referenced translation keys, errors and ARBs are complete', () {
    final ar = arb('ar'), en = arb('en');
    final extension = File('lib/core/localization/localization_extensions.dart')
        .readAsStringSync();
    final mapped = RegExp(r"'([^']+)'\s*=>\s*l10n\.")
        .allMatches(extension)
        .map((m) => m[1]!)
        .toSet();
    final required = <String>{};
    required.addAll(AppPage.values.map((page) => page.labelKey));
    required.addAll(CaseLocation.values.map((value) => value.name));
    required.addAll(PaymentMethod.values.map((value) => value.name));
    required.addAll(CashKind.values.map((value) => value.name));
    required.addAll(TransactionKind.values.map((value) => value.name));
    for (final file in Directory(
      'lib',
    ).listSync(recursive: true).whereType<File>()) {
      if (!file.path.endsWith('.dart') ||
          file.path.contains('app_localizations')) {
        continue;
      }
      final source = file.readAsStringSync();
      final literalUiText =
          RegExp(
                r'''\b(?:Text\s*\(|(?:label|title|hint|semanticLabel|tooltip|message)\s*:)\s*(['"])([^'"\n$]*)\1''',
              )
              .allMatches(source)
              .where((m) => RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(m[2]!));
      expect(
        literalUiText.map((m) => m[2]).toList(),
        isEmpty,
        reason: 'UI text belongs in ARB files: ${file.path}',
      );
      // Includes literal keys in conditional .t(...) expressions.
      for (final call in RegExp(r'\bt\(([^)]*)\)').allMatches(source)) {
        required.addAll(
          RegExp(r"'([a-zA-Z][a-zA-Z0-9]*)'")
              .allMatches(call[1]!)
              .map((m) => m[1]!),
        );
      }
      required.addAll(
        RegExp(r"WorkspaceException\(\s*'([^']+)'")
            .allMatches(source)
            .map((m) => m[1]!),
      );
      required.addAll(
        RegExp(r"_update\(\s*'([^']+)'").allMatches(source).map((m) => m[1]!),
      );
    }
    expect(
      required.difference(mapped),
      isEmpty,
      reason: 'Referenced keys need a localization mapping',
    );
    final keys = ar.keys.where((k) => !k.startsWith('@')).toSet();
    expect(en.keys.where((k) => !k.startsWith('@')).toSet(), keys);
    expect(keys.difference(mapped), isEmpty);
    expect(mapped.difference(keys), isEmpty);
    for (final key in keys) {
      expect((ar[key] as String).trim(), isNotEmpty, reason: 'ar:$key');
      expect((en[key] as String).trim(), isNotEmpty, reason: 'en:$key');
    }
  });

  for (final locale in ['ar', 'en']) {
    testWidgets('every mapped key resolves to the correct $locale text', (
      tester,
    ) async {
      late BuildContext localized;
      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Builder(
            builder: (context) {
              localized = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final entry in arb(
        locale,
      ).entries.where((e) => !e.key.startsWith('@'))) {
        expect(
          localized.t(entry.key),
          entry.value,
          reason: '$locale:${entry.key}',
        );
      }
      expect(
        localized.t('missingTranslationForTest'),
        localized.t('translationUnavailable'),
      );
    });
  }
}
