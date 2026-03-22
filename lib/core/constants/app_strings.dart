/// FinBill — All user-facing strings.
///
/// Keeping strings centralised makes localisation and copy changes trivial.
/// When adding a new string, place it under the most relevant section heading.
///
/// File location: lib/core/constants/app_strings.dart
library;

class AppStrings {
  AppStrings._();

  // ── App ────────────────────────────────────────────────────────
  static const String appName = 'FinBill';
  static const String appTagline = 'AI-powered billing for your business';

  // ── Bottom Navigation ──────────────────────────────────────────
  static const String navHome = 'Home';
  static const String navSales = 'Sales';
  static const String navPurchases = 'Purchases';
  static const String navParties = 'Parties';
  static const String navGst = 'GST';
  static const String navMenu = 'Menu';

  // ── Dashboard ──────────────────────────────────────────────────
  static const String todaysInsights = "Today's Insights";
  static const String sales = 'Sales';
  static const String purchases = 'Purchases';
  static const String pendingActions = 'Pending Actions';
  static const String pendingSubtitle = 'Everything looks settled for now';
  static const String viewMore = 'View More';

  // ── AI Card ────────────────────────────────────────────────────
  static const String aiTitle = 'FinBill AI Assist';
  static const String aiSubtitle = 'Ask FinBill anything about your business';
  static const String aiButton = 'Try Now';

  // ── Search ─────────────────────────────────────────────────────
  static const String searchHint = 'Search...';
  static const String searchSales = 'Search invoices...';
  static const String searchPurchases = 'Search purchases...';
  static const String searchParties = 'Search parties...';
  static const String searchInventory = 'Search items...';

  // ── Empty States ───────────────────────────────────────────────
  static const String noSales = 'No sales found';
  static const String noPurchases = 'No purchases found';
  static const String noParties = 'No parties found';
  static const String noItems = 'No items found';
  static const String noSalesSubtitle = 'Create your first invoice to get started';
  static const String noPurchasesSubtitle = 'Scan a bill or add one manually';
  static const String noPartiesSubtitle = 'Add your first customer or supplier';

  // ── FAB Labels ─────────────────────────────────────────────────
  static const String addSale = 'Add Sale';
  static const String addPurchase = 'Add Purchase';
  static const String addParty = 'Add Party';
  static const String addItem = 'Add Item';

  // ── Menu Sections ──────────────────────────────────────────────
  static const String sectionBusiness = 'BUSINESS';
  static const String sectionReports = 'REPORTS';
  static const String sectionAccount = 'ACCOUNT';
  static const String sectionRewards = 'REWARDS';
  static const String sectionSupport = 'SUPPORT';
  static const String sectionLegal = 'LEGAL';

  // ── Menu Items ─────────────────────────────────────────────────
  static const String businessProfile = 'Business Profile';
  static const String printSettings = 'Print Settings';
  static const String manageInventory = 'Manage Inventory';
  static const String smartOrderQueue = 'Smart Order Queue';
  static const String dueTracker = 'Due Tracker';
  static const String aiQuotation = 'AI Quotation';
  static const String gstFiling = 'GST Filing';
  static const String reports = 'Reports';
  static const String accountSettings = 'Account Settings';
  static const String subscription = 'Subscription';
  static const String referFriend = 'Refer a Friend';
  static const String customerSupport = 'Customer Support';
  static const String aboutUs = 'About Us';
  static const String privacyPolicy = 'Privacy Policy';
  static const String termsConditions = 'Terms & Conditions';
  static const String logout = 'Logout';
  static const String comingSoon = 'Soon';

  // ── Common Actions ─────────────────────────────────────────────
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String retry = 'Retry';
}
