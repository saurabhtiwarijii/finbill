/// FinBill — Purchases controller.
///
/// Manages the purchases list state backed by Firestore via [FirebaseService].
/// Subscribes to a real-time stream of purchases, with local search and date filtering.
///
/// File location: lib/features/purchases/controllers/purchases_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/purchase_model.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/date_filter_bottom_sheet.dart';

class PurchasesController extends ChangeNotifier {
  PurchasesController() {
    _subscribe();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── State ─────────────────────────────────────────────────────
  List<PurchaseModel> _allPurchases = [];
  List<PurchaseModel> _displayPurchases = [];
  String _searchQuery = '';
  bool _isLoading = true;
  StreamSubscription<List<PurchaseModel>>? _subscription;

  // ── Date filter ───────────────────────────────────────────────
  DateFilter _dateFilter = DateFilter.today();
  DateFilter get dateFilter => _dateFilter;

  List<PurchaseModel> get purchases => _displayPurchases;
  bool get isLoading => _isLoading;
  bool get isEmpty => _displayPurchases.isEmpty;
  int get totalPurchases => _allPurchases.length;

  // ── Real-time stream ──────────────────────────────────────────

  void _subscribe() {
    _subscription = _firebase.getPurchasesStream().listen(
      (purchases) {
        _allPurchases = purchases;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Purchases stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Manual reload — useful for pull-to-refresh.
  Future<void> loadPurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allPurchases = await _firebase.getPurchases();
      _applyFilters();
    } catch (e) {
      debugPrint('Purchases load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search ────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // ── Date filter ───────────────────────────────────────────────

  void setDateFilter(DateFilter filter) {
    _dateFilter = filter;
    _applyFilters();
    notifyListeners();
  }

  // ── Combined filter ───────────────────────────────────────────

  void _applyFilters() {
    // 1. Date filter
    var result = _allPurchases.where((p) => _dateFilter.includes(p.date)).toList();

    // 2. Search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((purchase) {
        return purchase.billNumber.toLowerCase().contains(_searchQuery) ||
            purchase.partyName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _displayPurchases = result;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
