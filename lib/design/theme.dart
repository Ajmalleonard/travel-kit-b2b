import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

class TwendeTheme {
  TwendeTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: TwendeColors.ink,
        onPrimary: TwendeColors.textInverse,
        secondary: TwendeColors.surfaceMuted,
        onSecondary: TwendeColors.textPrimary,
        surface: TwendeColors.surface,
        onSurface: TwendeColors.textPrimary,
        surfaceContainerHighest: TwendeColors.surfaceMuted,
        outline: TwendeColors.surfaceMuted,
        error: TwendeColors.danger,
      ),
      scaffoldBackgroundColor: TwendeColors.surfaceSubtle,
      appBarTheme: const AppBarTheme(
        backgroundColor: TwendeColors.background,
        foregroundColor: TwendeColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TwendeTypography.display,
        displayMedium: TwendeTypography.h1,
        displaySmall: TwendeTypography.h2,
        headlineLarge: TwendeTypography.h1,
        headlineMedium: TwendeTypography.h2,
        headlineSmall: TwendeTypography.h3,
        titleLarge: TwendeTypography.title,
        titleMedium: TwendeTypography.title,
        bodyLarge: TwendeTypography.body,
        bodyMedium: TwendeTypography.body,
        bodySmall: TwendeTypography.caption,
        labelLarge: TwendeTypography.button,
        labelMedium: TwendeTypography.label,
        labelSmall: TwendeTypography.caption,
      ),
      iconTheme: const IconThemeData(color: TwendeColors.textPrimary, size: 22),

      // BOLD pill CTA: dark fill, white text.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: TwendeColors.ink,
          foregroundColor: TwendeColors.textInverse,
          disabledBackgroundColor: TwendeColors.surfaceMuted,
          disabledForegroundColor: TwendeColors.textTertiary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 60),
          padding: const EdgeInsets.symmetric(
            horizontal: TwendeSpacing.xxxl,
            vertical: TwendeSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          ),
          textStyle: TwendeTypography.button,
        ),
      ),

      // Secondary pill: muted grey fill, dark text — no border.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: TwendeColors.surfaceMuted,
          foregroundColor: TwendeColors.textPrimary,
          elevation: 0,
          minimumSize: const Size(double.infinity, 60),
          padding: const EdgeInsets.symmetric(
            horizontal: TwendeSpacing.xxxl,
            vertical: TwendeSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          ),
          textStyle: TwendeTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: TwendeColors.surfaceMuted,
          foregroundColor: TwendeColors.textPrimary,
          side: BorderSide.none,
          minimumSize: const Size(double.infinity, 60),
          padding: const EdgeInsets.symmetric(
            horizontal: TwendeSpacing.xxxl,
            vertical: TwendeSpacing.xl,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          ),
          textStyle: TwendeTypography.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: TwendeColors.textPrimary,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: TwendeSpacing.xl,
            vertical: TwendeSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          ),
          textStyle: TwendeTypography.button,
        ),
      ),

      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.all(TwendeSpacing.md),
          foregroundColor: TwendeColors.textPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: TwendeColors.surfaceSubtle,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: TwendeSpacing.xl,
          vertical: TwendeSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        hintStyle: TwendeTypography.body.copyWith(
          color: TwendeColors.textTertiary,
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: TwendeColors.surfaceMuted,
        space: 1,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: TwendeColors.surfaceMuted,
        labelStyle: TwendeTypography.chip,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
        ),
      ),
      cardTheme: CardThemeData(
        color: TwendeColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusXl),
        ),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: TwendeColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: TwendeColors.surfaceMuted,
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(TwendeTypography.caption),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? TwendeColors.ink
                : TwendeColors.textTertiary,
            size: 22,
          ),
        ),
      ),
      splashFactory: NoSplash.splashFactory,
    );
  }
}
