/// FinBill — Feature access control system based on active plan.
///
/// Defines feature keys, per-plan feature mappings, and helper methods
/// to check access and retrieve limits. This is a static, local system
/// with no Firestore dependency.
///
/// File location: lib/core/config/feature_access.dart
library;

// ── Feature Keys ──────────────────────────────────────────────────

class FeatureKeys {
  FeatureKeys._();

  static const String invoiceLimit = 'invoice_limit';
  static const String purchaseLimit = 'purchase_limit';
  static const String scanLimit = 'scan_limit';
  static const String smartOrderQueue = 'smart_order_queue';
  static const String gstReports = 'gst_reports';
  static const String barcode = 'barcode';
  static const String whatsappShare = 'whatsapp_share';
}

// ── Per-Plan Feature Map ──────────────────────────────────────────

const Map<String, Map<String, dynamic>> planFeatures = {
  'Lite': {
    FeatureKeys.invoiceLimit: 150,
    FeatureKeys.purchaseLimit: 150,
    FeatureKeys.scanLimit: 50,
    FeatureKeys.smartOrderQueue: false,
    FeatureKeys.gstReports: false,
    FeatureKeys.barcode: false,
    FeatureKeys.whatsappShare: false,
  },
  'Standard': {
    FeatureKeys.invoiceLimit: 500,
    FeatureKeys.purchaseLimit: 500,
    FeatureKeys.scanLimit: 200,
    FeatureKeys.smartOrderQueue: true,
    FeatureKeys.gstReports: false,
    FeatureKeys.barcode: false,
    FeatureKeys.whatsappShare: true,
  },
  'Elite': {
    FeatureKeys.invoiceLimit: -1, // -1 = unlimited
    FeatureKeys.purchaseLimit: -1,
    FeatureKeys.scanLimit: -1,
    FeatureKeys.smartOrderQueue: true,
    FeatureKeys.gstReports: true,
    FeatureKeys.barcode: true,
    FeatureKeys.whatsappShare: true,
  },
};

// ── Active Plan State ─────────────────────────────────────────────

/// Currently active plan name. Defaults to 'Lite'.
/// Update this when the user's plan changes (e.g. after purchase).
String _activePlan = 'Lite';

String get activePlan => _activePlan;

void setActivePlan(String planName) {
  if (planFeatures.containsKey(planName)) {
    _activePlan = planName;
  }
}

// ── Helper Methods ────────────────────────────────────────────────

/// Returns `true` if the current plan grants access to [feature].
///
/// For boolean features (e.g. `smart_order_queue`), checks the flag.
/// For numeric limits (e.g. `invoice_limit`), returns `true` if limit > 0
/// or is unlimited (-1).
bool hasAccess(String feature) {
  final features = planFeatures[_activePlan];
  if (features == null || !features.containsKey(feature)) return false;

  final value = features[feature];

  if (value is bool) return value;
  if (value is int) return value == -1 || value > 0;

  return false;
}

/// Returns the numeric limit for the given [feature] under the active plan.
///
/// Returns `-1` for unlimited, `0` if the feature doesn't exist or
/// isn't a numeric feature.
int getLimit(String feature) {
  final features = planFeatures[_activePlan];
  if (features == null || !features.containsKey(feature)) return 0;

  final value = features[feature];
  if (value is int) return value;

  return 0;
}
