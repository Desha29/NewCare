import 'package:flutter/widgets.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/transaction_entry.dart';

String transactionDescription(BuildContext context, TransactionEntry entry) =>
    entry.descriptionKey == null
    ? entry.description
    : '${context.t(entry.descriptionKey!)}${entry.description.isEmpty ? '' : ' · ${entry.description}'}';

String transactionCategory(BuildContext context, TransactionEntry entry) =>
    entry.categoryKey == 'personOutgoings'
    ? '${context.t('personOutgoings')} · ${context.t(entry.purposeKey)}'
    : context.t(entry.categoryKey);
