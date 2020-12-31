import 'package:flutter/material.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

enum SheetKind { info, success, warning, error }

class AppSheet {
  AppSheet._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    String? message,
    SheetKind kind = SheetKind.info,
    String primaryLabel = 'OK',
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _Body(
        title: title,
        message: message,
        kind: kind,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
      ),
    );
  }

  static Future<void> error(BuildContext context, Object error,
          {String title = 'Something went wrong'}) =>
      show(context,
          title: title, message: error.toString(), kind: SheetKind.error);

  static void toast(BuildContext context, String message,
      {SheetKind kind = SheetKind.info}) {
    final color = switch (kind) {
      SheetKind.success => TwendeColors.success,
      SheetKind.warning => TwendeColors.warning,
      SheetKind.error => TwendeColors.danger,
      _ => TwendeColors.ink,
    };
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(TwendeSpacing.lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
        ),
        content: Text(message,
            style: TwendeTypography.body.copyWith(
                color: TwendeColors.textInverse,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.title,
    required this.message,
    required this.kind,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String title;
  final String? message;
  final SheetKind kind;
  final String primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      decoration: const BoxDecoration(
        color: TwendeColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TwendeSpacing.radiusXl),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        TwendeSpacing.xxl,
        TwendeSpacing.md,
        TwendeSpacing.xxl,
        TwendeSpacing.xxl + inset,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: TwendeSpacing.xl),
              decoration: BoxDecoration(
                color: TwendeColors.surfaceMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(title, style: TwendeTypography.h2),
          if (message != null) ...[
            const SizedBox(height: TwendeSpacing.sm),
            Text(message!, style: TwendeTypography.body),
          ],
          const SizedBox(height: TwendeSpacing.xxl),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onPrimary?.call();
            },
            child: Text(primaryLabel),
          ),
          if (secondaryLabel != null) ...[
            const SizedBox(height: TwendeSpacing.sm),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onSecondary?.call();
              },
              child: Text(secondaryLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
