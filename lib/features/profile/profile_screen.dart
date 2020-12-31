import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../api/repositories.dart';
import '../../auth/auth_controller.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';
import '../onboarding/onboarding_store.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final op = ref.watch(operatorProfileProvider);
    final onb = ref.watch(onboardingControllerProvider);
    final name = auth.session?.user.fullName ?? 'Partner';
    final business = op.value?.businessName ?? onb.businessName ?? 'Your business';
    final email = auth.session?.user.email ?? '';

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TwendeSpacing.xxl,
        TwendeSpacing.xxxl,
        TwendeSpacing.xxl,
        TwendeSpacing.xxxl,
      ),
      children: [
        Text('Profile', style: TwendeTypography.display),
        const SizedBox(height: TwendeSpacing.xxl),
        Container(
          padding: const EdgeInsets.all(TwendeSpacing.xl),
          decoration: BoxDecoration(
            color: TwendeColors.ink,
            borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name.toUpperCase(),
                  style: TwendeTypography.caption.copyWith(
                      color: TwendeColors.textInverse, letterSpacing: 2)),
              const SizedBox(height: TwendeSpacing.sm),
              Text(business,
                  style: TwendeTypography.h1.copyWith(
                      color: TwendeColors.textInverse)),
              if (email.isNotEmpty) ...[
                const SizedBox(height: TwendeSpacing.xs),
                Text(email,
                    style: TwendeTypography.body.copyWith(
                        color: TwendeColors.textInverse
                            .withValues(alpha: 0.7))),
              ],
            ],
          ),
        ),
        const SizedBox(height: TwendeSpacing.xxl),
        _Row(
          icon: IconsaxPlusBold.shield_tick,
          label: 'Verification',
          trailing: _chip(op.value?.status ?? 'pending'),
          onTap: () => context.push('/verification'),
        ),
        _Row(
          icon: IconsaxPlusBold.bank,
          label: 'Payouts',
          onTap: () => AppSheet.show(context,
              title: 'Coming soon',
              kind: SheetKind.info),
        ),
        _Row(
          icon: IconsaxPlusBold.message_question,
          label: 'Help',
          onTap: () => AppSheet.show(context,
              title: 'Contact',
              message: 'partners@twendezanzibar.com',
              kind: SheetKind.info),
        ),
        const SizedBox(height: TwendeSpacing.xxxl),
        FilledButton(
          onPressed: () async =>
              ref.read(authControllerProvider.notifier).signOut(),
          style: FilledButton.styleFrom(
            backgroundColor: TwendeColors.dangerBg,
            foregroundColor: TwendeColors.danger,
          ),
          child: const Text('Sign out'),
        ),
      ],
    );
  }

  Widget _chip(String s) {
    final (label, c, bg) = switch (s) {
      'approved' => ('Verified', TwendeColors.success, TwendeColors.successBg),
      'rejected' => ('Rejected', TwendeColors.danger, TwendeColors.dangerBg),
      _ => ('Pending', TwendeColors.warning, TwendeColors.warningBg),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      ),
      child: Text(label,
          style: TwendeTypography.caption.copyWith(
              color: c, fontWeight: FontWeight.w600)),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TwendeSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: TwendeColors.textPrimary),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(child: Text(label, style: TwendeTypography.title)),
              ?trailing,
              const SizedBox(width: 6),
              const Icon(IconsaxPlusLinear.arrow_right_3,
                  color: TwendeColors.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}
