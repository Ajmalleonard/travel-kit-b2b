import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:intl/intl.dart';

import '../../api/models.dart';
import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';

class AvailabilityScreen extends ConsumerStatefulWidget {
  const AvailabilityScreen({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends ConsumerState<AvailabilityScreen> {
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  final _capacity = TextEditingController(text: '10');

  @override
  void dispose() {
    _capacity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listing = ref.watch(listingByIdProvider(widget.listingId));
    final slots = ref.watch(availabilityForListingProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability'),
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          TwendeSpacing.xxl,
          TwendeSpacing.xl,
          TwendeSpacing.xxl,
          TwendeSpacing.xxxl,
        ),
        children: [
          Text(listing.value?.title ?? 'Listing', style: TwendeTypography.h2),
          Text('Pick a date and set capacity', style: TwendeTypography.body),
          const SizedBox(height: TwendeSpacing.xl),
          _MonthHeader(
            month: _focused,
            onPrev: () => setState(
              () => _focused = DateTime(_focused.year, _focused.month - 1),
            ),
            onNext: () => setState(
              () => _focused = DateTime(_focused.year, _focused.month + 1),
            ),
          ),
          const SizedBox(height: TwendeSpacing.lg),
          _MonthGrid(
            month: _focused,
            selected: _selected,
            booked: slots.value ?? const [],
            onPick: (d) => setState(() => _selected = d),
          ),
          const SizedBox(height: TwendeSpacing.xl),
          if (_selected != null) ...[
            Text(
              'Capacity for ${DateFormat('MMM d, yyyy').format(_selected!)}',
              style: TwendeTypography.label,
            ),
            const SizedBox(height: TwendeSpacing.sm),
            TextField(
              controller: _capacity,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: 'e.g. 10'),
            ),
            const SizedBox(height: TwendeSpacing.lg),
            ElevatedButton(onPressed: _add, child: const Text('Add slot')),
            const SizedBox(height: TwendeSpacing.md),
          ],
          if ((slots.value ?? const []).isNotEmpty) ...[
            const SizedBox(height: TwendeSpacing.xl),
            Text('Existing slots', style: TwendeTypography.h3),
            const SizedBox(height: TwendeSpacing.md),
            for (final s in slots.value!)
              Padding(
                padding: const EdgeInsets.only(bottom: TwendeSpacing.sm),
                child: _SlotRow(slot: s, onDelete: () => _remove(s)),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _add() async {
    final cap = int.tryParse(_capacity.text);
    if (_selected == null || cap == null || cap <= 0) {
      AppSheet.show(
        context,
        title: 'Pick a date and capacity',
        kind: SheetKind.warning,
      );
      return;
    }
    try {
      await ref
          .read(availabilityRepoProvider)
          .add(listingId: widget.listingId, date: _selected!, capacity: cap);
      ref.invalidate(availabilityForListingProvider(widget.listingId));
      if (mounted) {
        AppSheet.toast(context, 'Added', kind: SheetKind.success);
      }
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    }
  }

  Future<void> _remove(AvailabilitySlot s) async {
    try {
      await ref
          .read(availabilityRepoProvider)
          .remove(listingId: widget.listingId, availId: s.id);
      ref.invalidate(availabilityForListingProvider(widget.listingId));
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    }
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            DateFormat.yMMMM().format(month),
            style: TwendeTypography.h3,
          ),
        ),
        IconButton(
          onPressed: onPrev,
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(IconsaxPlusLinear.arrow_right_3),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.selected,
    required this.booked,
    required this.onPick,
  });
  final DateTime month;
  final DateTime? selected;
  final List<AvailabilitySlot> booked;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    // 0 = Monday; we want week starting Mon.
    final leadingBlanks = (first.weekday - 1) % 7;

    final cells = <Widget>[];
    for (int i = 0; i < leadingBlanks; i++) {
      cells.add(const SizedBox());
    }
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      final isBooked = booked.any(
        (b) =>
            b.date.year == date.year &&
            b.date.month == date.month &&
            b.date.day == date.day,
      );
      final isSelected =
          selected != null &&
          selected!.year == date.year &&
          selected!.month == date.month &&
          selected!.day == date.day;
      final isPast = date.isBefore(
        DateTime.now().subtract(const Duration(days: 1)),
      );
      cells.add(
        _Day(
          day: d,
          booked: isBooked,
          selected: isSelected,
          disabled: isPast,
          onTap: isPast ? null : () => onPick(date),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (final w in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(
                child: Center(
                  child: Text(
                    w,
                    style: TextStyle(
                      color: TwendeColors.textTertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: TwendeSpacing.sm),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          children: cells,
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.day,
    required this.booked,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });
  final int day;
  final bool booked;
  final bool selected;
  final bool disabled;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (selected) {
      bg = TwendeColors.ink;
      fg = TwendeColors.textInverse;
    } else if (booked) {
      bg = TwendeColors.successBg;
      fg = TwendeColors.success;
    } else {
      bg = TwendeColors.surfaceMuted;
      fg = disabled ? TwendeColors.textTertiary : TwendeColors.textPrimary;
    }
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusMd),
        onTap: onTap,
        child: Center(
          child: Text(
            '$day',
            style: TwendeTypography.title.copyWith(color: fg, fontSize: 14),
          ),
        ),
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.onDelete});
  final AvailabilitySlot slot;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TwendeSpacing.md),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMM d, EEE').format(slot.date),
                  style: TwendeTypography.title,
                ),
                Text(
                  slot.remaining != null
                      ? '${slot.remaining} / ${slot.capacity} left'
                      : '${slot.capacity} capacity',
                  style: TwendeTypography.body,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(IconsaxPlusBold.trash, color: TwendeColors.danger),
          ),
        ],
      ),
    );
  }
}
