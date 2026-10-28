import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'nc_empty.dart';

class NcAdaptiveTable extends StatelessWidget {
  const NcAdaptiveTable({
    super.key,
    required this.headers,
    required this.rows,
    required this.emptyLabel,
    this.onRowTap,
    this.actions,
    this.alwaysTable = false,
    this.cellBuilder,
  });
  final List<String> headers;
  final List<List<String>> rows;
  final String emptyLabel;
  final ValueChanged<int>? onRowTap;
  final Widget Function(int)? actions;
  final bool alwaysTable;
  final Widget Function(int row, int column, String value)? cellBuilder;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return NcEmpty(message: emptyLabel);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!alwaysTable && constraints.maxWidth < 520) return _cards();
        final cellWidth = math.max(
          100.0,
          math.min(
            260.0,
            (constraints.maxWidth -
                    32 -
                    (headers.length - 1) * 24 -
                    (actions == null ? 0 : 96)) /
                headers.length,
          ),
        );
        final table = DataTable(
          showCheckboxColumn: false,
          horizontalMargin: 16,
          columnSpacing: 24,
          headingRowHeight: 52,
          dataRowMinHeight: 52,
          dataRowMaxHeight: double.infinity,
          headingTextStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            color: AppColors.muted,
            fontWeight: FontWeight.w700,
          ),
          dataTextStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          columns: [
            for (final header in headers)
              DataColumn(
                label: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: cellWidth),
                  child: Text(header, softWrap: true),
                ),
              ),
            if (actions != null) const DataColumn(label: SizedBox.shrink()),
          ],
          rows: [
            for (var i = 0; i < rows.length; i++)
              DataRow(
                onSelectChanged: onRowTap == null ? null : (_) => onRowTap!(i),
                cells: [
                  for (var j = 0; j < rows[i].length; j++)
                    DataCell(
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: cellWidth),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child:
                              cellBuilder?.call(i, j, rows[i][j]) ??
                              Text(rows[i][j], softWrap: true),
                        ),
                      ),
                    ),
                  if (actions != null) DataCell(actions!(i)),
                ],
              ),
          ],
        );
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: table,
          ),
        );
      },
    );
  }

  Widget _cards() {
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < headers.length; j++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child:
                            cellBuilder?.call(i, j, rows[i][j]) ??
                            Text(
                              '${headers[j]}: ${rows[i][j]}',
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: j == 0
                                    ? FontWeight.w700
                                    : FontWeight.w700,
                              ),
                            ),
                      ),
                    if (actions != null)
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions!(i),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
