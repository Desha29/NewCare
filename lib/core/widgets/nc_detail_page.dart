import 'package:flutter/material.dart';

/// Shared element used only for record-to-detail navigation.
class NcHeroTitle extends StatelessWidget {
  const NcHeroTitle({super.key, required this.tag, required this.title});
  final Object tag;
  final String title;

  @override
  Widget build(BuildContext context) => Hero(
    tag: tag,
    transitionOnUserGestures: true,
    child: Material(
      type: MaterialType.transparency,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );
}

/// Uses a modal route so Hero can keep the source page and its filters alive.
class NcDetailPage extends StatelessWidget {
  const NcDetailPage({
    super.key,
    required this.tag,
    required this.title,
    required this.child,
  });
  final Object tag;
  final String title;
  final Widget child;

  static Future<void> open(
    BuildContext context, {
    required Object tag,
    required String title,
    required Widget child,
  }) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        transitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 260),
        reverseTransitionDuration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) =>
            NcDetailPage(tag: tag, title: title, child: child),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.transparent,
    body: SafeArea(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onTap: () {},
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Material(
                  color: Theme.of(context).cardColor,
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context)
                                  .dividerColor
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            BackButton(
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: NcHeroTitle(tag: tag, title: title),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 20),
                              tooltip: MaterialLocalizations.of(
                                context,
                              ).closeButtonTooltip,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: child,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
