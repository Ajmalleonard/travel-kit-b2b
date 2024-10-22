import 'package:flutter/material.dart';

/// Bold UI palette — clean white surfaces, near-black hero blocks,
/// muted grey chips. Zero borders, zero shadows everywhere.
class TwendeColors {
  TwendeColors._();

  // Hero/primary near-black, used for filled CTAs and dark cards.
  static const Color ink = Color(0xFF1A1F2E);
  static const Color inkSoft = Color(0xFF2A2F3E);

  // Page + card surfaces.
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFEFF1); // chips, secondary buttons
  static const Color surfaceSubtle = Color(0xFFF7F7F8); // input fills

  // Text.
  static const Color textPrimary = Color(0xFF0A1320);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFA0A6B0);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Brand accent (used sparingly — selection state, status).
  static const Color accent = Color(0xFF1A1F2E); // same as ink, bold not amber
  static const Color accentSoft = Color(0xFFEFEFF1);

  // Status — kept only for badges, not chrome.
  static const Color success = Color(0xFF0F8A4F);
  static const Color successBg = Color(0xFFE5F4EC);
  static const Color warning = Color(0xFFB46A0F);
  static const Color warningBg = Color(0xFFFAF0DC);
  static const Color danger = Color(0xFFB91C1C);
  static const Color dangerBg = Color(0xFFFCE8E8);
}
// trust the process trust - 23398