import 'package:flutter/material.dart';

import '../responsive/app_breakpoints.dart';

class NcActionRow extends StatelessWidget {
  const NcActionRow({super.key, required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => AppBreakpoints.compact(context)
      ? Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              children[i],
            ],
          ],
        )
      : Wrap(spacing: 12, runSpacing: 12, children: children);
}
