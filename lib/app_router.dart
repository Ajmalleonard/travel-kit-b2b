import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'auth/auth_controller.dart';
import 'design/colors.dart';
import 'design/spacing.dart';
import 'design/typography.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/bookings/bookings_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/home/root_shell.dart';
import 'features/listings/availability_screen.dart';
import 'features/listings/create_listing_screen.dart';
import 'features/listings/edit_listing_screen.dart';
import 'features/listings/listings_screen.dart';
import 'features/listings/reviews_screen.dart';
import 'features/onboarding/onboarding_flow.dart';
import 'features/onboarding/onboarding_store.dart';
import 'features/profile/profile_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/verification/verification_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: _Listenable(ref),
    errorBuilder: (_, state) => _RouterError(error: state.error),
    redirect: (ctx, state) {
      final auth = ref.read(authControllerProvider);
      final onb = ref.read(onboardingControllerProvider);
      final loc = state.matchedLocation;
      final splash = loc == '/splash';
      final signIn = loc == '/sign-in';
      final onboarding = loc.startsWith('/onboarding');

      if (auth.status == AuthStatus.unknown) return splash ? null : '/splash';
      if (auth.status == AuthStatus.signedOut) {
        return signIn ? null : '/sign-in';
      }
      if (!onb.completed) return onboarding ? null : '/onboarding';
      if (splash || signIn || onboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, _) => const SplashScreen()),
      GoRoute(path: '/sign-in', builder: (_, _) => const SignInScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingFlow()),
      GoRoute(
          path: '/listings/new',
          builder: (_, _) => const CreateListingScreen()),
      GoRoute(
        path: '/listings/:id/edit',
        builder: (_, state) =>
            EditListingScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/listings/:id/availability',
        builder: (_, state) =>
            AvailabilityScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/listings/:id/reviews',
        builder: (_, state) =>
            ReviewsScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
          path: '/verification',
          builder: (_, _) => const VerificationScreen()),
      ShellRoute(
        builder: (_, _, child) => RootShell(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
          GoRoute(
              path: '/listings', builder: (_, _) => const ListingsScreen()),
          GoRoute(path: '/bookings', builder: (_, _) => const BookingsScreen()),
          GoRoute(path: '/profile', builder: (_, _) => const ProfileScreen()),
        ],
      ),
    ],
  );
});

class _Listenable extends ChangeNotifier {
  _Listenable(Ref ref) {
    ref.listen(authControllerProvider, (_, _) => notifyListeners());
    ref.listen(onboardingControllerProvider, (_, _) => notifyListeners());
  }
}

class _RouterError extends StatelessWidget {
  const _RouterError({this.error});
  final Exception? error;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(TwendeSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Something went wrong', style: TwendeTypography.h2),
              const SizedBox(height: TwendeSpacing.sm),
              Text(error?.toString() ?? 'Unknown',
                  style: TwendeTypography.body
                      .copyWith(color: TwendeColors.danger)),
              const SizedBox(height: TwendeSpacing.xl),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
