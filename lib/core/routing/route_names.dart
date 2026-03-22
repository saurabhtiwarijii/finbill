/// FinBill — Named route path constants.
///
/// Every route in the app is defined here as a constant. This avoids
/// hardcoded strings scattered across the codebase and makes refactoring
/// routes a single-file change.
///
/// **Naming convention:**
///   • Tab roots:    `/home`, `/sales`, ...
///   • Sub-routes:   `create`, `add`, `:id` (relative to parent)
///   • Named routes: `camelCase` identifiers for GoRouter `name:` param
///
/// File location: lib/core/routing/route_names.dart
library;

class RoutePaths {
  RoutePaths._();

  // ── Tab root paths ─────────────────────────────────────────────
  static const String home = '/home';
  static const String sales = '/sales';
  static const String purchases = '/purchases';
  static const String parties = '/parties';
  static const String menu = '/menu';

  // ── Sales sub-paths (relative) ─────────────────────────────────
  static const String createInvoice = 'create';       // /sales/create
  static const String invoiceDetail = ':invoiceId';   // /sales/:invoiceId

  // ── Purchases sub-paths (relative) ─────────────────────────────
  static const String addPurchase = 'add';            // /purchases/add
  static const String purchaseDetail = ':purchaseId'; // /purchases/:purchaseId

  // ── Parties sub-paths (relative) ───────────────────────────────
  static const String addParty = 'add';               // /parties/add
  static const String partyDetail = ':partyId';       // /parties/:partyId

  // ── Menu sub-paths (relative) ──────────────────────────────────
  static const String businessProfile = 'business-profile';
  static const String printSettings = 'print-settings';
  static const String reports = 'reports';
  static const String salesReport = 'sales-report';
  static const String purchaseReport = 'purchase-report';
  static const String inventoryReport = 'inventory-report';
  static const String dueReport = 'due-report';
  static const String inventory = 'inventory';
  static const String addItem = 'add-item';           // /menu/inventory/add-item
  static const String dueTracker = 'due-tracker';
  static const String smartOrderQueue = 'smart-order-queue';
  static const String aiQuotation = 'ai-quotation';
  static const String aboutUs = 'about-us';
  static const String gstDashboard = 'gst';             // /menu/gst
  static const String gstr1 = 'gstr-1';                 // /menu/gst/gstr-1
  static const String gstr2 = 'gstr-2';                 // /menu/gst/gstr-2
  static const String accountSettings = 'account-settings';
  static const String subscription = 'subscription';
  static const String customerSupport = 'customer-support';
  static const String privacyPolicy = 'privacy-policy';
  static const String termsConditions = 'terms-conditions';

  // ── Auth (top-level) ───────────────────────────────────────────
  static const String login = '/login';
}

/// Named route identifiers used with `context.goNamed(...)`.
///
/// These are separate from paths so route names stay stable even if
/// the URL structure changes later.
class RouteNameIds {
  RouteNameIds._();

  static const String home = 'home';
  static const String sales = 'sales';
  static const String createInvoice = 'createInvoice';
  static const String invoiceDetail = 'invoiceDetail';
  static const String purchases = 'purchases';
  static const String addPurchase = 'addPurchase';
  static const String purchaseDetail = 'purchaseDetail';
  static const String parties = 'parties';
  static const String addParty = 'addParty';
  static const String partyDetail = 'partyDetail';
  static const String menu = 'menu';
  static const String businessProfile = 'businessProfile';
  static const String printSettings = 'printSettings';
  static const String reports = 'reports';
  static const String salesReport = 'salesReport';
  static const String purchaseReport = 'purchaseReport';
  static const String inventoryReport = 'inventoryReport';
  static const String dueReport = 'dueReport';
  static const String inventory = 'inventory';
  static const String addItem = 'addItem';
  static const String dueTracker = 'dueTracker';
  static const String smartOrderQueue = 'smartOrderQueue';
  static const String aiQuotation = 'aiQuotation';
  static const String aboutUs = 'aboutUs';
  static const String gstDashboard = 'gstDashboard';
  static const String gstr1 = 'gstr1';
  static const String gstr2 = 'gstr2';
  static const String accountSettings = 'accountSettings';
  static const String subscription = 'subscription';
  static const String customerSupport = 'customerSupport';
  static const String privacyPolicy = 'privacyPolicy';
  static const String termsConditions = 'termsConditions';
  static const String login = 'login';
}
