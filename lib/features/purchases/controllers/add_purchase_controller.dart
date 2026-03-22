/// FinBill — Add Purchase controller.
///
/// Manages the state of the purchase creation form: supplier info,
/// line items (add/update/remove), GST toggle, and dynamic total
/// calculations. After saving, increments stock for purchased items.
///
/// File location: lib/features/purchases/controllers/add_purchase_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../../models/purchase_model.dart';
import '../../../models/item_model.dart';
import '../../../services/firebase_service.dart';
import '../../inventory/controllers/inventory_controller.dart';

class AddPurchaseController extends ChangeNotifier {
  AddPurchaseController({required this.inventoryController});

  final InventoryController inventoryController;
  final FirebaseService _firebase = FirebaseService.instance;

  // ── Form state ────────────────────────────────────────────────
  String partyId = '';
  String partyName = '';
  String mobileNumber = '';
  DateTime purchaseDate = DateTime.now();
  bool hasGst = false;
  bool _isSaving = false;
  bool isWalkIn = true;

  void toggleWalkIn(bool walkIn) {
    isWalkIn = walkIn;
    if (walkIn) {
      partyId = '';
    }
    notifyListeners();
  }

  void selectParty(String id, String name, String mobile) {
    partyId = id;
    partyName = name;
    mobileNumber = mobile;
    notifyListeners();
  }

  void clearPartySelection() {
    partyId = '';
    notifyListeners();
  }

  // ── Edit mode ─────────────────────────────────────────────────
  bool isEditMode = false;
  PurchaseModel? _originalPurchase;

  // ── Payment mode ──────────────────────────────────────────────
  String paymentMode = 'cash'; // cash, card, due, split
  double cashAmount = 0;
  double cardAmount = 0;
  double splitDueAmount = 0;

  double get paidAmount {
    switch (paymentMode) {
      case 'cash':
      case 'card':
        return grandTotal;
      case 'due':
        return 0;
      case 'split':
        return cashAmount + cardAmount;
      default:
        return grandTotal;
    }
  }

  double get dueAmount {
    switch (paymentMode) {
      case 'cash':
      case 'card':
        return 0;
      case 'due':
        return grandTotal;
      case 'split':
        return splitDueAmount;
      default:
        return 0;
    }
  }

  void setPaymentMode(String mode) {
    paymentMode = mode;
    if (mode != 'split') {
      cashAmount = 0;
      cardAmount = 0;
      splitDueAmount = 0;
    } else {
      splitDueAmount = grandTotal;
    }
    notifyListeners();
  }

  void setCashAmount(double amount) {
    cashAmount = amount;
    splitDueAmount = (grandTotal - cashAmount - cardAmount).clamp(0, double.infinity);
    notifyListeners();
  }

  void setCardAmount(double amount) {
    cardAmount = amount;
    splitDueAmount = (grandTotal - cashAmount - cardAmount).clamp(0, double.infinity);
    notifyListeners();
  }

  void setSplitDueAmount(double amount) {
    splitDueAmount = amount;
    notifyListeners();
  }

  final List<PurchaseLineItem> _lineItems = [];

  List<PurchaseLineItem> get lineItems => List.unmodifiable(_lineItems);
  bool get isSaving => _isSaving;

  // ── Computed totals ───────────────────────────────────────────

  double get subtotal =>
      _lineItems.fold(0, (sum, item) => sum + item.subtotal);

  double get totalTax =>
      _lineItems.fold(0, (sum, item) => sum + item.taxAmount);

  double get grandTotal => subtotal + totalTax;

  bool get hasItems => _lineItems.isNotEmpty;

  // ── Available inventory items ─────────────────────────────────

  List<ItemModel> get availableItems => inventoryController.items;

  // ── Line item operations ──────────────────────────────────────

