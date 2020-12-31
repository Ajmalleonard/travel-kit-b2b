import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../api/repositories.dart';
import '../../auth/auth_controller.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final listings = ref.watch(myListingsProvider);
    final bookings = ref.watch(incomingBookingsProvider);
    final profile = ref.watch(operatorProfileProvider);
    final analytics = ref.watch(analyticsProvider);

    final name = auth.session?.user.fullName ?? 'Partner';
    final money = NumberFormat.simpleCurrency(name: 'USD');
    final revenue = (bookings.value ?? const []).fold<double>(
      0,
      (a, b) => a + b.total,
    );

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myListingsProvider);
        ref.invalidate(incomingBookingsProvider);
        ref.invalidate(operatorProfileProvider);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          TwendeSpacing.xxl,
          TwendeSpacing.xxxl,
          TwendeSpacing.xxl,
          TwendeSpacing.xxxl,
        ),
        children: [
          Text('Hi, $name', style: TwendeTypography.display),
          const SizedBox(height: TwendeSpacing.xxl),

          // ── Dark hero card (Permata pattern). ────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: TwendeColors.ink,
              borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
            ),
            padding: const EdgeInsets.all(TwendeSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'REVENUE',
                  style: TwendeTypography.caption.copyWith(
                    color: TwendeColors.textInverse,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: TwendeSpacing.md),
                Text(
                  money.format(revenue),
                  style: TwendeTypography.display.copyWith(
                    color: TwendeColors.textInverse,
                    fontSize: 40,
                  ),
                ),
                const SizedBox(height: TwendeSpacing.sm),
                Text(
                  '${bookings.value?.length ?? 0} pending',
                  style: TwendeTypography.body.copyWith(
                    color: TwendeColors.textInverse.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: TwendeSpacing.xl),

          // ── Verification chip-style banner. ──────────────────────────────
          _StatusBanner(
            status: profile.value?.status ?? 'pending',
            onTap: () => context.push('/verification'),
          ),

          const SizedBox(height: TwendeSpacing.xxl),

          // ── KPI row. ─────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _Kpi(
                  label: 'Listings',
                  value: '${listings.value?.length ?? 0}',
                ),
              ),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(
                child: _Kpi(
                  label: 'Bookings',
                  value: '${bookings.value?.length ?? 0}',
                ),
              ),
            ],
          ),

          const SizedBox(height: TwendeSpacing.xxl),

          _AnalyticsRow(
            data: analytics.value,
            localListings: listings.value?.length ?? 0,
            localBookings: bookings.value?.length ?? 0,
          ),

          const SizedBox(height: TwendeSpacing.xxxl),

          Text('Quick actions', style: TwendeTypography.h3),
          const SizedBox(height: TwendeSpacing.md),
          _ActionRow(
            icon: IconsaxPlusBold.add_square,
            label: 'New listing',
            onTap: () => context.push('/listings/new'),
          ),
          const SizedBox(height: TwendeSpacing.sm),
          _ActionRow(
            icon: IconsaxPlusBold.calendar,
            label: 'View bookings',
            onTap: () => context.go('/bookings'),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.onTap});
  final String status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'verified';
    return Material(
      color: TwendeColors.surfaceMuted,
      borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(TwendeSpacing.lg),
          child: Row(
            children: [
              Icon(
                approved
                    ? IconsaxPlusBold.shield_tick
                    : IconsaxPlusBold.warning_2,
                color: TwendeColors.ink,
              ),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(
                child: Text(
                  approved ? 'Verified' : 'Get verified',
                  style: TwendeTypography.title,
                ),
              ),
              const Icon(
                IconsaxPlusLinear.arrow_right_3,
                color: TwendeColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.xl),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TwendeTypography.caption.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: TwendeSpacing.sm),
          Text(value, style: TwendeTypography.display.copyWith(fontSize: 32)),
        ],
      ),
    );
  }
}

class _AnalyticsRow extends StatelessWidget {
  const _AnalyticsRow({
    required this.data,
    required this.localListings,
    required this.localBookings,
  });
  final Map<String, dynamic>? data;
  final int localListings;
  final int localBookings;

  @override
  Widget build(BuildContext context) {
    // Server-scoped metrics if available, else fall back to local aggregates.
    final aov = data?['avg_order_value'] ?? '—';
    final conv = data?['conversion_rate'] ?? '—';
    final cancel = data?['cancellation_rate'] ?? '—';
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.xl),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE',
            style: TwendeTypography.caption.copyWith(letterSpacing: 1.5),
          ),
          const SizedBox(height: TwendeSpacing.md),
          Row(
            children: [
              Expanded(
                child: _Metric(label: 'AOV', value: '$aov'),
              ),
              Expanded(
                child: _Metric(label: 'Conv', value: '$conv'),
              ),
              Expanded(
                child: _Metric(label: 'Cancel', value: '$cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TwendeTypography.h2),
        Text(label, style: TwendeTypography.caption),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TwendeColors.surfaceMuted,
      borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(TwendeSpacing.lg),
          child: Row(
            children: [
              Icon(icon, color: TwendeColors.ink),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(child: Text(label, style: TwendeTypography.title)),
              const Icon(
                IconsaxPlusLinear.arrow_right_3,
                color: TwendeColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
