import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/utils/center_clock.dart';
import '../../../workspace/data/models/workspace_snapshot.dart';
import '../../data/managed_record_kind.dart';
import '../../data/record_mutations.dart';
import 'record_editor_spec.dart';

abstract final class RecordEditorSpecs {
  static RecordEditorSpec create(
    BuildContext context,
    WorkspaceSnapshot data,
    ManagedRecordKind kind,
    String id,
  ) {
    final j = RecordMutations.read(data, kind, id);
    String t(String key) => context.t(key);
    String value(String key) => j[key]?.toString() ?? '';
    final expenseLabel = value('recipient').isEmpty
        ? 'centerExpense'
        : 'otherPersonOutgoing';
    EditorField money(String key, String label) => EditorField(
      key,
      t(label),
      ((j[key] as int) / 100).toStringAsFixed(2),
      input: EditorInput.money,
    );
    EditorField date(String key, String label, {bool required = true}) =>
        EditorField(
          key,
          t(label),
          j[key] == null
              ? ''
              : CenterClock.local(DateTime.parse(j[key] as String))
                    .toIso8601String(),
          input: EditorInput.dateTime,
          required: required,
        );
    final locale = Localizations.localeOf(context).languageCode;
    final staff = {
      for (final n in data.staff)
        n.id: '${n.name}${n.isManager ? ' · ${t('manager')}' : ''}',
    };
    return switch (kind) {
      ManagedRecordKind.caseRecord => RecordEditorSpec(
        title: value('title'),
        fields: [
          EditorField('title', t('caseTitle'), value('title')),
          EditorField(
            'staff',
            t('caseOwner'),
            value('staff'),
            input: EditorInput.choice,
            choices: {for (final n in data.staff) n.id: staff[n.id]!},
          ),
          EditorField(
            'procedure',
            t('procedure'),
            value('procedure'),
            input: EditorInput.choice,
            choices: {for (final p in data.procedures) p.id: p.name(locale)},
          ),
          EditorField(
            'location',
            t('caseType'),
            value('location'),
            input: EditorInput.choice,
            choices: {'inside': t('inside'), 'outside': t('outside')},
          ),
          EditorField(
            'address',
            t('address'),
            value('address'),
            required: false,
          ),
          EditorField(
            'phone',
            t('phoneOptional'),
            value('phone'),
            required: false,
          ),
          EditorField(
            'supplies',
            t('supplies'),
            (j['supplies'] as List).join('\n'),
            input: EditorInput.multiline,
            required: false,
          ),
          money('amount', 'amount'),
          EditorField(
            'payment',
            t('paymentMethod'),
            value('payment'),
            input: EditorInput.choice,
            choices: {'cash': t('cash'), 'wallet': t('wallet')},
          ),
          date('created', 'time'),
        ],
      ),
      ManagedRecordKind.caseReceipt => RecordEditorSpec(
        title: t('casePayment'),
        fields: [
          money('amount', 'amount'),
          EditorField(
            'staffId',
            t('recordedBy'),
            value('staffId'),
            input: EditorInput.choice,
            choices: staff,
          ),
          EditorField(
            'method',
            t('paymentMethod'),
            value('method'),
            input: EditorInput.choice,
            choices: {'cash': t('cash'), 'wallet': t('wallet')},
          ),
          date('paidAt', 'dateAndTime'),
        ],
      ),
      ManagedRecordKind.nursing => RecordEditorSpec(
        title: value('name'),
        requiresReason: false,
        fields: [
          EditorField('name', t('memberName'), value('name')),
          EditorField(
            'phone',
            t('phoneOptional'),
            value('phone'),
            required: false,
          ),
          money('salary', 'monthlySalary'),
          EditorField(
            'isManager',
            t('isManager'),
            value('isManager'),
            input: EditorInput.toggle,
          ),
          EditorField(
            'active',
            t('active'),
            value('active'),
            input: EditorInput.toggle,
          ),
        ],
      ),
      ManagedRecordKind.procedure => RecordEditorSpec(
        title: value(locale == 'ar' ? 'ar' : 'en'),
        fields: [EditorField('ar', t('itemName'), value('ar'))],
      ),
      ManagedRecordKind.supply => RecordEditorSpec(
        title: value(locale == 'ar' ? 'ar' : 'en'),
        fields: [EditorField('ar', t('itemName'), value('ar'))],
      ),
      ManagedRecordKind.movement => RecordEditorSpec(
        title: ['advance', 'externalAdvance'].contains(value('kind'))
            ? t('advance')
            : value('reason'),
        requiresReason: ![
          'advance',
          'award',
          'externalAdvance',
        ].contains(value('kind')),
        fields: [
          money('amount', 'amount'),
          EditorField(
            'recipient',
            t('externalRecipient'),
            value('recipient'),
            required: false,
          ),
          if (!['advance', 'award', 'externalAdvance'].contains(value('kind')))
            EditorField('reason', t('reason'), value('reason')),
          EditorField(
            'staff',
            t('recordedBy'),
            value('staff'),
            input: EditorInput.choice,
            choices: {
              for (final n in data.staff.where(
                (n) => ['advance', 'award'].contains(j['kind']) || n.active,
              ))
                n.id: staff[n.id]!,
            },
          ),
          EditorField(
            'kind',
            t('movementKind'),
            value('kind'),
            input: EditorInput.choice,
            choices: {
              'income': t('income'),
              'expense': t(expenseLabel),
              if (value('kind') != 'externalAdvance') 'advance': t('advance'),
              'award': t('award'),
              if (value('kind') == 'externalAdvance')
                'externalAdvance': t('advance'),
            },
          ),
          date('created', 'time'),
        ],
      ),
      ManagedRecordKind.shift => RecordEditorSpec(
        title: t('shift'),
        fields: [
          money('opening', 'openingCash'),
          EditorField(
            'note',
            t('handoverNotes'),
            value('note'),
            input: EditorInput.multiline,
            required: false,
          ),
          date('opened', 'openedAt'),
          date('closed', 'endShift', required: false),
        ],
      ),
    };
  }
}
