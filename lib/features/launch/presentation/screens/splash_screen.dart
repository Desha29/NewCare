import 'package:flutter/material.dart';

import '../../../../core/localization/localization_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/animated_brand_mark.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.onCompleted});
  final VoidCallback? onCompleted;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> reveal;
  bool started = false;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    reveal = CurvedAnimation(parent: controller, curve: Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (started) return;
    started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      controller.value = 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onCompleted?.call();
      });
    } else {
      controller.forward().whenComplete(() {
        if (mounted) widget.onCompleted?.call();
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    body: SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBrandMark(animation: reveal),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: reveal,
                child: Text(
                  context.t('brandName'),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              FadeTransition(
                opacity: reveal,
                child: Text(
                  context.t('nursingCareServices'),
                  style: const TextStyle(
                    fontSize: 10,
                    letterSpacing: 1.5,
                    color: AppColors.teal,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: reveal,
                child: Text(
                  context.t('loadingWorkspace'),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 16),
              AnimatedBuilder(
                animation: controller,
                builder: (context, _) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Opacity(
                        opacity: (controller.value - i * .12).clamp(.2, 1),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.teal,
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
      ),
    ),
  );
}
