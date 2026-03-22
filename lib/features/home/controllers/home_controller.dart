/// FinBill — Home Dashboard controller.
///
/// Holds the dashboard state: today's sales/purchase totals, pending
/// action count, and any error state. Connected directly to 
/// FirebaseService live streams for instant dynamic updates.
///
/// File location: lib/features/home/controllers/home_controller.dart
library;

import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../../services/firebase_service.dart';
import '../../../services/notification_service.dart';

class HomeController extends ChangeNotifier {
  // ── State ─────────────────────────────────────────────────────
  double _todaySales = 0;
  double _todayPurchases = 0;
  int _pendingActionCount = 0;
  bool _isLoading = false;

  double get todaySales => _todaySales;
  double get todayPurchases => _todayPurchases;
  int get pendingActionCount => _pendingActionCount;
  bool get isLoading => _isLoading;

  /// Whether there are any pending actions to show.
  bool get hasPendingActions => _pendingActionCount > 0;

  /// Human-readable subtitle for pending actions.
  String get pendingSubtitle => hasPendingActions
      ? '$_pendingActionCount items low in stock'
      : 'Everything looks settled for now';

  StreamSubscription? _salesSub;
  StreamSubscription? _purchasesSub;
  StreamSubscription? _lowStockSub;

  /// Tracks which items have already triggered a notification to avoid spam.
  final Set<String> _notifiedLowStockItemIds = {};

  // ── Data Fetching ─────────────────────────────────────────────

  /// Wires up real-time stream bindings to fetch and filter today's documents.
  void loadDashboard() {
    _isLoading = true;
    notifyListeners();
    
    getTodaySales();
    getTodayPurchases();
    getLowStock();
    
    _isLoading = false;
    notifyListeners();
  }

  void getTodaySales() {
    _salesSub?.cancel();
    _salesSub = FirebaseService.instance.getSalesStream().listen((sales) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      _todaySales = sales
          .where((s) => (s.date.isAtSameMomentAs(start) || s.date.isAfter(start)) && s.date.isBefore(end))
          .fold(0.0, (sum, s) => sum + s.grandTotal);
      notifyListeners();
    });
  }

  void getTodayPurchases() {
    _purchasesSub?.cancel();
    _purchasesSub = FirebaseService.instance.getPurchasesStream().listen((purchases) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));

      _todayPurchases = purchases
          .where((p) => (p.date.isAtSameMomentAs(start) || p.date.isAfter(start)) && p.date.isBefore(end))
          .fold(0.0, (sum, p) => sum + p.grandTotal);
      notifyListeners();
    });
  }

  void getLowStock() {
    _lowStockSub?.cancel();
    _lowStockSub = FirebaseService.instance.streamLowStock().listen((items) {
      _pendingActionCount = items.length;

      final currentLowStockIds = <String>{};

      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final itemId = item['itemId'] as String? ?? '';
        final itemName = item['itemName'] as String? ?? 'Unknown Item';
        
        if (itemId.isNotEmpty) {
          currentLowStockIds.add(itemId);

          if (!_notifiedLowStockItemIds.contains(itemId)) {
            // New low stock item! Trigger notification
            _notifiedLowStockItemIds.add(itemId);
            
            NotificationService.instance.showNotification(
              id: itemId.hashCode,
              title: 'Low stock alert',
              body: '$itemName is below threshold',
            );
          }
        }
      }

      // Remove items that are no longer low stock so they can trigger again later
      _notifiedLowStockItemIds.retainAll(currentLowStockIds);

      notifyListeners();
    });
  }

  @override
  void dispose() {
    _salesSub?.cancel();
    _purchasesSub?.cancel();
    _lowStockSub?.cancel();
    super.dispose();
  }
}
