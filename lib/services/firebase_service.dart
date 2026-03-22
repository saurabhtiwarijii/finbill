/// FinBill — Firebase service.
///
/// Business-scoped Firestore CRUD for items and sales.
/// All data is stored under `businesses/{businessId}/` for tenant isolation.
///
/// File location: lib/services/firebase_service.dart
library;

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/firebase_constants.dart';
import '../models/item_model.dart';
import '../models/sale_model.dart';
import '../models/purchase_model.dart';
import '../models/party_model.dart';
import '../models/business_model.dart';
import '../models/print_settings_model.dart';

class FirebaseService {
  FirebaseService._();
  static final instance = FirebaseService._();

  final _firestore = FirebaseFirestore.instance;

  // ── Hardcoded business ID for development ─────────────────────
  // TODO: Replace with authenticated user's active business ID
  static const String _defaultBusinessId = 'demo_business';

  String _businessId = _defaultBusinessId;

  /// Override the business ID (e.g. after login).
  void setBusinessId(String id) => _businessId = id;
  String get businessId => _businessId;

  // ═══════════════════════════════════════════════════════════════
  //  Helper — collection reference
  // ═══════════════════════════════════════════════════════════════

  CollectionReference<Map<String, dynamic>> _collection(String name) =>
      _firestore.collection(
        FirebaseConstants.businessPath(_businessId, name),
      );

  // ═══════════════════════════════════════════════════════════════
  //  BUSINESS PROFILE
  // ═══════════════════════════════════════════════════════════════

  /// Fetch the current business profile.
  Future<BusinessModel?> getBusinessProfile() async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .get();
      
