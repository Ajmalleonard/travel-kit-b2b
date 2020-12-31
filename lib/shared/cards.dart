import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../design/colors.dart';
import '../design/spacing.dart';
import '../design/typography.dart';

/// The reference-style stacked card:
/// ┌────────────────────────────────────────────────┐
/// │ [avatar] Title              [chip on the right]│
/// │           subtitle                              │
/// │                                                 │
/// │ leadingValue   • [icon middle] •   trailingVal │
/// │                                                 │
/// │ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ │
/// │                                                 │
/// │ $price                          [ CTA pill ]   │
/// │ caption                                         │
/// └────────────────────────────────────────────────┘
class ReferenceCard extends StatelessWidget {
  const ReferenceCard({
    super.key,
    required this.avatar,
    required this.title,
    required this.subtitle,
    required this.chip,
    required this.middle,
    required this.priceLabel,
    required this.priceCaption,
    required this.ctaLabel,
    required this.onCta,
  });

  final Widget avatar;
  final String title;
  final String subtitle;
  final String chip;
  final Widget middle;
  final String priceLabel;
  final String priceCaption;
  final String ctaLabel;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.xxl),
      decoration: BoxDecoration(
        color: TwendeColors.surface,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(width: 50, height: 50, child: avatar),
              const SizedBox(width: TwendeSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TwendeTypography.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: TwendeTypography.body,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: TwendeSpacing.sm),
              _Chip(label: chip),
            ],
          ),
          const SizedBox(height: TwendeSpacing.xxl),
          middle,
          const SizedBox(height: TwendeSpacing.xl),
          const _DashedDivider(),
          const SizedBox(height: TwendeSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      priceLabel,
                      style: TwendeTypography.display.copyWith(fontSize: 32),
                    ),
                    Text(priceCaption, style: TwendeTypography.body),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onCta,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwendeSpacing.xxl,
                    vertical: TwendeSpacing.lg,
                  ),
                ),
                child: Text(ctaLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A flight-style "leading – icon – trailing" row used as the middle slot.
class TimeRangeRow extends StatelessWidget {
  const TimeRangeRow({
    super.key,
    required this.leading,
    required this.middle,
    required this.trailing,
    this.middleIcon = IconsaxPlusBold.calendar_2,
  });
  final String leading;
  final String middle;
  final String trailing;
  final IconData middleIcon;

  @override
  Widget build(BuildContext context) {
    final big = TwendeTypography.display.copyWith(fontSize: 30);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(leading, style: big),
        Row(
          children: [
            Icon(middleIcon, size: 16, color: TwendeColors.textTertiary),
            const SizedBox(width: 4),
            Text(middle, style: TwendeTypography.body),
          ],
        ),
        Text(trailing, style: big),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      ),
      child: Text(
        label,
        style: TwendeTypography.chip.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        const dash = 6.0;
        const gap = 4.0;
        final n = (c.maxWidth / (dash + gap)).floor();
        return Row(
          children: List.generate(
            n,
            (_) => Container(
              width: dash,
              height: 1,
              margin: const EdgeInsets.only(right: gap),
              color: TwendeColors.surfaceMuted,
            ),
          ),
        );
      },
    );
  }
}

/// Round avatar with a first letter inside a soft circle.
class InitialAvatar extends StatelessWidget {
  const InitialAvatar({super.key, required this.text, this.color});
  final String text;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final initial = text.trim().isEmpty ? '?' : text.trim()[0].toUpperCase();
    return Container(
      decoration: BoxDecoration(
        color: color ?? TwendeColors.surfaceMuted,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TwendeTypography.h3.copyWith(color: TwendeColors.textPrimary),
      ),
    );
  }
}
