import 'package:flutter/material.dart';

class NcAuthLayout extends StatelessWidget {
  const NcAuthLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: c.maxWidth < 520 ? 16 : 32,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
