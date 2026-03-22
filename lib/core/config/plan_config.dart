/// FinBill — Static subscription plan configuration.
///
/// These plans are defined locally and do NOT use Firestore.
/// They can be referenced by the Subscription screen and
/// any feature-gating logic throughout the app.
///
/// File location: lib/core/config/plan_config.dart
library;

class Plan {
  final String name;
  final double price;
  final List<String> features;

  const Plan({
    required this.name,
    required this.price,
    required this.features,
  });
}

/// All available subscription plans.
const List<Plan> plans = [
  // ── Lite Plan ──────────────────────────────────────────────────
  Plan(
    name: 'Lite',
    price: 0,
    features: [
      '150 invoices/month',
      '150 purchase entries/month',
      '50 scans/month',
      'Basic invoicing',
      'Low stock alerts',
      'Due tracker',
    ],
  ),

  // ── Standard Plan ──────────────────────────────────────────────
  Plan(
    name: 'Standard',
    price: 2999,
    features: [
      '500 invoices/month',
      '500 purchase entries/month',
      '200 scans/month',
      'Batch scanning',
      'Smart order queue',
      'WhatsApp sharing (500/month)',
      'E-Invoicing (limited)',
      'E-Way Bill (limited)',
    ],
  ),

  // ── Elite Plan ─────────────────────────────────────────────────
  Plan(
    name: 'Elite',
    price: 5999,
    features: [
      'Unlimited invoices',
      'Unlimited purchases',
      'Unlimited scans',
      'All GST reports',
      'Barcode scanner',
      'Barcode generator',
      'Data migration',
      'Priority support',
    ],
  ),
];
