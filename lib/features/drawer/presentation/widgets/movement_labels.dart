import 'package:flutter/widgets.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../data/models/cash_movement.dart';

String movementDescription(BuildContext context, CashMovement movement) {
  final title = movement.automaticReason
      ? context.t(movement.purposeKey)
      : movement.reason;
  return movement.recipient.isEmpty ? title : '$title · ${movement.recipient}';
}

String movementCategory(BuildContext context, CashMovement movement) =>
    movement.isPersonOutgoing
    ? '${context.t('personOutgoings')} · ${context.t(movement.purposeKey)}'
    : context.t(movement.categoryKey);
