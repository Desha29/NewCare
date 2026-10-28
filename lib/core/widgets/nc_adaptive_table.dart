import 'package:flutter/material.dart';

import '../responsive/app_breakpoints.dart';
import '../theme/app_colors.dart';
import 'nc_empty.dart';

class NcAdaptiveTable extends StatelessWidget {
  const NcAdaptiveTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.emptyLabel,
    this.onRowTap,
  });
  final List<String> headers;
  final List<List<String>> rows;
  final String emptyLabel;
  final ValueChanged<int>? onRowTap;
  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return NcEmpty(message: emptyLabel);
    if (AppBreakpoints.compact(context)) {
      return Column(
        children: [
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: onRowTap == null ? null : () => onRowTap!(i),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      for (var j = 0; j < headers.length; j++)
                        Text(
                          '${headers[j]}: ${rows[i][j]}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: j == 0
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        headingTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.muted,
          fontWeight: FontWeight.w600,
        ),
        dataTextStyle: const TextStyle(
          fontFamily: 'Cairo',
          fontSize: 12,
          color: AppColors.text,
        ),
        columns: headers.map((h) => DataColumn(label: Text(h))).toList(),
        rows: [
          for (var i = 0; i < rows.length; i++)
            DataRow(
              onSelectChanged: onRowTap == null ? null : (_) => onRowTap!(i),
              cells: rows[i].map((v) => DataCell(Text(v))).toList(),
            ),
        ],
      ),
    );
  }
}
