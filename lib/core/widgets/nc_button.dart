import 'package:flutter/material.dart';

class NcButton extends StatelessWidget {
  const NcButton({
    super.key,
    required this.label,
    this.onPressed,
    this.secondary = false,
    this.busy = false,
    this.icon,
    this.style,
    this.iconSize = 18,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary, busy;
  final IconData? icon;
  final ButtonStyle? style;
  final double iconSize;
  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (busy) ...[
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize),
          const SizedBox(width: 8),
        ],
        Flexible(child: Text(label, textAlign: TextAlign.center)),
      ],
    );
    return secondary
        ? OutlinedButton(
            style: style,
            onPressed: busy ? null : onPressed,
            child: child,
          )
        : FilledButton(
            style: style,
            onPressed: busy ? null : onPressed,
            child: child,
          );
  }
}
