import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/api_config.dart';
import '../../auth/auth_controller.dart';
import '../../design/colors.dart';
import '../../design/spacing.dart';
import '../../design/typography.dart';
import '../../shared/app_sheet.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _register = false;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final auth = ref.read(authControllerProvider.notifier);
    try {
      if (_register) {
        await auth.register(
          email: _email.text.trim(),
          password: _password.text,
          fullName: _name.text.trim().isEmpty ? 'Partner' : _name.text.trim(),
        );
      } else {
        await auth.signIn(
            email: _email.text.trim(), password: _password.text);
      }
    } catch (e) {
      if (mounted) AppSheet.error(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            TwendeSpacing.xxl,
            TwendeSpacing.mega,
            TwendeSpacing.xxl,
            TwendeSpacing.xxl,
          ),
          children: [
            // Dark hero block (Permata-style card).
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: TwendeColors.ink,
                borderRadius: BorderRadius.circular(TwendeSpacing.radiusLg),
              ),
              padding: const EdgeInsets.all(TwendeSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TWENDE',
                      style: TwendeTypography.h2.copyWith(
                        color: TwendeColors.textInverse,
                        letterSpacing: 4,
                      )),
                  const Spacer(),
                  Text('Partners',
                      style: TwendeTypography.h1.copyWith(
                        color: TwendeColors.textInverse,
                        fontSize: 28,
                      )),
                ],
              ),
            ),
            const SizedBox(height: TwendeSpacing.xxxl),
            Text(_register ? 'Create account' : 'Sign in',
                style: TwendeTypography.h1),
            const SizedBox(height: TwendeSpacing.xl),
            if (_register) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(hintText: 'Full name'),
              ),
              const SizedBox(height: TwendeSpacing.md),
            ],
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            const SizedBox(height: TwendeSpacing.md),
            TextField(
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password'),
            ),
            const SizedBox(height: TwendeSpacing.xxl),
            ElevatedButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.2),
                    )
                  : Text(_register ? 'Create' : 'Sign in'),
            ),
            const SizedBox(height: TwendeSpacing.sm),
            TextButton(
              onPressed: () => setState(() => _register = !_register),
              child: Text(_register ? 'Have an account?' : 'New here?'),
            ),
            if (ApiConfig.devBypassAuth) ...[
              const SizedBox(height: TwendeSpacing.xl),
              FilledButton(
                onPressed: () =>
                    ref.read(authControllerProvider.notifier).signInAsPreview(),
                child: const Text('Preview'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
