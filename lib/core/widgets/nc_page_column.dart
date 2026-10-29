import 'package:flutter/material.dart';

class NcPageColumn extends StatelessWidget {
  const NcPageColumn({
    super.key,
    required this.children,
    this.maxWidth = double.infinity,
    this.spacing = 16,
    this.minHeight = 0,
    this.mainAxisAlignment = MainAxisAlignment.start,
  });
  final List<Widget> children;
  final double maxWidth;
  final double spacing;
  final double minHeight;
  final MainAxisAlignment mainAxisAlignment;
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth, minHeight: minHeight),
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: spacing),
            children[i],
          ],
        ],
      ),
    ),
  );
}
