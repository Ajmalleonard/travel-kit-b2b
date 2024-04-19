import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_router.dart';
import 'design/colors.dart';
import 'design/spacing.dart';
import 'design/theme.dart';
import 'design/typography.dart';

void main() {
  ErrorWidget.builder = (details) {
    if (kReleaseMode) {
      return Container(
        color: TwendeColors.background,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(TwendeSpacing.xl),
        child: Text("We couldn't render this screen.",
            textAlign: TextAlign.center, style: TwendeTypography.body),
      );
    }
    return Container(
      color: TwendeColors.dangerBg,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(TwendeSpacing.xl),
      child: SingleChildScrollView(
        child: Text(details.exceptionAsString(),
            style: TwendeTypography.body.copyWith(color: TwendeColors.danger)),
      ),
    );
  };
  runApp(const ProviderScope(child: TwendePartnersApp()));
}

class TwendePartnersApp extends ConsumerWidget {
  const TwendePartnersApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Twende Partners',
      debugShowCheckedModeBanner: false,
      theme: TwendeTheme.light(),
      routerConfig: router,
    );
  }
}
// rewrote this to prevent crash - 20279