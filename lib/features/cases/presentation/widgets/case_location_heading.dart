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
    final icon = location == CaseLocation.inside
        ? Icons.local_hospital_outlined
        : Icons.home_outlined;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: compact ? 8 : 14,
      ),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.$2.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: colors.$2, size: compact ? 18 : 22),
          const SizedBox(width: 8),
          Text(
            context.t(location.name),
            style: TextStyle(
              fontSize: compact ? 16 : 20,
              fontWeight: FontWeight.w700,
              color: colors.$2,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
