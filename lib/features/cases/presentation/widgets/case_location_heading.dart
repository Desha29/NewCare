import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/widgets/nc_status_badge.dart';
import '../../data/models/case_record.dart';

class CaseLocationHeading extends StatelessWidget {
  const CaseLocationHeading({
    super.key,
    required this.location,
    this.compact = false,
  });
  final CaseLocation location;
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final colors = NcStatusBadge.colors(location.name);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 12 : 16,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        context.t(location.name),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: compact ? 18 : 22,
          fontWeight: FontWeight.w700,
          color: colors.$2,
        ),
      ),
    );
  }
}
