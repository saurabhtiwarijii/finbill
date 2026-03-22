/// FinBill — Inventory controller.
///
/// Manages inventory state backed by Firestore via [FirebaseService].
/// Subscribes to a real-time stream so the UI updates automatically
/// when items are added/edited/deleted — even from another device.
///
/// File location: lib/features/inventory/controllers/inventory_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/item_model.dart';
import '../../../services/firebase_service.dart';

class InventoryController extends ChangeNotifier {
  InventoryController() {
    _subscribe();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── State ─────────────────────────────────────────────────────
  List<ItemModel> _items = [];
  List<ItemModel> _filteredItems = [];
  String _searchQuery = '';
  bool _isLoading = true;
  StreamSubscription<List<ItemModel>>? _subscription;

  List<ItemModel> get items =>
      _searchQuery.isEmpty ? _items : _filteredItems;
  bool get isLoading => _isLoading;
  bool get isEmpty => items.isEmpty;
  int get totalItems => _items.length;
  int get lowStockCount => _items.where((i) => i.isLowStock).length;

  // ── Real-time stream ──────────────────────────────────────────

  void _subscribe() {
    _subscription = _firebase.getItemsStream().listen(
      (items) {
        _items = items;
        _applySearch();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Inventory stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Manual reload — useful for pull-to-refresh.
  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _firebase.getItems();
      _applySearch();
    } catch (e) {
      debugPrint('Inventory load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Search ────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredItems = _items;
    } else {
      _filteredItems = _items
          .where((item) =>
              item.name.toLowerCase().contains(_searchQuery) ||
              item.unit.toLowerCase().contains(_searchQuery))
          .toList();
    }
  }

  // ── CRUD Operations (Firestore-backed) ────────────────────────

  /// Add a new item to Firestore.
  Future<void> addItem(ItemModel item) async {
    try {
      await _firebase.addItem(item);
      // Stream will update _items automatically
    } catch (e) {
      debugPrint('addItem error: $e');
    }
  }

  /// Update an existing item in Firestore.
  Future<void> updateItem(ItemModel updatedItem) async {
    try {
      await _firebase.updateItem(updatedItem);
    } catch (e) {
      debugPrint('updateItem error: $e');
    }
  }

  /// Update stock quantity for a specific item.
  Future<void> updateStock(String itemId, double newStock) async {
    final item = getById(itemId);
    if (item != null) {
      await updateItem(item.copyWith(stock: newStock));
    }
  }

  /// Remove an item from Firestore.
  Future<void> deleteItem(String itemId) async {
    try {
      await _firebase.deleteItem(itemId);
    } catch (e) {
      debugPrint('deleteItem error: $e');
    }
  }

  /// Get a single item by ID, or null if not found.
  ItemModel? getById(String itemId) {
    try {
      return _items.firstWhere((i) => i.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// Generate a unique ID for a new item.
  String generateId() => 'item_${DateTime.now().millisecondsSinceEpoch}';

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