      if (!doc.exists) return null;
      return BusinessModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      print('FirebaseService.getBusinessProfile error: $e');
      return null;
    }
  }

  /// Create or update the business profile.
  Future<void> saveBusinessProfile(BusinessModel business) async {
    try {
      await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .set(business.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('FirebaseService.saveBusinessProfile error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  SETTINGS
  // ═══════════════════════════════════════════════════════════════

  /// Fetch account settings for the business owner profile.
  Future<Map<String, dynamic>?> getAccountSettings() async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('settings')
          .doc('account')
          .get();
      if (!doc.exists) return null;
      return doc.data();
    } catch (e) {
      debugPrint('FirebaseService.getAccountSettings error: $e');
      return null;
    }
  }

  /// Save or update account settings.
  Future<void> saveAccountSettings(Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('settings')
          .doc('account')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('FirebaseService.saveAccountSettings error: $e');
      rethrow;
    }
  }

  /// Fetch print settings.
  Future<PrintSettingsModel?> getPrintSettings() async {
    try {
      final doc = await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection(FirebaseConstants.settingsCollection)
          .doc('print')
          .get();

      if (!doc.exists || doc.data() == null) return null;
      return PrintSettingsModel.fromMap(doc.data()!);
    } catch (e) {
      print('FirebaseService.getPrintSettings error: $e');
      return null;
    }
  }

  /// Save print settings.
  Future<void> savePrintSettings(PrintSettingsModel settings) async {
    try {
      await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection(FirebaseConstants.settingsCollection)
          .doc('print')
          .set(settings.toMap(), SetOptions(merge: true));
    } catch (e) {
      print('FirebaseService.savePrintSettings error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  INVENTORY
  // ═══════════════════════════════════════════════════════════════

  /// Add or overwrite an item document.
  Future<void> addItem(ItemModel item) async {
    try {
      await _collection(FirebaseConstants.itemsCollection)
          .doc(item.id)
          .set(item.toMap());
      await checkAndUpdateLowStock(item.id);
    } catch (e) {
      debugPrint('FirebaseService.addItem error: $e');
      rethrow;
    }
  }

  /// Update an existing item.
  Future<void> updateItem(ItemModel item) async {
    try {
      await _collection(FirebaseConstants.itemsCollection)
          .doc(item.id)
          .update(item.toMap());
      await checkAndUpdateLowStock(item.id);
    } catch (e) {
      debugPrint('FirebaseService.updateItem error: $e');
      rethrow;
    }
  }

  /// Delete an item by ID.
  Future<void> deleteItem(String itemId) async {
    try {
      await _collection(FirebaseConstants.itemsCollection)
          .doc(itemId)
          .delete();
    } catch (e) {
      debugPrint('FirebaseService.deleteItem error: $e');
      rethrow;
    }
  }

  /// Real-time stream of all items, ordered by name.
  Stream<List<ItemModel>> getItemsStream() {
    return _collection(FirebaseConstants.itemsCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return ItemModel.fromMap(data);
            }).toList());
  }

  /// One-time fetch of all items.
  Future<List<ItemModel>> getItems() async {
    try {
      final snapshot = await _collection(FirebaseConstants.itemsCollection)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return ItemModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('FirebaseService.getItems error: $e');
      return [];
    }
  }

  /// Fetch a single item by ID. Returns null if not found.
  Future<ItemModel?> getItemById(String itemId) async {
    try {
      final doc = await _collection(FirebaseConstants.itemsCollection)
          .doc(itemId)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return ItemModel.fromMap(data);
    } catch (e) {
      debugPrint('FirebaseService.getItemById error: $e');
      return null;
    }
  }

  // ── Low Stock Detection ────────────────────────────────────────

  /// Checks an item's stock against its alertLevel and updates
  /// the low_stock collection accordingly.
  Future<void> checkAndUpdateLowStock(String itemId) async {
    try {
      final doc = await _collection(FirebaseConstants.itemsCollection)
          .doc(itemId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final stock = (data['stock'] as num?)?.toDouble() ?? 0;
      final alertLevel = (data['alertLevel'] as num?)?.toInt() ?? 0;
      final itemName = data['name'] as String? ?? '';

      final lowStockRef = _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('low_stock')
          .doc(itemId);

      if (alertLevel > 0 && stock <= alertLevel) {
        await lowStockRef.set({
          'itemId': itemId,
          'itemName': itemName,
          'stock': stock,
          'alertLevel': alertLevel,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        debugPrint('⚠ Low stock: $itemName ($stock <= $alertLevel)');
      } else {
        await lowStockRef.delete();
      }
    } catch (e) {
      debugPrint('checkAndUpdateLowStock error: $e');
    }
  }

  /// Real-time stream of low stock items.
  Stream<List<Map<String, dynamic>>> streamLowStock() {
    return _firestore
        .collection(FirebaseConstants.businessesCollection)
        .doc(_businessId)
        .collection('low_stock')
        .orderBy('stock', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  // ── Stock management ──────────────────────────────────────────

  /// Atomically deduct stock for a single item using a Firestore
  /// transaction. Clamps to 0 — stock never goes negative.
  /// Returns the new stock value.
  Future<double> updateItemStock(String itemId, double quantitySold) async {
    final docRef =
        _collection(FirebaseConstants.itemsCollection).doc(itemId);

    final newStock = await _firestore.runTransaction<double>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        debugPrint('updateItemStock: item $itemId not found');
        return -1;
      }

      final currentStock = (snapshot.data()?['stock'] as num?)?.toDouble() ?? 0;
      // Clamp to 0 — never go negative
      final ns = (currentStock - quantitySold).clamp(0.0, double.infinity);

      transaction.update(docRef, {'stock': ns});
      return ns;
    });

    // Check low stock after transaction completes
    if (newStock >= 0) {
      await checkAndUpdateLowStock(itemId);
    }
    return newStock;
  }

  /// Deduct stock for all line items in a sale.
  /// Runs each update as a separate transaction for atomicity.
  Future<void> deductStockForSale(SaleModel sale) async {
    for (final lineItem in sale.lineItems) {
      try {
        final newStock =
            await updateItemStock(lineItem.itemId, lineItem.quantity);
        if (newStock >= 0) {
          debugPrint(
            'Stock updated: ${lineItem.itemName} → $newStock',
          );
        }
      } catch (e) {
        debugPrint(
          'Stock deduction failed for ${lineItem.itemName}: $e',
        );
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  SALES
  // ═══════════════════════════════════════════════════════════════

  /// Generates a sequential invoice number using an atomic Firestore transaction.
  /// Prevents race conditions and ensures no duplicate 'INV-XXXX' numbers.
  Future<String> generateInvoiceNumber() async {
    final docRef = _firestore
        .collection(FirebaseConstants.businessesCollection)
        .doc(_businessId)
        .collection(FirebaseConstants.settingsCollection)
        .doc('invoice');

    return _firestore.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(docRef);
      int lastInvoiceNumber = 0;

      if (snapshot.exists) {
        lastInvoiceNumber =
            (snapshot.data()?['lastInvoiceNumber'] as num?)?.toInt() ?? 0;
      }

      final newInvoiceNumber = lastInvoiceNumber + 1;
      transaction.set(
        docRef,
        {'lastInvoiceNumber': newInvoiceNumber},
        SetOptions(merge: true),
      );

      return 'INV-${newInvoiceNumber.toString().padLeft(4, '0')}';
    });
  }

  /// Generates a sequential purchase number using an atomic Firestore transaction.
  /// Returns 'PUR-0001', 'PUR-0002', etc.
  Future<String> generatePurchaseNumber() async {
    final docRef = _firestore
        .collection(FirebaseConstants.businessesCollection)
        .doc(_businessId)
        .collection(FirebaseConstants.settingsCollection)
        .doc('purchase');

    return _firestore.runTransaction<String>((transaction) async {
      final snapshot = await transaction.get(docRef);
      int lastNumber = 0;

      if (snapshot.exists) {
        lastNumber =
            (snapshot.data()?['lastPurchaseNumber'] as num?)?.toInt() ?? 0;
      }

      final newNumber = lastNumber + 1;
      transaction.set(
        docRef,
        {'lastPurchaseNumber': newNumber},
        SetOptions(merge: true),
      );

      return 'PUR-${newNumber.toString().padLeft(4, '0')}';
    });
  }

  /// Add a sale with its line items stored as a subcollection.
  Future<String> addSale(SaleModel sale) async {
    print('>>> INSIDE addSale()');
    print('>>> Sale ID: ${sale.id} | Invoice: ${sale.invoiceNumber}');
    print('>>> Party: ${sale.partyName} | Items: ${sale.lineItems.length} | Total: ${sale.grandTotal}');

    final collectionPath = FirebaseConstants.businessPath(
        _businessId, FirebaseConstants.salesCollection);
    print('>>> Collection path: $collectionPath');

    try {
      final salesRef = _firestore.collection(collectionPath);
      final docRef = salesRef.doc(sale.id);

      // Build the data map
      final saleData = sale.toMap();
      print('>>> Sale data keys: ${saleData.keys.toList()}');

      // Write sale header using .set() EXACTLY like addPurchase
      print('>>> Writing sale document to Firestore (set)...');
      await docRef.set(saleData);
      print('>>> Document CREATED/UPDATED with ID: ${docRef.id}');

      print('>>> addSale() COMPLETE — returning ${docRef.id}');

      return docRef.id;
    } catch (e, stack) {
      print('>>> addSale() FAILED: $e');
      print('>>> Stack: $stack');
      rethrow;
    }
  }

  /// Updates an existing sale document in Firestore.
  Future<void> updateSale(SaleModel sale) async {
    final collectionPath = FirebaseConstants.businessPath(
        _businessId, FirebaseConstants.salesCollection);
    try {
      final docRef = _firestore.collection(collectionPath).doc(sale.id);
      await docRef.update(sale.toMap());
      print('>>> updateSale() SUCCESS — ${sale.id}');
    } catch (e, stack) {
      print('>>> updateSale() FAILED: $e');
      print('>>> Stack: $stack');
      rethrow;
    }
  }

  /// Real-time stream of sales, newest first.
  Stream<List<SaleModel>> getSalesStream() {
    return _collection(FirebaseConstants.salesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      final validSales = <SaleModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          validSales.add(SaleModel.fromMap(data));
        } catch (e) {
          print('>>> ERROR parsing sale document ${doc.id}: $e');
        }
      }
      return validSales;
    });
  }

  /// One-time fetch of all sales.
  Future<List<SaleModel>> getSales() async {
    try {
      final snapshot = await _collection(FirebaseConstants.salesCollection)
          .orderBy('date', descending: true)
          .get();
      final validSales = <SaleModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          validSales.add(SaleModel.fromMap(data));
        } catch (e) {
          print('>>> ERROR parsing sale document ${doc.id}: $e');
        }
      }
      return validSales;
    } catch (e) {
      print('FirebaseService.getSales error: $e');
      return [];
    }
  }

  /// Fetch a single sale by ID.
  Future<SaleModel?> getSaleById(String saleId) async {
    try {
      final doc = await _collection(FirebaseConstants.salesCollection).doc(saleId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return SaleModel.fromMap(data);
      }
    } catch (e) {
      debugPrint('FirebaseService.getSaleById error: $e');
    }
    return null;
  }

  /// Fetch all sales for a specific party.
  Future<List<SaleModel>> getSalesByPartyId(String partyId) async {
    try {
      final snapshot = await _collection(FirebaseConstants.salesCollection)
          .where('partyId', isEqualTo: partyId)
          .get();
      final results = <SaleModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          results.add(SaleModel.fromMap(data));
        } catch (e) {
          debugPrint('Error parsing sale ${doc.id}: $e');
        }
      }
      // Sort locally (newest first) to avoid composite index requirement
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      debugPrint('getSalesByPartyId error: $e');
      return [];
    }
  }

  /// Fetch all purchases for a specific party.
  Future<List<PurchaseModel>> getPurchasesByPartyId(String partyId) async {
    try {
      final snapshot = await _collection(FirebaseConstants.purchasesCollection)
          .where('partyId', isEqualTo: partyId)
          .get();
      final results = <PurchaseModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          results.add(PurchaseModel.fromMap(data));
        } catch (e) {
          debugPrint('Error parsing purchase ${doc.id}: $e');
        }
      }
      // Sort locally (newest first) to avoid composite index requirement
      results.sort((a, b) => b.date.compareTo(a.date));
      return results;
    } catch (e) {
      debugPrint('getPurchasesByPartyId error: $e');
      return [];
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  PURCHASES
  // ═══════════════════════════════════════════════════════════════

  /// Add a purchase with its line items stored as a subcollection.
  Future<void> addPurchase(PurchaseModel purchase) async {
    debugPrint('──── FirebaseService.addPurchase START ────');
    debugPrint('Purchase ID: ${purchase.id}');
    debugPrint('Bill: ${purchase.billNumber}');
    debugPrint('Party: ${purchase.partyName}');
    debugPrint('Line items: ${purchase.lineItems.length}');

    try {
      final purchasesRef =
          _collection(FirebaseConstants.purchasesCollection);
      final docRef = purchasesRef.doc(purchase.id);

      // Write the purchase header
      debugPrint('Writing purchase header...');
      await docRef.set(purchase.toMap());
      debugPrint('✓ Purchase written');

      debugPrint('──── FirebaseService.addPurchase SUCCESS ────');
    } catch (e, stack) {
      debugPrint('✗ FirebaseService.addPurchase FAILED: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Updates an existing purchase document in Firestore.
  Future<void> updatePurchase(PurchaseModel purchase) async {
    try {
      final docRef =
          _collection(FirebaseConstants.purchasesCollection).doc(purchase.id);
      await docRef.update(purchase.toMap());
      debugPrint('>>> updatePurchase() SUCCESS — ${purchase.id}');
    } catch (e, stack) {
      debugPrint('>>> updatePurchase() FAILED: $e');
      debugPrint('>>> Stack: $stack');
      rethrow;
    }
  }

  /// Real-time stream of purchases, newest first.
  Stream<List<PurchaseModel>> getPurchasesStream() {
    return _collection(FirebaseConstants.purchasesCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PurchaseModel.fromMap(data);
            }).toList());
  }

  /// One-time fetch of all purchases.
  Future<List<PurchaseModel>> getPurchases() async {
    try {
      final snapshot =
          await _collection(FirebaseConstants.purchasesCollection)
              .orderBy('date', descending: true)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PurchaseModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('FirebaseService.getPurchases error: $e');
      return [];
    }
  }

  /// Fetch a single purchase by ID.
  Future<PurchaseModel?> getPurchaseById(String purchaseId) async {
    try {
      final doc = await _collection(FirebaseConstants.purchasesCollection).doc(purchaseId).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return PurchaseModel.fromMap(data);
      }
    } catch (e) {
      debugPrint('FirebaseService.getPurchaseById error: $e');
    }
    return null;
  }

  // ── Purchase Stock Increment ──────────────────────────────────

  /// Atomically increment stock for a single item (used after purchase).
  Future<double> incrementItemStock(
      String itemId, double quantityPurchased) async {
    final docRef =
        _collection(FirebaseConstants.itemsCollection).doc(itemId);

    final newStock = await _firestore.runTransaction<double>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        debugPrint('incrementItemStock: item $itemId not found');
        return -1;
      }

      final currentStock =
          (snapshot.data()?['stock'] as num?)?.toDouble() ?? 0;
      final ns = currentStock + quantityPurchased;

      transaction.update(docRef, {'stock': ns});
      return ns;
    });

    // Check low stock after transaction completes
    if (newStock >= 0) {
      await checkAndUpdateLowStock(itemId);
    }
    return newStock;
  }

  /// Increment stock for all line items in a purchase.
  Future<void> incrementStockForPurchase(PurchaseModel purchase) async {
    for (final lineItem in purchase.lineItems) {
      try {
        final newStock =
            await incrementItemStock(lineItem.itemId, lineItem.quantity);
        if (newStock >= 0) {
          debugPrint(
            'Stock incremented: ${lineItem.itemName} → $newStock (+${lineItem.quantity})',
          );
        }
      } catch (e) {
        debugPrint(
          'Stock increment failed for ${lineItem.itemName}: $e',
        );
      }
    }
  }

  /// Syncs inventory from a purchase: finds or creates items by normalised name,
  /// then increments stock and updates buyPrice. This is the smart replacement for
  /// [incrementStockForPurchase] that auto-creates missing inventory items.
  Future<void> syncInventoryFromPurchase(PurchaseModel purchase) async {
    for (final lineItem in purchase.lineItems) {
      final trimmedName = lineItem.itemName.trim();
      if (trimmedName.isEmpty || lineItem.quantity <= 0) {
        debugPrint('⏭ Skipping line item (empty name or invalid qty)');
        continue;
      }

      try {
        // Skip if this item was already linked to an existing inventory item
        if (lineItem.isFromInventory && lineItem.itemId.isNotEmpty) {
          // Just increment stock for existing items
          final newStock =
              await incrementItemStock(lineItem.itemId, lineItem.quantity);
          if (newStock >= 0) {
            // Also update buyPrice to latest purchase price
            await _collection(FirebaseConstants.itemsCollection)
                .doc(lineItem.itemId)
                .update({'buyPrice': lineItem.rate});
            debugPrint(
                '✓ Stock incremented: ${lineItem.itemName} → $newStock (+${lineItem.quantity})');
          }
          continue;
        }

        // For custom items — search by normalized name
        final normalizedName = trimmedName.toLowerCase();
        final snapshot = await _collection(FirebaseConstants.itemsCollection)
            .where('name_lowercase', isEqualTo: normalizedName)
            .limit(1)
            .get();

        if (snapshot.docs.isNotEmpty) {
          // Item exists in inventory — increment stock + update buyPrice
          final existingDoc = snapshot.docs.first;
          final existingId = existingDoc.id;
          final currentStock =
              (existingDoc.data()['stock'] as num?)?.toDouble() ?? 0;
          final newStock = currentStock + lineItem.quantity;

          await existingDoc.reference.update({
            'stock': newStock,
            'buyPrice': lineItem.rate,
          });
          await checkAndUpdateLowStock(existingId);
          debugPrint(
              '✓ Existing inventory updated: $trimmedName → stock $newStock (+${lineItem.quantity})');
        } else {
          // Item DOES NOT exist — create new inventory item
          final docRef =
              _collection(FirebaseConstants.itemsCollection).doc();
          final newItemData = {
            'id': docRef.id,
            'name': trimmedName,
            'name_lowercase': normalizedName,
            'unit': lineItem.unit,
            'stock': lineItem.quantity,
            'buyPrice': lineItem.rate,
            'sellPrice': 0.0,
            'taxRate': lineItem.taxRate,
            'alertLevel': 0,
            'createdAt': FieldValue.serverTimestamp(),
          };
          await docRef.set(newItemData);
          debugPrint(
              '✓ New inventory item created: $trimmedName (stock: ${lineItem.quantity}, buyPrice: ${lineItem.rate})');
        }
      } catch (e) {
        debugPrint(
            '⚠ syncInventoryFromPurchase failed for ${lineItem.itemName}: $e');
      }
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  PARTIES
  // ═══════════════════════════════════════════════════════════════

  /// Finds an existing party by mobile number or creates a new one.
  /// Returns the partyId. Uses mobile as the unique deduplication key.
  /// If mobile is empty, returns empty string (walk-in, no party created).
  Future<String> findOrCreateParty({
    required String name,
    required String mobile,
    required String type, // 'customer' or 'supplier'
  }) async {
    if (mobile.trim().isEmpty) {
      debugPrint('findOrCreateParty: no mobile → skip (walk-in)');
      return '';
    }

    try {
      // Query by mobile number for deduplication
      final snapshot = await _collection(FirebaseConstants.partiesCollection)
          .where('mobile', isEqualTo: mobile.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Party exists — update name if different
        final doc = snapshot.docs.first;
        final existingName = doc.data()['name'] as String? ?? '';
        if (existingName != name.trim() && name.trim().isNotEmpty) {
          await doc.reference.update({'name': name.trim()});
          debugPrint('✓ Party name updated: "$existingName" → "${name.trim()}"');
        }
        debugPrint('✓ Existing party found: ${doc.id}');
        return doc.id;
      }

      // Party doesn't exist — create new
      final docRef = _collection(FirebaseConstants.partiesCollection).doc();
      final partyData = {
        'id': docRef.id,
        'name': name.trim(),
        'mobile': mobile.trim(),
        'type': type,
        'balance': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await docRef.set(partyData);
      debugPrint('✓ New party created: ${docRef.id} ($name, $mobile, $type)');
      return docRef.id;
    } catch (e) {
      debugPrint('⚠ findOrCreateParty error: $e');
      return '';
    }
  }

  /// Add or overwrite a party document.
  Future<void> addParty(PartyModel party) async {
    try {
      await _collection(FirebaseConstants.partiesCollection)
          .doc(party.id)
          .set(party.toMap());
    } catch (e) {
      debugPrint('FirebaseService.addParty error: $e');
      rethrow;
    }
  }

  /// Real-time stream of all parties, ordered by name.
  Stream<List<PartyModel>> getPartiesStream() {
    return _collection(FirebaseConstants.partiesCollection)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return PartyModel.fromMap(data);
            }).toList());
  }

  /// One-time fetch of all parties.
  Future<List<PartyModel>> getParties() async {
    try {
      final snapshot = await _collection(FirebaseConstants.partiesCollection)
          .orderBy('name')
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return PartyModel.fromMap(data);
      }).toList();
    } catch (e) {
      debugPrint('FirebaseService.getParties error: $e');
      return [];
    }
  }

  /// Fetch a single party by ID. Returns null if not found.
  Future<PartyModel?> getPartyById(String partyId) async {
    try {
      final doc = await _collection(FirebaseConstants.partiesCollection)
          .doc(partyId)
          .get();
      if (!doc.exists) return null;
      final data = doc.data()!;
      data['id'] = doc.id;
      return PartyModel.fromMap(data);
    } catch (e) {
      debugPrint('FirebaseService.getPartyById error: $e');
      return null;
    }
  }

  /// Atomically update a party's balance using a Firestore transaction.
  /// [amount] is added to the current balance (can be negative).
  /// Sale → pass positive amount (party owes more).
  /// Purchase → pass negative amount (you owe more).
  Future<double> updatePartyBalance(String partyId, double amount) async {
    final docRef =
        _collection(FirebaseConstants.partiesCollection).doc(partyId);

    return _firestore.runTransaction<double>((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        debugPrint('updatePartyBalance: party $partyId not found');
        return 0;
      }

      final currentBalance =
          (snapshot.data()?['balance'] as num?)?.toDouble() ?? 0;
      final newBalance = currentBalance + amount;

      transaction.update(docRef, {'balance': newBalance});
      debugPrint(
        'Party balance updated: $partyId → $newBalance (was $currentBalance, changed by $amount)',
      );
      return newBalance;
    });
  }

  // ── Delete Operations ──────────────────────────────────────────

  /// Deletes a sale invoice and restores stock for inventory items.
  /// Also removes associated due records. Uses batch write for atomicity.
  Future<void> deleteSale(SaleModel sale) async {
    debugPrint('──── FirebaseService.deleteSale START ────');
    debugPrint('Sale ID: ${sale.id} | Invoice: ${sale.invoiceNumber}');

    try {
      final batch = _firestore.batch();

      // 1. Delete the sale document
      final saleRef = _collection(FirebaseConstants.salesCollection).doc(sale.id);
      batch.delete(saleRef);

      // 2. Delete associated due records
      final duesSnapshot = await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('dues')
          .where('referenceId', isEqualTo: sale.id)
          .get();

      for (final doc in duesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit batch (deletes sale doc + due records atomically)
      await batch.commit();
      debugPrint('✓ Sale and dues deleted');

      // 4. Restore stock via individual transactions (after batch)
      for (final lineItem in sale.lineItems) {
        if (lineItem.isFromInventory && lineItem.itemId.isNotEmpty) {
          try {
            // Add stock back (negative deduction = restoration)
            await updateItemStock(lineItem.itemId, -lineItem.quantity);
            debugPrint('✓ Stock restored: ${lineItem.itemName} +${lineItem.quantity}');
          } catch (e) {
            debugPrint('⚠ Stock restore failed for ${lineItem.itemName}: $e');
          }
        }
      }

      debugPrint('──── FirebaseService.deleteSale SUCCESS ────');
    } catch (e, stack) {
      debugPrint('✗ FirebaseService.deleteSale FAILED: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Deletes a purchase invoice and adjusts stock for inventory items.
  /// Also removes associated due records. Uses batch write for atomicity.
  Future<void> deletePurchase(PurchaseModel purchase) async {
    debugPrint('──── FirebaseService.deletePurchase START ────');
    debugPrint('Purchase ID: ${purchase.id} | Bill: ${purchase.billNumber}');

    try {
      final batch = _firestore.batch();

      // 1. Delete the purchase document
      final purchaseRef = _collection(FirebaseConstants.purchasesCollection)
          .doc(purchase.id);
      batch.delete(purchaseRef);

      // 2. Delete associated due records
      final duesSnapshot = await _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('dues')
          .where('referenceId', isEqualTo: purchase.id)
          .get();

      for (final doc in duesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit batch (deletes purchase doc + due records atomically)
      await batch.commit();
      debugPrint('✓ Purchase and dues deleted');

      // 3. Deduct stock back for inventory items (reverse the purchase)
      for (final lineItem in purchase.lineItems) {
        if (lineItem.itemId.isNotEmpty) {
          try {
            // Deduct the stock that was added during purchase
            await updateItemStock(lineItem.itemId, lineItem.quantity);
            debugPrint('✓ Stock reversed: ${lineItem.itemName} -${lineItem.quantity}');
          } catch (e) {
            debugPrint('⚠ Stock reversal failed for ${lineItem.itemName}: $e');
          }
        }
      }

      debugPrint('──── FirebaseService.deletePurchase SUCCESS ────');
    } catch (e, stack) {
      debugPrint('✗ FirebaseService.deletePurchase FAILED: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }

  /// Records a due entry in the dues collection.
  Future<void> recordDue({
    required String partyName,
    required double amount,
    required String type, // 'sale' or 'purchase'
    required String referenceId,
    String phoneNumber = '',
  }) async {
    try {
      final docRef = _firestore
          .collection(FirebaseConstants.businessesCollection)
          .doc(_businessId)
          .collection('dues')
          .doc();
      await docRef.set({
        'id': docRef.id,
        'partyName': partyName,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'type': type,
        'referenceId': referenceId,
        'date': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      debugPrint('✓ Due recorded: $type — amount $amount');
    } catch (e) {
      debugPrint('⚠ recordDue failed: $e');
    }
  }

  /// Streams pending dues for the current business.
  Stream<List<Map<String, dynamic>>> streamPendingDues() {
    return _firestore
        .collection(FirebaseConstants.businessesCollection)
        .doc(_businessId)
        .collection('dues')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  /// Delete a party by ID.
  Future<void> deleteParty(String partyId) async {
    try {
      await _collection(FirebaseConstants.partiesCollection)
          .doc(partyId)
          .delete();
    } catch (e) {
      debugPrint('FirebaseService.deleteParty error: $e');
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  //  TEST — Firestore connectivity check
  // ═══════════════════════════════════════════════════════════════

  /// Diagnostic function to verify Firestore can write data.
  Future<void> testFirestoreWrite() async {
    print('>>> TEST WRITE STARTED');

    try {
      final ref = await _firestore.collection('test_collection').add({
        'message': 'test working',
        'timestamp': DateTime.now().toString(),
      });
      print('>>> TEST WRITE SUCCESS — doc id: ${ref.id}');
    } catch (e) {
      print('>>> TEST WRITE FAILED: $e');
    }
  }
}
