/// FinBill — Sales controller.
///
/// Manages the sales list state backed by Firestore via [FirebaseService].
/// Subscribes to a real-time stream of sales, with local search and date filtering.
///
/// File location: lib/features/sales/controllers/sales_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/sale_model.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/date_filter_bottom_sheet.dart';

class SalesController extends ChangeNotifier {
  SalesController() {
    _subscribe();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── State ─────────────────────────────────────────────────────
  List<SaleModel> _allSales = [];
  List<SaleModel> _displaySales = [];
  String _searchQuery = '';
  bool _isLoading = true;
  StreamSubscription<List<SaleModel>>? _subscription;

  // ── Date filter ───────────────────────────────────────────────
  DateFilter _dateFilter = DateFilter.today();
  DateFilter get dateFilter => _dateFilter;

  List<SaleModel> get sales => _displaySales;
  bool get isLoading => _isLoading;
  bool get isEmpty => _displaySales.isEmpty;
  int get totalSales => _allSales.length;

  // ── Real-time stream ──────────────────────────────────────────

  void _subscribe() {
    _subscription = _firebase.getSalesStream().listen(
      (sales) {
        _allSales = sales;
        _applyFilters();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Sales stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Manual reload — useful for pull-to-refresh.
  Future<void> loadSales() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allSales = await _firebase.getSales();
      _applyFilters();
    } catch (e) {
      debugPrint('Sales load error: $e');
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
    var result = _allSales.where((sale) => _dateFilter.includes(sale.date)).toList();

    // 2. Search filter
    if (_searchQuery.isNotEmpty) {
      result = result.where((sale) {
        return sale.invoiceNumber.toLowerCase().contains(_searchQuery) ||
            sale.partyName.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    _displaySales = result;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
