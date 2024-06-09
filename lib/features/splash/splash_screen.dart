import 'package:flutter/material.dart';

import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // ANIMATION (1/3): subtle fade-in for the splash mark.
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 480),
          curve: Curves.easeOut,
          builder: (_, v, child) => Opacity(opacity: v, child: child),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: TwendeColors.ink,
                  borderRadius: BorderRadius.circular(TwendeSpacing.radiusXl),
                ),
                alignment: Alignment.center,
                child: Text('T',
                    style: TwendeTypography.display.copyWith(
                      color: TwendeColors.textInverse,
                      fontSize: 40,
                    )),
              ),
              const SizedBox(height: TwendeSpacing.xl),
              Text('Twende Partners', style: TwendeTypography.h2),
            ],
          ),
        ),
      ),
    );
  }
}
// 其实这里的逻辑有点难懂 - 21134