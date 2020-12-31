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
import '../../shared/cards.dart';

class ListingsScreen extends ConsumerStatefulWidget {
  const ListingsScreen({super.key});

  @override
  ConsumerState<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends ConsumerState<ListingsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final listings = ref.watch(myListingsProvider);
    final all = listings.value ?? const <Listing>[];
    final list = _filter == 'all'
        ? all
        : all.where((l) => l.type == _filter).toList();
    final money = NumberFormat.simpleCurrency(name: 'USD');

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async => ref.invalidate(myListingsProvider),
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              TwendeSpacing.xxl,
              TwendeSpacing.xxl,
              TwendeSpacing.xxl,
              TwendeSpacing.xxxl +
                  72 +
                  MediaQuery.viewPaddingOf(context).bottom,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Listings', style: TwendeTypography.display),
                  ),
                  IconButton(
                    onPressed: () => context.push('/listings/new'),
                    icon: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: TwendeColors.ink,
                        borderRadius: BorderRadius.circular(
                          TwendeSpacing.radiusPill,
                        ),
                      ),
                      child: const Icon(
                        IconsaxPlusBold.add,
                        color: TwendeColors.textInverse,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TwendeSpacing.lg),
              _FilterBar(
                value: _filter,
                onChanged: (v) => setState(() => _filter = v),
              ),
              const SizedBox(height: TwendeSpacing.lg),
              if (listings.isLoading && all.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(TwendeSpacing.xxxl),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: TwendeSpacing.mega,
                  ),
                  child: Center(
                    child: Text(
                      'No listings yet',
                      style: TwendeTypography.body,
                    ),
                  ),
                )
              else
                for (final l in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: TwendeSpacing.md),
                    child: _ListingCard(listing: l, money: money),
                  ),
            ],
          ),
        ),
        // Floating "Filter" pill at the bottom, matching the reference.
        Positioned(
          left: 0,
          right: 0,
          bottom: MediaQuery.viewPaddingOf(context).bottom + TwendeSpacing.lg,
          child: Center(
            child: _FloatingPill(
              icon: IconsaxPlusBold.setting_4,
              label: 'Filter',
              onTap: () => _openFilters(context),
            ),
          ),
        ),
      ],
    );
  }

  void _openFilters(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(
        current: _filter,
        onPick: (v) => setState(() => _filter = v),
      ),
    );
  }
}

class _ListingCard extends ConsumerWidget {
  const _ListingCard({required this.listing, required this.money});
  final Listing listing;
  final NumberFormat money;

  String get _typeLabel => switch (listing.type) {
    'site' => 'Site',
    'experience' => 'Experience',
    'trip' => 'Trip',
    'safari' => 'Safari',
    _ => listing.type,
  };

  IconData get _typeIcon => switch (listing.type) {
    'site' => IconsaxPlusBold.building_3,
    'experience' => IconsaxPlusBold.magicpen,
    'trip' => IconsaxPlusBold.map,
    'safari' => IconsaxPlusBold.tree,
    _ => IconsaxPlusBold.note_2,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subtitle = [
      _typeLabel,
      if (listing.destinationName != null) listing.destinationName!,
    ].join(' · ');

    return ReferenceCard(
      avatar: InitialAvatar(text: listing.title),
      title: listing.title,
      subtitle: subtitle,
      chip: listing.isActive ? 'Live' : 'Draft',
      middle: Row(
        children: [
          Icon(_typeIcon, color: TwendeColors.textTertiary, size: 18),
          const SizedBox(width: TwendeSpacing.sm),
          if (listing.durationHours != null)
            _Pellet(text: '${listing.durationHours}h'),
          if (listing.capacity != null)
            _Pellet(text: '${listing.capacity} guests'),
        ],
      ),
      priceLabel: money.format(listing.price),
      priceCaption: 'per person',
      ctaLabel: 'Manage',
      onCta: () => _openSheet(context, ref),
    );
  }

  void _openSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      useSafeArea: false,
      isScrollControlled: true,
      builder: (_) => _ManageSheet(listing: listing),
    );
  }
}