  void addLineItem(ItemModel item, {double quantity = 1}) {
    _lineItems.add(PurchaseLineItem(
      itemId: item.id,
      itemName: item.name,
      unit: item.unit,
      quantity: quantity,
      rate: item.buyPrice,
      taxRate: hasGst ? item.taxRate : 0,
      isFromInventory: true,
    ));
    notifyListeners();
  }

  /// Add an empty line item for manual entry.
  void addEmptyLineItem() {
    _lineItems.add(const PurchaseLineItem(
      itemId: '',
      itemName: '',
      unit: 'pcs',
      quantity: 1,
      rate: 0,
      taxRate: 0,
      isFromInventory: false,
    ));
    notifyListeners();
  }

  /// Update item name for manual entry. Resets isFromInventory if user edits.
  void updateItemName(int index, String name) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(
      itemName: name,
      isFromInventory: false,
      itemId: '',
    );
    notifyListeners();
  }

  /// Populate line item from inventory selection (autocomplete or picker).
  void populateFromInventory(int index, ItemModel item) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = PurchaseLineItem(
      itemId: item.id,
      itemName: item.name,
      unit: item.unit,
      quantity: _lineItems[index].quantity,
      rate: item.buyPrice,
      taxRate: hasGst ? item.taxRate : 0,
      isFromInventory: true,
    );
    notifyListeners();
  }

  void updateQuantity(int index, double quantity) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(quantity: quantity);
    notifyListeners();
  }

  void updateRate(int index, double rate) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(rate: rate);
    notifyListeners();
  }

  void updateTaxRate(int index, double taxRate) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(taxRate: taxRate);
    notifyListeners();
  }

  void removeLineItem(int index) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems.removeAt(index);
    notifyListeners();
  }

  // ── GST toggle ────────────────────────────────────────────────

  void toggleGst(bool value) {
    hasGst = value;
    for (int i = 0; i < _lineItems.length; i++) {
      final item = inventoryController.getById(_lineItems[i].itemId);
      _lineItems[i] = _lineItems[i].copyWith(
        taxRate: value ? (item?.taxRate ?? 0) : 0,
      );
    }
    notifyListeners();
  }

  // ── Date ──────────────────────────────────────────────────────

  void setDate(DateTime date) {
    purchaseDate = date;
    notifyListeners();
  }

  // ── Build ─────────────────────────────────────────────────────

  PurchaseModel buildPurchase(String billNumber) {
    final id = isEditMode ? _originalPurchase!.id : 'pur_${DateTime.now().millisecondsSinceEpoch}';
    return PurchaseModel(
      id: id,
      billNumber: billNumber,
      partyId: partyId,
      partyName: partyName,
      mobileNumber: mobileNumber,
      date: purchaseDate,
      hasGst: hasGst,
      lineItems: List.from(_lineItems),
      paymentMode: paymentMode,
      paidAmount: paidAmount,
      dueAmount: dueAmount,
    );
  }

  /// Pre-fills all form fields for editing an existing purchase.
  void loadForEdit(PurchaseModel purchase) {
    isEditMode = true;
    _originalPurchase = purchase;
    partyId = purchase.partyId;
    partyName = purchase.partyName;
    mobileNumber = purchase.mobileNumber;
    purchaseDate = purchase.date;
    hasGst = purchase.hasGst;
    _lineItems.clear();
    _lineItems.addAll(purchase.lineItems);
    paymentMode = purchase.paymentMode;
    if (paymentMode == 'split') {
      cashAmount = purchase.paidAmount;
      cardAmount = 0;
      splitDueAmount = purchase.dueAmount;
    }
    notifyListeners();
  }

  // ── Save ──────────────────────────────────────────────────────

  /// Validates, builds, saves to Firestore, then increments stock.
  Future<PurchaseModel?> savePurchase() async {
    debugPrint('──── AddPurchaseController.savePurchase START ────');

    final error = validate();
    if (error != null) {
      debugPrint('✗ Validation failed: $error');
      return null;
    }
    debugPrint('✓ Validation passed');
    debugPrint('  Party: $partyName');
    debugPrint('  Items: ${_lineItems.length}');
    debugPrint('  Grand total: $grandTotal');

    _isSaving = true;
    notifyListeners();

    try {
      // 1. Auto-create/link party (Regular mode only)
      if (!isWalkIn && mobileNumber.trim().isNotEmpty) {
        debugPrint('Finding or creating supplier party...');
        final resolvedPartyId = await _firebase.findOrCreateParty(
          name: partyName,
          mobile: mobileNumber,
          type: 'supplier',
        );
        if (resolvedPartyId.isNotEmpty) {
          partyId = resolvedPartyId;
          debugPrint('✓ Party linked: $partyId');
        }
      }

      // 2. Generate sequential bill number
      String billNumber;
      if (isEditMode) {
        billNumber = _originalPurchase!.billNumber;
        debugPrint('Edit mode — keeping bill number: $billNumber');
      } else {
        debugPrint('Generating sequential purchase number...');
        billNumber = await _firebase.generatePurchaseNumber();
      }

      final purchase = buildPurchase(billNumber);
      debugPrint('✓ PurchaseModel built — id: ${purchase.id}, bill: ${purchase.billNumber}');

      // 2. Save the purchase to Firestore
      if (isEditMode) {
        debugPrint('Calling firebase.updatePurchase...');
        await _firebase.updatePurchase(purchase);
        debugPrint('✓ updatePurchase completed');
      } else {
        debugPrint('Calling firebase.addPurchase...');
        await _firebase.addPurchase(purchase);
        debugPrint('✓ addPurchase completed');
      }

      // 3. Stock adjustment + Inventory sync
      if (isEditMode) {
        // Reverse old purchase stock (old items were added, so now subtract)
        debugPrint('Reversing old purchase stock...');
        for (final oldItem in _originalPurchase!.lineItems) {
          try {
            await _firebase.updateItemStock(oldItem.itemId, oldItem.quantity);
          } catch (e) {
            debugPrint('⚠ Stock reversal failed for ${oldItem.itemName}: $e');
          }
        }
      }
      // Sync inventory: find or create items, then increment stock
      debugPrint('Syncing inventory from purchase...');
      await _firebase.syncInventoryFromPurchase(purchase);
      debugPrint('✓ Inventory synced');

      // 4. Record Due (do NOT update party balance yet)
      if (purchase.dueAmount > 0) {
        try {
          await _firebase.recordDue(
            partyName: purchase.partyName.isNotEmpty ? purchase.partyName : 'Cash Purchase',
            amount: purchase.dueAmount,
            type: 'purchase',
            referenceId: purchase.id,
            phoneNumber: mobileNumber,
          );
        } catch (e) {
          debugPrint('>>> Due recording failed (non-fatal): $e');
        }
      }

      // 5. Update party balance (negative = you owe supplier)
      if (partyId.isNotEmpty && purchase.dueAmount > 0) {
        try {
          await _firebase.updatePartyBalance(partyId, -purchase.dueAmount);
          debugPrint('✓ Party balance updated: -${purchase.dueAmount}');
        } catch (e) {
          debugPrint('⚠ Party balance update failed (non-fatal): $e');
        }
      }

      debugPrint('──── AddPurchaseController.savePurchase SUCCESS ────');
      return purchase;
    } catch (e, stack) {
      debugPrint('✗ savePurchase FAILED: $e');
      debugPrint('Stack: $stack');
      return null;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Validates the form has minimum required data.
  String? validate() {
    if (_lineItems.isEmpty) return 'Add at least one item';
    for (final item in _lineItems) {
      if (item.quantity <= 0) return 'Quantity must be greater than 0';
      if (item.rate <= 0) return 'Rate must be greater than 0';
    }
    if (paymentMode == 'split') {
      final diff = (cashAmount + cardAmount + splitDueAmount - grandTotal).abs();
      if (diff > 0.01) {
        return 'Amount mismatch! Cash + Card + Due must equal Total.';
      }
    }
    return null;
  }
}
