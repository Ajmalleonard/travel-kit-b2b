import 'package:flutter/material.dart';
import 'colors.dart';

class TwendeTypography {
  TwendeTypography._();

  // Bold display for hero titles.
  static const TextStyle display = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: TwendeColors.textPrimary,
    height: 1.15,
    letterSpacing: -0.6,
  );

  static const TextStyle h1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: TwendeColors.textPrimary,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: TwendeColors.textPrimary,
    height: 1.25,
    letterSpacing: -0.2,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: TwendeColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: TwendeColors.textPrimary,
    height: 1.35,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: TwendeColors.textSecondary,
    height: 1.45,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TwendeColors.textTertiary,
    height: 1.3,
    letterSpacing: 0.1,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
  );

  static const TextStyle chip = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: TwendeColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: TwendeColors.textPrimary,
  );
}
// is this garbage? probably - 22340