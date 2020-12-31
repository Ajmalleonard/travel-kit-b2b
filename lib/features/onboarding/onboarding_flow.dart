import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';
import 'onboarding_store.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pages = PageController();
  int _i = 0;
  static const _total = 4;

  void _next() {
    if (_i < _total - 1) {
      _pages.nextPage(
          duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final a = ref.read(onboardingControllerProvider);
    if (a.kind == null || a.offerings.isEmpty) {
      AppSheet.show(context,
          title: 'Pick one',
          message: 'Tell us who you are and what you offer.',
          kind: SheetKind.warning);
      return;
    }
    if ((a.businessName ?? '').trim().isEmpty) {
      AppSheet.show(context,
          title: 'Business name',
          message: 'Add your business name to continue.',
          kind: SheetKind.warning);
      return;
    }
    await ref.read(onboardingControllerProvider.notifier).complete();
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 64,
        leading: _i == 0
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: TwendeSpacing.xl),
                child: IconButton(
                  onPressed: () => _pages.previousPage(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOut),
                  icon: const Icon(IconsaxPlusLinear.arrow_left_2),
                ),
              ),
        title: Text('${_i + 1} of $_total',
            style: TwendeTypography.caption),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: TwendeSpacing.lg),
            child: TextButton(onPressed: _finish, child: const Text('Skip')),
          ),
        ],
      ),
      body: PageView(
        controller: _pages,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _i = i),
        children: const [
          _StepKind(),
          _StepOfferings(),
          _StepRegion(),
          _StepBusiness(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
            TwendeSpacing.xxl, 0, TwendeSpacing.xxl, TwendeSpacing.xl),
        child: ElevatedButton(
          onPressed: _next,
          child: Text(_i == _total - 1 ? 'Finish' : 'Continue'),
        ),
      ),
    );
  }
}

class _Frame extends StatelessWidget {
  const _Frame({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        TwendeSpacing.xxl,
        TwendeSpacing.xxl,
        TwendeSpacing.xxl,
        TwendeSpacing.xxxl,
      ),
      children: [
        Text(title, style: TwendeTypography.display),
        const SizedBox(height: TwendeSpacing.xxl),
        child,
      ],
    );
  }
}

class _StepKind extends ConsumerWidget {
  const _StepKind();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(onboardingControllerProvider).kind;
    const items = [
      (PartnerKind.solo, 'Solo guide', IconsaxPlusBold.user_tick),
      (PartnerKind.agency, 'Agency', IconsaxPlusBold.people),
      (PartnerKind.hotel, 'Hotel', IconsaxPlusBold.house_2),
    ];
    return _Frame(
      title: 'Who are you?',
      child: Column(
        children: [
          for (final e in items)
            Padding(
              padding: const EdgeInsets.only(bottom: TwendeSpacing.md),
              child: _ChoiceRow(
                label: e.$2,
                icon: e.$3,
                selected: sel == e.$1,
                onTap: () => ref
                    .read(onboardingControllerProvider.notifier)
                    .setKind(e.$1),
              ),
            ),
        ],
      ),
    );
  }
}

class _StepOfferings extends ConsumerWidget {
  const _StepOfferings();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(onboardingControllerProvider).offerings;
    final n = ref.read(onboardingControllerProvider.notifier);
    const items = [
      ('sites', 'Sites'),
      ('experiences', 'Experiences'),
      ('trips', 'Trips'),
      ('safari', 'Safari'),
      ('stays', 'Stays'),
      ('cars', 'Cars'),
    ];
    return _Frame(
      title: 'What do you offer?',
      child: Wrap(
        spacing: TwendeSpacing.sm,
        runSpacing: TwendeSpacing.sm,
        children: [
          for (final i in items)
            _PillChip(
              label: i.$2,
              selected: sel.contains(i.$1),
              onTap: () => n.toggleOffering(i.$1),
            ),
        ],
      ),
    );
  }
}

class _StepRegion extends ConsumerWidget {
  const _StepRegion();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sel = ref.watch(onboardingControllerProvider).region;
    final n = ref.read(onboardingControllerProvider.notifier);
    const regions = [
      'Stone Town',
      'North Zanzibar',
      'East Coast',
      'South Coast',
      'Pemba',
      'Arusha',
      'Serengeti',
      'Ngorongoro',
      'Kilimanjaro',
      'Dar es Salaam',
    ];
    return _Frame(
      title: 'Where do you work?',
      child: Wrap(
        spacing: TwendeSpacing.sm,
        runSpacing: TwendeSpacing.sm,
        children: [
          for (final r in regions)
            _PillChip(
              label: r,
              selected: sel == r,
              onTap: () => n.setRegion(r),
            ),
        ],
      ),
    );
  }
}

class _StepBusiness extends ConsumerStatefulWidget {
  const _StepBusiness();
  @override
  ConsumerState<_StepBusiness> createState() => _StepBusinessState();
}

class _StepBusinessState extends ConsumerState<_StepBusiness> {
  late final TextEditingController _name;
  late final TextEditingController _phone;

  @override
  void initState() {
    super.initState();
    final a = ref.read(onboardingControllerProvider);
    _name = TextEditingController(text: a.businessName ?? '');
    _phone = TextEditingController(text: a.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Frame(
      title: 'Your business',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Business name'),
            onChanged: (v) => ref
                .read(onboardingControllerProvider.notifier)
                .setBusiness(name: v, phone: _phone.text),
          ),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone'),
            onChanged: (v) => ref
                .read(onboardingControllerProvider.notifier)
                .setBusiness(name: _name.text, phone: v),
          ),
        ],
      ),
    );
  }
}

/// ANIMATION (2/3): selection state crossfades when picked.
class _ChoiceRow extends StatelessWidget {
  const _ChoiceRow({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected ? TwendeColors.ink : TwendeColors.surfaceMuted,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
        child: InkWell(
          borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(TwendeSpacing.xl),
            child: Row(
              children: [
                Icon(icon,
                    color: selected
                        ? TwendeColors.textInverse
                        : TwendeColors.textPrimary),
                const SizedBox(width: TwendeSpacing.md),
                Expanded(
                  child: Text(label,
                      style: TwendeTypography.h3.copyWith(
                        color: selected
                            ? TwendeColors.textInverse
                            : TwendeColors.textPrimary,
                      )),
                ),
                if (selected)
                  const Icon(IconsaxPlusBold.tick_circle,
                      color: TwendeColors.textInverse),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  const _PillChip({
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
              horizontal: TwendeSpacing.xl,
              vertical: TwendeSpacing.md,
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
