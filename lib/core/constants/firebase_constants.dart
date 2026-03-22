/// FinBill — Firebase collection names and path constants.
///
/// Single source of truth for all Firestore collection paths.
/// Prevents typos and makes schema refactoring a single-file change.
///
/// File location: lib/core/constants/firebase_constants.dart
library;

class FirebaseConstants {
  FirebaseConstants._();

  // ── Top-level collections ─────────────────────────────────────
  static const String usersCollection = 'users';
  static const String businessesCollection = 'businesses';

  // ── Business sub-collections ──────────────────────────────────
  static const String itemsCollection = 'items';
  static const String partiesCollection = 'parties';
  static const String salesCollection = 'sales';
  static const String purchasesCollection = 'purchases';
  static const String paymentsCollection = 'payments';
  static const String countersCollection = 'counters';
  static const String settingsCollection = 'settings';

  // ── Counter document IDs ──────────────────────────────────────
  static const String invoiceCounter = 'invoice_counter';
  static const String purchaseCounter = 'purchase_counter';

  // ── Storage paths ─────────────────────────────────────────────
  static const String receiptsFolder = 'receipts';
  static const String logosFolder = 'logos';
  static const String profilePhotosFolder = 'profile_photos';

  // ── Helpers ───────────────────────────────────────────────────

  /// Returns the Firestore path for a business's sub-collection.
  /// e.g. `businesses/abc123/items`
  static String businessPath(String businessId, String subCollection) =>
      '$businessesCollection/$businessId/$subCollection';
}
