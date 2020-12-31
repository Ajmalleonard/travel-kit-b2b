import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({super.key, required this.listingId});
  final String listingId;

  @override
  ConsumerState<EditListingScreen> createState() =>
      _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  final _desc = TextEditingController();
  final _capacity = TextEditingController();
  final _duration = TextEditingController();
  bool _loaded = false;
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _price.dispose();
    _desc.dispose();
    _capacity.dispose();
    _duration.dispose();
    super.dispose();
  }

  void _prefill() {
    final l = ref.read(listingByIdProvider(widget.listingId)).value;
    if (l == null || _loaded) return;
    _title.text = l.title;
    _price.text = l.price.toStringAsFixed(0);
    _desc.text = l.description ?? '';
    if (l.capacity != null) _capacity.text = '${l.capacity}';
    if (l.durationHours != null) _duration.text = '${l.durationHours}';
    _loaded = true;
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(listingsRepoProvider).update(widget.listingId, {
        'title': _title.text.trim(),
        'price': double.tryParse(_price.text) ?? 0,
        'description': _desc.text.trim(),
        if (_capacity.text.isNotEmpty)
          'capacity': int.tryParse(_capacity.text),
        if (_duration.text.isNotEmpty)
          'duration_hours': int.tryParse(_duration.text),
      });
      ref.invalidate(myListingsProvider);
      ref.invalidate(listingByIdProvider(widget.listingId));
      if (!mounted) return;
      AppSheet.show(context,
          title: 'Saved',
          kind: SheetKind.success,
          onPrimary: () => context.pop());
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncListing = ref.watch(listingByIdProvider(widget.listingId));
    asyncListing.whenData((_) => _prefill());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit listing'),
        leading: IconButton(
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
          onPressed: () => context.pop(),
        ),
      ),
      body: asyncListing.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(TwendeSpacing.xl),
            child: Text("Couldn't load: $e",
                style:
                    TwendeTypography.body.copyWith(color: TwendeColors.danger)),
          ),
        ),
        data: (listing) {
          if (listing == null) {
            return Center(
                child: Text('Not found', style: TwendeTypography.body));
          }
          return ListView(
            padding: const EdgeInsets.all(TwendeSpacing.xxl),
            children: [
              Text('Title', style: TwendeTypography.label),
              const SizedBox(height: TwendeSpacing.sm),
              TextField(controller: _title),
              const SizedBox(height: TwendeSpacing.md),
              Text('Price (USD)', style: TwendeTypography.label),
              const SizedBox(height: TwendeSpacing.sm),
              TextField(
                  controller: _price, keyboardType: TextInputType.number),
              const SizedBox(height: TwendeSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Capacity', style: TwendeTypography.label),
                        const SizedBox(height: TwendeSpacing.sm),
                        TextField(
                            controller: _capacity,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                  const SizedBox(width: TwendeSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hours', style: TwendeTypography.label),
                        const SizedBox(height: TwendeSpacing.sm),
                        TextField(
                            controller: _duration,
                            keyboardType: TextInputType.number),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TwendeSpacing.md),
              Text('Description', style: TwendeTypography.label),
              const SizedBox(height: TwendeSpacing.sm),
              TextField(controller: _desc, maxLines: 4),
              const SizedBox(height: TwendeSpacing.xxxl),
              ElevatedButton(
                onPressed: _busy ? null : _save,
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.2))
                    : const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