class _ManageSheet extends ConsumerWidget {
  const _ManageSheet({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          Text(listing.title, style: TwendeTypography.h2),
          const SizedBox(height: TwendeSpacing.xl),
          _Action(
            icon: IconsaxPlusBold.edit,
            label: 'Edit listing',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/listings/${listing.id}/edit');
            },
          ),
          _Action(
            icon: IconsaxPlusBold.calendar_2,
            label: 'Availability',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/listings/${listing.id}/availability');
            },
          ),
          _Action(
            icon: IconsaxPlusBold.star_1,
            label: 'Reviews',
            onTap: () {
              Navigator.of(context).pop();
              context.push('/listings/${listing.id}/reviews');
            },
          ),
          _Action(
            icon: listing.isActive
                ? IconsaxPlusBold.eye_slash
                : IconsaxPlusBold.eye,
            label: listing.isActive ? 'Hide (Draft)' : 'Publish (Live)',
            onTap: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(listingsRepoProvider).update(listing.id, {
                  'is_active': !listing.isActive,
                });
                ref.invalidate(myListingsProvider);
                if (context.mounted) {
                  AppSheet.toast(
                    context,
                    listing.isActive ? 'Set to draft' : 'Set live',
                    kind: SheetKind.success,
                  );
                }
              } catch (e) {
                if (context.mounted) AppSheet.error(context, e);
              }
            },
          ),
          _Action(
            icon: IconsaxPlusBold.trash,
            label: 'Delete',
            destructive: true,
            onTap: () async {
              Navigator.of(context).pop();
              try {
                await ref.read(listingsRepoProvider).delete(listing.id);
                ref.invalidate(myListingsProvider);
                if (context.mounted) {
                  AppSheet.toast(context, 'Deleted', kind: SheetKind.success);
                }
              } catch (e) {
                if (context.mounted) AppSheet.error(context, e);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = destructive ? TwendeColors.danger : TwendeColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: TwendeSpacing.md),
          child: Row(
            children: [
              Icon(icon, color: c),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TwendeTypography.title.copyWith(color: c),
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

class _Pellet extends StatelessWidget {
  const _Pellet({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: TwendeSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      ),
      child: Text(
        text,
        style: TwendeTypography.caption.copyWith(letterSpacing: 0),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  static const _f = [
    ('all', 'All'),
    ('site', 'Sites'),
    ('experience', 'Experiences'),
    ('trip', 'Trips'),
    ('safari', 'Safari'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _f.length,
        separatorBuilder: (_, _) => const SizedBox(width: TwendeSpacing.sm),
        itemBuilder: (_, i) {
          final sel = value == _f[i].$1;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: sel ? TwendeColors.ink : TwendeColors.surfaceMuted,
              borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
              child: InkWell(
                borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
                onTap: () => onChanged(_f[i].$1),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TwendeSpacing.lg,
                    vertical: TwendeSpacing.sm,
                  ),
                  child: Center(
                    child: Text(
                      _f[i].$2,
                      style: TwendeTypography.chip.copyWith(
                        color: sel
                            ? TwendeColors.textInverse
                            : TwendeColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FloatingPill extends StatelessWidget {
  const _FloatingPill({
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
      color: TwendeColors.ink,
      borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: TwendeSpacing.xxl,
            vertical: TwendeSpacing.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: TwendeColors.textInverse, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TwendeTypography.button.copyWith(
                  color: TwendeColors.textInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatelessWidget {
  const _FiltersSheet({required this.current, required this.onPick});
  final String current;
  final ValueChanged<String> onPick;

  static const _opts = [
    ('all', 'All listings'),
    ('site', 'Sites'),
    ('experience', 'Experiences'),
    ('trip', 'Trips'),
    ('safari', 'Safari'),
  ];

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
          Text('Filter listings', style: TwendeTypography.h2),
          const SizedBox(height: TwendeSpacing.xl),
          for (final o in _opts)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  onPick(o.$1);
                  Navigator.of(context).pop();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: TwendeSpacing.md,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(o.$2, style: TwendeTypography.title),
                      ),
                      if (current == o.$1)
                        const Icon(
                          IconsaxPlusBold.tick_circle,
                          color: TwendeColors.ink,
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
