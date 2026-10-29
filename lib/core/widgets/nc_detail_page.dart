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

/// Uses a real page route so Hero can keep the source page and its filters alive.
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
    appBar: AppBar(
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      title: NcHeroTitle(tag: tag, title: title),
    ),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: child,
          ),
        ),
      ),
    ),
  );
}
