/// FinBill — GoRouter configuration with StatefulShellRoute.
///
/// ## How routing works in FinBill
///
/// 1. **Tab navigation** is handled by [StatefulShellRoute.indexedStack].
///    Each tab (Home, Sales, Purchases, Parties, Menu) is a "branch".
///    GoRouter keeps every branch alive internally — switching tabs does
///    NOT rebuild previous screens (same behaviour as a manual IndexedStack).
///
/// 2. **Sub-routes** (e.g. /sales/create, /parties/:partyId) are defined
///    as children of their parent tab branch. They push **inside** that
///    branch's navigator, keeping the bottom nav visible.
///
/// 3. **Full-screen routes** (e.g. /login) are defined outside the shell
///    and push without the bottom nav.
///
/// ## Adding a new route
///
/// 1. Add the path constant to [RoutePaths] in `route_names.dart`.
/// 2. Add a named ID to [RouteNameIds].
/// 3. Add a [GoRoute] under the correct branch below.
/// 4. Navigate with: `context.goNamed(RouteNameIds.myRoute)`
///
/// File location: lib/core/routing/app_router.dart
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/sale_model.dart';
import '../../models/purchase_model.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/sales/screens/sales_screen.dart';
import '../../features/sales/screens/add_sale_screen.dart';
import '../../features/sales/screens/sale_detail_screen.dart';
import '../../features/purchases/screens/purchases_screen.dart';
import '../../features/purchases/screens/add_purchase_screen.dart';
import '../../features/purchases/screens/purchase_detail_screen.dart';
import '../../features/parties/screens/parties_screen.dart';
import '../../features/parties/screens/add_party_screen.dart';
import '../../features/parties/screens/party_detail_screen.dart';
import '../../models/party_model.dart';
import '../../features/menu/screens/menu_screen.dart';
import '../../features/menu/business_profile/business_profile_screen.dart';
import '../../features/menu/account_settings/screens/account_settings_screen.dart';
import '../../features/menu/about_us/screens/about_us_screen.dart';
import '../../features/menu/subscription/screens/subscription_screen.dart';
import '../../features/menu/support/screens/customer_support_screen.dart';
import '../../features/menu/legal/screens/privacy_policy_screen.dart';
import '../../features/menu/legal/screens/terms_conditions_screen.dart';
import '../../features/menu/print_settings/print_settings_screen.dart';
import '../../features/reports/screens/reports_dashboard_screen.dart';
import '../../features/reports/screens/sales_report_screen.dart';
import '../../features/reports/screens/purchase_report_screen.dart';
import '../../features/reports/screens/inventory_report_screen.dart';
import '../../features/reports/screens/due_report_screen.dart';
import '../../features/inventory/screens/inventory_screen.dart';
import '../../features/inventory/screens/low_stock_screen.dart';
import '../../features/dues/screens/due_tracker_screen.dart';
import '../../features/gst/screens/gst_dashboard_screen.dart';
import '../../features/gst/screens/gstr1_screen.dart';
import '../../features/gst/screens/gstr2_screen.dart';
import '../../navigation_shell.dart';
import '../../services/app_state_service.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  /// Global navigator key for full-screen routes (login, onboarding).
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// One navigator key per tab branch — GoRouter uses these to maintain
  /// independent navigation stacks for each tab.
  static final _homeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
  static final _salesKey = GlobalKey<NavigatorState>(debugLabel: 'sales');
  static final _purchasesKey = GlobalKey<NavigatorState>(debugLabel: 'purchases');
  static final _partiesKey = GlobalKey<NavigatorState>(debugLabel: 'parties');
  static final _menuKey = GlobalKey<NavigatorState>(debugLabel: 'menu');

  // ════════════════════════════════════════════════════════════════
  //  Router instance — used by MaterialApp.router
  // ════════════════════════════════════════════════════════════════

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppStateService.instance.isProfileComplete ? RoutePaths.home : RoutePaths.accountSettings,
    refreshListenable: AppStateService.instance,
    redirect: (context, state) {
      final isGoingToSettings = state.uri.path == RoutePaths.accountSettings;
      
      if (!AppStateService.instance.isProfileComplete && !isGoingToSettings) {
        // Force them to the account settings page to complete their profile
        return RoutePaths.accountSettings;
      }
      return null;
    },
    debugLogDiagnostics: true,
    routes: [
      // ── Bottom nav shell (5 tabs with state preservation) ──────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // [navigationShell] is the GoRouter-managed IndexedStack.
          // It is passed to our NavigationShell which wraps it with
          // the BottomNavigationBar.
          return NavigationShell(navigationShell: navigationShell);
        },
        branches: [
          // ── Tab 0 : Home ──────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeKey,
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNameIds.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // ── Tab 1 : Sales ─────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _salesKey,
            routes: [
              GoRoute(
                path: RoutePaths.sales,
                name: RouteNameIds.sales,
                builder: (context, state) => const SalesScreen(),
                routes: [
                  // /sales/create
                  GoRoute(
                    path: RoutePaths.createInvoice,
                    name: RouteNameIds.createInvoice,
                    builder: (context, state) =>
                        const AddSaleScreen(),
                  ),
                  // /sales/:invoiceId
                  GoRoute(
                    path: RoutePaths.invoiceDetail,
                    name: RouteNameIds.invoiceDetail,
                    builder: (context, state) {
                      final sale = state.extra as SaleModel;
                      return SaleDetailScreen(sale: sale);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 2 : Purchases ─────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _purchasesKey,
            routes: [
              GoRoute(
                path: RoutePaths.purchases,
                name: RouteNameIds.purchases,
                builder: (context, state) => const PurchasesScreen(),
                routes: [
                  // /purchases/add
                  GoRoute(
                    path: RoutePaths.addPurchase,
                    name: RouteNameIds.addPurchase,
                    builder: (context, state) =>
                        const AddPurchaseScreen(),
                  ),
                  // /purchases/:purchaseId
                  GoRoute(
                    path: RoutePaths.purchaseDetail,
                    name: RouteNameIds.purchaseDetail,
                    builder: (context, state) {
                      final purchase = state.extra as PurchaseModel;
                      return PurchaseDetailScreen(purchase: purchase);
                    },
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 3 : Parties ───────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _partiesKey,
            routes: [
              GoRoute(
                path: RoutePaths.parties,
                name: RouteNameIds.parties,
                builder: (context, state) => const PartiesScreen(),
                routes: [
                  // /parties/add
                  GoRoute(
                    path: RoutePaths.addParty,
                    name: RouteNameIds.addParty,
                    builder: (context, state) =>
                        const AddPartyScreen(),
                  ),
                  // /parties/:partyId
                  GoRoute(
                    path: RoutePaths.partyDetail,
                    name: RouteNameIds.partyDetail,
                    builder: (context, state) => PartyDetailScreen(
                      partyId: state.pathParameters['partyId'] ?? '',
                      party: state.extra as PartyModel?,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 4 : Menu ──────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _menuKey,
            routes: [
              GoRoute(
                path: RoutePaths.menu,
                name: RouteNameIds.menu,
                builder: (context, state) => const MenuScreen(),
                routes: [
                  // /menu/business-profile
                  GoRoute(
                    path: RoutePaths.businessProfile,
                    name: RouteNameIds.businessProfile,
                    builder: (context, state) => const BusinessProfileScreen(),
                  ),
                  // /menu/print-settings
                  GoRoute(
                    path: RoutePaths.printSettings,
                    name: RouteNameIds.printSettings,
                    builder: (context, state) => const PrintSettingsScreen(),
                  ),
                  // /menu/reports
                  GoRoute(
                    path: RoutePaths.reports,
                    name: RouteNameIds.reports,
                    builder: (context, state) =>
                        const ReportsDashboardScreen(),
                    routes: [
                      GoRoute(
                        path: RoutePaths.salesReport,
                        name: RouteNameIds.salesReport,
                        builder: (context, state) =>
                            const SalesReportScreen(),
                      ),
                      GoRoute(
                        path: RoutePaths.purchaseReport,
                        name: RouteNameIds.purchaseReport,
                        builder: (context, state) =>
                            const PurchaseReportScreen(),
                      ),
                      GoRoute(
                        path: RoutePaths.inventoryReport,
                        name: RouteNameIds.inventoryReport,
                        builder: (context, state) =>
                            const InventoryReportScreen(),
                      ),
                      GoRoute(
                        path: RoutePaths.dueReport,
                        name: RouteNameIds.dueReport,
                        builder: (context, state) =>
                            const DueReportScreen(),
                      ),
                    ],
                  ),
                  // /menu/inventory
                  GoRoute(
                    path: RoutePaths.inventory,
                    name: RouteNameIds.inventory,
                    builder: (context, state) =>
                        const InventoryScreen(),
                    routes: [
                      // /menu/inventory/add-item
                      GoRoute(
                        path: RoutePaths.addItem,
                        name: RouteNameIds.addItem,
                        builder: (context, state) =>
                            const _Placeholder(title: 'Add Item'),
                      ),
                    ],
                  ),
                  // /menu/due-tracker
                  GoRoute(
                    path: RoutePaths.dueTracker,
                    name: RouteNameIds.dueTracker,
                    builder: (context, state) =>
                        const DueTrackerScreen(),
                  ),
                  // /menu/smart-order-queue
                  GoRoute(
                    path: RoutePaths.smartOrderQueue,
                    name: RouteNameIds.smartOrderQueue,
                    builder: (context, state) => const LowStockScreen(),
                  ),
                  // /menu/ai-quotation
                  GoRoute(
                    path: RoutePaths.aiQuotation,
                    name: RouteNameIds.aiQuotation,
                    builder: (context, state) =>
                        const _Placeholder(title: 'AI Quotation'),
                  ),
                  // /menu/account-settings
                  GoRoute(
                    path: RoutePaths.accountSettings,
                    name: RouteNameIds.accountSettings,
                    builder: (context, state) =>
                        const AccountSettingsScreen(),
                  ),
                  // /menu/subscription
                  GoRoute(
                    path: RoutePaths.subscription,
                    name: RouteNameIds.subscription,
                    builder: (context, state) =>
                        const SubscriptionScreen(),
                  ),
                  // /menu/about-us
                  GoRoute(
                    path: RoutePaths.aboutUs,
                    name: RouteNameIds.aboutUs,
                    builder: (context, state) =>
                        const AboutUsScreen(),
                  ),
                  // /menu/customer-support
                  GoRoute(
                    path: RoutePaths.customerSupport,
                    name: RouteNameIds.customerSupport,
                    builder: (context, state) =>
                        const CustomerSupportScreen(),
                  ),
                  // /menu/privacy-policy
                  GoRoute(
                    path: RoutePaths.privacyPolicy,
                    name: RouteNameIds.privacyPolicy,
                    builder: (context, state) =>
                        const PrivacyPolicyScreen(),
                  ),
                  // /menu/terms-conditions
                  GoRoute(
                    path: RoutePaths.termsConditions,
                    name: RouteNameIds.termsConditions,
                    builder: (context, state) =>
                        const TermsConditionsScreen(),
                  ),
                  // /menu/gst
                  GoRoute(
                    path: RoutePaths.gstDashboard,
                    name: RouteNameIds.gstDashboard,
                    builder: (context, state) => const GstDashboardScreen(),
                    routes: [
                      GoRoute(
                        path: RoutePaths.gstr1,
                        name: RouteNameIds.gstr1,
                        builder: (context, state) => const Gstr1Screen(),
                      ),
                      GoRoute(
                        path: RoutePaths.gstr2,
                        name: RouteNameIds.gstr2,
                        builder: (context, state) => const Gstr2Screen(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ── Full-screen routes (no bottom nav) ────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.login,
        name: RouteNameIds.login,
        builder: (context, state) => const _Placeholder(title: 'Login'),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════
//  Temporary placeholder — replaced with real screens per feature
// ══════════════════════════════════════════════════════════════════

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title\n(Coming Soon)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
