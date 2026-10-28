import 'package:flutter/material.dart';

import '../../app/widgets/workspace_header.dart';

class NcAuthLayout extends StatelessWidget {
  const NcAuthLayout({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: WorkspaceHeader(
              onMenu: () {},
              compact: false,
              showShiftControls: false,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: c.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
