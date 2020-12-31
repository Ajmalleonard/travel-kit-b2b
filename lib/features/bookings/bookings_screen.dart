import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../api/models.dart';
import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';
import '../../shared/cards.dart';

class BookingsScreen extends ConsumerStatefulWidget {
  const BookingsScreen({super.key});

  @override
  ConsumerState<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends ConsumerState<BookingsScreen> {
  String _seg = 'pending';

  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(incomingBookingsProvider);
    final list = (bookings.value ?? const <Booking>[])
        .where((b) => _seg == 'all' || b.status == _seg)
        .toList();

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(incomingBookingsProvider),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          TwendeSpacing.xxl,
          TwendeSpacing.xxl,
          TwendeSpacing.xxl,
          TwendeSpacing.xxxl,
        ),
        children: [
          Text('Bookings', style: TwendeTypography.display),
          const SizedBox(height: TwendeSpacing.xl),
          _Segments(value: _seg, onChanged: (v) => setState(() => _seg = v)),
          const SizedBox(height: TwendeSpacing.xl),
          if (bookings.isLoading)
            const Padding(
              padding: EdgeInsets.all(TwendeSpacing.xxxl),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (!bookings.isLoading && list.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: TwendeSpacing.mega),
              child: Center(
                child: Text('No $_seg bookings', style: TwendeTypography.body),
              ),
            ),
          for (final b in list)
            Padding(
              padding: const EdgeInsets.only(bottom: TwendeSpacing.md),
              child: _BookingCard(booking: b),
            ),
        ],
      ),
    );
  }
}

class _Segments extends StatelessWidget {
  const _Segments({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;
  static const _opts = [
    ('pending', 'Pending'),
    ('confirmed', 'Confirmed'),
    ('all', 'All'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      ),
      child: Row(
        children: [
          for (final o in _opts)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),

                decoration: BoxDecoration(
                  color: value == o.$1 ? TwendeColors.ink : Colors.transparent,
                  borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(
                      TwendeSpacing.radiusPill,
                    ),
                    onTap: () => onChanged(o.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: TwendeSpacing.sm,
                      ),
                      child: Center(
                        child: Text(
                          o.$2,
                          style: TwendeTypography.chip.copyWith(
                            fontWeight: FontWeight.w600,
                            color: value == o.$1
                                ? TwendeColors.textInverse
                                : TwendeColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final money = NumberFormat.simpleCurrency(name: 'USD');
    final date = DateFormat('MMM d, EEE').format(booking.travelDate);
    final time = DateFormat.jm().format(booking.travelDate);

    return ReferenceCard(
      avatar: InitialAvatar(text: booking.travelerName),
      title: booking.listingTitle,
      subtitle: '${booking.travelerName} · ${booking.guests} guests',
      chip: date,
      middle: TimeRangeRow(
        leading: time,
        middle: '${booking.guests}p',
        trailing: booking.status.toUpperCase(),
      ),
      priceLabel: money.format(booking.total),
      priceCaption: 'Total',
      ctaLabel: booking.status == 'pending' ? 'Confirm' : 'View',
      onCta: () => booking.status == 'pending'
          ? _confirm(context, ref)
          : _openDetail(context, ref),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(operatorRepoProvider).confirmBooking(booking.id);
      ref.invalidate(incomingBookingsProvider);
      if (context.mounted) {
        AppSheet.toast(context, 'Confirmed', kind: SheetKind.success);
      }
    } catch (e) {
      if (context.mounted) AppSheet.error(context, e);
    }
  }

  void _openDetail(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      isScrollControlled: true,
      builder: (_) => _DetailSheet(booking: booking),
    );
  }
}

class _DetailSheet extends ConsumerWidget {
  const _DetailSheet({required this.booking});
  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inset = MediaQuery.viewPaddingOf(context).bottom;
    final money = NumberFormat.simpleCurrency(name: 'USD');
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Text(booking.listingTitle, style: TwendeTypography.h2),
          const SizedBox(height: 4),
          Text(
            '${booking.travelerName} · ${DateFormat('MMM d, yyyy').format(booking.travelDate)}',
            style: TwendeTypography.body,
          ),
          const SizedBox(height: TwendeSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _Stat(label: 'Guests', value: '${booking.guests}'),
              ),
              const SizedBox(width: TwendeSpacing.sm),
              Expanded(
                child: _Stat(
                  label: 'Total',
                  value: money.format(booking.total),
                ),
              ),
              const SizedBox(width: TwendeSpacing.sm),
              Expanded(
                child: _Stat(label: 'Status', value: booking.status),
              ),
            ],
          ),
          const SizedBox(height: TwendeSpacing.xxl),
          if (booking.status == 'pending') ...[
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await ref
                      .read(operatorRepoProvider)
                      .confirmBooking(booking.id);
                  ref.invalidate(incomingBookingsProvider);
                  if (context.mounted) {
                    AppSheet.toast(
                      context,
                      'Confirmed',
                      kind: SheetKind.success,
                    );
                  }
                } catch (e) {
                  if (context.mounted) AppSheet.error(context, e);
                }
              },
              child: const Text('Confirm booking'),
            ),
            const SizedBox(height: TwendeSpacing.sm),
          ],
          FilledButton(
            onPressed: () => _confirmCancel(context, ref),
            style: FilledButton.styleFrom(
              backgroundColor: TwendeColors.dangerBg,
              foregroundColor: TwendeColors.danger,
            ),
            child: const Text('Cancel booking'),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop();
    AppSheet.show(
      context,
      title: 'Cancel booking?',
      message: 'The traveler is notified and refunded.',
      kind: SheetKind.warning,
      primaryLabel: 'Cancel it',
      secondaryLabel: 'Keep it',
      onPrimary: () async {
        try {
          await ref.read(bookingsRepoProvider).cancel(booking.id);
          ref.invalidate(incomingBookingsProvider);
          if (context.mounted) {
            AppSheet.toast(context, 'Cancelled', kind: SheetKind.success);
          }
        } catch (e) {
          if (context.mounted) AppSheet.error(context, e);
        }
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.md),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TwendeTypography.caption.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TwendeTypography.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
