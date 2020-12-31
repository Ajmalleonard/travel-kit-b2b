import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../api/repositories.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';
import '../onboarding/onboarding_store.dart';

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() =>
      _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  late final TextEditingController _name;
  late final TextEditingController _license;
  late final TextEditingController _phone;
  bool _id = false;
  bool _doc = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final a = ref.read(onboardingControllerProvider);
    _name = TextEditingController(text: a.businessName ?? '');
    _phone = TextEditingController(text: a.phone ?? '');
    _license = TextEditingController();
  }

  @override
  void dispose() {
    _name.dispose();
    _license.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_name.text.trim().isEmpty || !_id || !_doc) {
      AppSheet.show(context,
          title: 'Missing',
          message: 'Business name and both documents are required.',
          kind: SheetKind.warning);
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(operatorRepoProvider).upsert(
            businessName: _name.text.trim(),
            phone: _phone.text.trim(),
            licenseNumber:
                _license.text.trim().isEmpty ? null : _license.text.trim(),
          );
      ref.invalidate(operatorProfileProvider);
      if (!mounted) return;
      AppSheet.show(context,
          title: 'Submitted',
          message: 'Review in ~24 hours.',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verification'),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(IconsaxPlusLinear.arrow_left_2),
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
          Text('Business', style: TwendeTypography.h3),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _name,
            decoration: const InputDecoration(hintText: 'Business name'),
          ),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _license,
            decoration: const InputDecoration(hintText: 'License number'),
          ),
          const SizedBox(height: TwendeSpacing.md),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone'),
          ),
          const SizedBox(height: TwendeSpacing.xxl),
          Text('Documents', style: TwendeTypography.h3),
          const SizedBox(height: TwendeSpacing.md),
          _Upload(
            label: 'ID',
            uploaded: _id,
            onTap: () => setState(() => _id = true),
          ),
          const SizedBox(height: TwendeSpacing.md),
          _Upload(
            label: 'Business license',
            uploaded: _doc,
            onTap: () => setState(() => _doc = true),
          ),
          const SizedBox(height: TwendeSpacing.xxxl),
          ElevatedButton(
            onPressed: _busy ? null : _submit,
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2.2))
                : const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

/// ANIMATION (3/3): upload tile crossfades to success state.
class _Upload extends StatelessWidget {
  const _Upload({
    required this.label,
    required this.uploaded,
    required this.onTap,
  });
  final String label;
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: uploaded ? TwendeColors.successBg : TwendeColors.surfaceMuted,
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
                Icon(
                  uploaded
                      ? IconsaxPlusBold.tick_circle
                      : IconsaxPlusBold.document_upload,
                  color: uploaded ? TwendeColors.success : TwendeColors.ink,
                ),
                const SizedBox(width: TwendeSpacing.md),
                Expanded(child: Text(label, style: TwendeTypography.title)),
                Text(uploaded ? 'Uploaded' : 'Tap to add',
                    style: TwendeTypography.caption),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
