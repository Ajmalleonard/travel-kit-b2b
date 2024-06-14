import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_plus/iconsax_plus.dart';

import '../../design/colors.dart';

class RootShell extends StatelessWidget {
  const RootShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (IconsaxPlusLinear.home_2, IconsaxPlusBold.home_2, 'Home', '/'),
    (IconsaxPlusLinear.note_2, IconsaxPlusBold.note_2, 'Listings', '/listings'),
    (IconsaxPlusLinear.calendar, IconsaxPlusBold.calendar, 'Bookings', '/bookings'),
    (IconsaxPlusLinear.user, IconsaxPlusBold.user, 'Profile', '/profile'),
  ];

  int _idxFor(String loc) {
    if (loc.startsWith('/listings')) return 1;
    if (loc.startsWith('/bookings')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _idxFor(loc);
    return Scaffold(
      body: SafeArea(bottom: false, child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: idx,
        onDestinationSelected: (i) => context.go(_tabs[i].$4),
        backgroundColor: TwendeColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: TwendeColors.surfaceMuted,
        destinations: [
          for (int i = 0; i < _tabs.length; i++)
            NavigationDestination(
              icon: Icon(_tabs[i].$1, color: TwendeColors.textTertiary),
              selectedIcon: Icon(_tabs[i].$2, color: TwendeColors.ink),
              label: _tabs[i].$3,
            ),
        ],
      ),
    );
  }
}
// trust the process trust - 21211