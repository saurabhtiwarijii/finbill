/// FinBill — Navigation shell with persistent bottom navigation bar.
///
/// ## How it works
///
/// GoRouter's [StatefulShellRoute.indexedStack] manages tab state internally.
/// It provides a [StatefulNavigationShell] widget that:
///   1. Acts as an IndexedStack — keeps all 5 tab widget trees alive.
///   2. Exposes [currentIndex] — the active tab based on the current URL.
///   3. Provides [goBranch()] — switches to a tab via route navigation.
///
/// This widget simply wraps that shell with a styled [BottomNavigationBar].
///
/// ## Why this approach?
///
/// • **Route-based** — Tab changes are URL transitions (`/home` → `/sales`),
///   making deep-linking & back-button behaviour correct automatically.
/// • **State preserved** — Each tab has its own [Navigator] key, so scroll
///   positions, form inputs, and sub-navigation stacks survive tab switches.
/// • **Scalable** — Adding a new tab is a single branch entry in `app_router.dart`.
///
/// File location: lib/navigation_shell.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_strings.dart';

class NavigationShell extends StatelessWidget {
  const NavigationShell({super.key, required this.navigationShell});

  /// The GoRouter-managed shell that preserves tab state.
  /// This is provided by [StatefulShellRoute.indexedStack] in the router.
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The [navigationShell] IS the IndexedStack — it renders the active
      // tab's widget tree and keeps all other tabs alive in memory.
      body: navigationShell,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          // [currentIndex] is derived from the current URL, not manual state.
          currentIndex: navigationShell.currentIndex,

          onTap: (index) {
            // [goBranch] navigates to the tab's root route.
            // [initialLocation: true] ensures tapping the already-active tab
            // pops back to its root screen (e.g. /sales/create → /sales).
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: AppStrings.navHome,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: AppStrings.navSales,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_outlined),
              activeIcon: Icon(Icons.shopping_cart_rounded),
              label: AppStrings.navPurchases,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded),
              activeIcon: Icon(Icons.people_rounded),
              label: AppStrings.navParties,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_rounded),
              activeIcon: Icon(Icons.menu_open_rounded),
              label: AppStrings.navMenu,
            ),
          ],
        ),
      ),
    );
  }
}
