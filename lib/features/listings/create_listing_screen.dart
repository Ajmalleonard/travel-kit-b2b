import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../api/models.dart';
import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';

class CreateListingScreen extends ConsumerStatefulWidget {
  const CreateListingScreen({super.key});

  @override
  ConsumerState<CreateListingScreen> createState() =>
      _CreateListingScreenState();
}

class _CreateListingScreenState extends ConsumerState<CreateListingScreen> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _capacity = TextEditingController();
  final _duration = TextEditingController();
  String _type = 'experience';
  Destination? _dest;
  bool _busy = false;

  static const _types = [
    ('site', 'Site'),
    ('experience', 'Experience'),
    ('trip', 'Trip'),
    ('safari', 'Safari'),
  ];

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _capacity.dispose();
    _duration.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_title.text.trim().isEmpty || _dest == null) {
      AppSheet.show(
        context,
        title: 'Missing fields',
        message: 'Title and destination are required.',
        kind: SheetKind.warning,
      );
      return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(listingsRepoProvider)
          .create(
            title: _title.text.trim(),
            type: _type,
            price: double.tryParse(_price.text) ?? 0,
            destinationId: _dest!.id,
            description: _desc.text.isEmpty ? null : _desc.text,
            capacity: int.tryParse(_capacity.text),
            durationHours: int.tryParse(_duration.text),
          );
      ref.invalidate(myListingsProvider);
      if (!mounted) return;
      AppSheet.show(
        context,
        title: 'Saved',
        message: 'Created as draft.',
        kind: SheetKind.success,
        onPrimary: () => context.pop(),
      );
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dests = ref.watch(destinationsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('New listing'),
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
          Text('Type', style: TwendeTypography.label),
          const SizedBox(height: TwendeSpacing.sm),
          Wrap(
            spacing: TwendeSpacing.sm,
            runSpacing: TwendeSpacing.sm,
            children: [
              for (final t in _types)
                _Pill(
                  label: t.$2,
                  selected: _type == t.$1,
                  onTap: () => setState(() => _type = t.$1),
                ),
            ],
          ),
          const SizedBox(height: TwendeSpacing.xl),
          TextField(
            controller: _title,
            decoration: const InputDecoration(hintText: 'Title'),
          ),
          const SizedBox(height: TwendeSpacing.md),
          dests.when(
            loading: () => const LinearProgressIndicator(minHeight: 2),
            error: (e, _) => Text(
              "Couldn't load destinations: $e",
              style: TwendeTypography.caption,
            ),
            data: (list) => DropdownButtonFormField<Destination>(
              initialValue: _dest,
              hint: const Text('Destination'),
              items: [
                for (final d in list)
                  DropdownMenuItem(value: d, child: Text(d.name)),
              ],
              onChanged: (v) => setState(() => _dest = v),
            ),
          ),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'Price (USD)'),
          ),
          const SizedBox(height: TwendeSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _capacity,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Capacity'),
                ),
              ),
              const SizedBox(width: TwendeSpacing.md),
              Expanded(
                child: TextField(
                  controller: _duration,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Hours'),
                ),
              ),
            ],
          ),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _desc,
            maxLines: 4,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(height: TwendeSpacing.xxxl),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.2,
                    ),
                  )
                : const Text('Create'),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected ? TwendeColors.ink : TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusPill),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: TwendeSpacing.lg,
              vertical: TwendeSpacing.sm,
            ),
            child: Text(
              label,
              style: TwendeTypography.chip.copyWith(
                color: selected
                    ? TwendeColors.textInverse
                    : TwendeColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
