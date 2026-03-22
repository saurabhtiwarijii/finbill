/// FinBill — Add Sale controller.
///
/// Manages the state of the invoice creation form: party info,
/// line items (add/update/remove), GST toggle, and dynamic total
/// calculations. Uses [InventoryController] to fetch available items
/// and [FirebaseService] to persist the sale.
///
/// File location: lib/features/sales/controllers/add_sale_controller.dart
import 'package:flutter/foundation.dart';
import '../../../models/sale_model.dart';
import '../../../models/item_model.dart';
import '../../../services/firebase_service.dart';
import '../../inventory/controllers/inventory_controller.dart';

class AddSaleController extends ChangeNotifier {
  AddSaleController({
    required this.inventoryController,
    required FirebaseService firebaseService,
  }) : _firebase = firebaseService;

  final InventoryController inventoryController;
  final FirebaseService _firebase;

  // ── Form state ────────────────────────────────────────────────
  String partyId = '';
  String partyName = '';
  String mobileNumber = '';
  DateTime saleDate = DateTime.now();
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

  /// Select a party from the autocomplete suggestions.
  void selectParty(String id, String name, String mobile) {
    partyId = id;
    partyName = name;
    mobileNumber = mobile;
    notifyListeners();
  }

  /// Clear party selection (e.g. when user edits name manually).
  void clearPartySelection() {
    partyId = '';
    notifyListeners();
  }

  // ── Edit mode ─────────────────────────────────────────────────
  bool isEditMode = false;
  SaleModel? _originalSale;

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

  final List<SaleLineItem> _lineItems = [];

  List<SaleLineItem> get lineItems => List.unmodifiable(_lineItems);
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

  /// Adds a blank line item card for manual entry.
  void addEmptyLineItem() {
    _lineItems.add(const SaleLineItem(
      itemName: '',
      quantity: 1,
      rate: 0,
      taxRate: 0,
      isFromInventory: false,
    ));
    notifyListeners();
  }

  /// Add a line item from an inventory item with given quantity.
  void addLineItem(ItemModel item, {double quantity = 1}) {
    _lineItems.add(SaleLineItem(
      itemId: item.id,
      itemName: item.name,
      unit: item.unit,
      quantity: quantity,
      rate: item.sellPrice,
      taxRate: hasGst ? item.taxRate : 0,
      isFromInventory: true,
    ));
    notifyListeners();
  }

  /// Populates an existing line item at [index] with inventory data.
  void populateFromInventory(int index, ItemModel item) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = SaleLineItem(
      itemId: item.id,
      itemName: item.name,
      unit: item.unit,
      quantity: _lineItems[index].quantity,
      rate: item.sellPrice,
      taxRate: hasGst ? item.taxRate : 0,
      isFromInventory: true,
    );
    notifyListeners();
  }

  /// Update the item name manually. If editing from an inventory item,
  /// this resets the `isFromInventory` flag.
  void updateItemName(int index, String name) {
    if (index < 0 || index >= _lineItems.length) return;
    final current = _lineItems[index];
    _lineItems[index] = current.copyWith(
      itemName: name,
      isFromInventory: false,
      itemId: '',
    );
    notifyListeners();
  }

  /// Update quantity for a line item at [index].
  void updateQuantity(int index, double quantity) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(quantity: quantity);
    notifyListeners();
  }

  /// Update rate for a line item at [index].
  void updateRate(int index, double rate) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(rate: rate);
    notifyListeners();
  }

  /// Update tax rate for a specific line item at [index].
  void updateTaxRate(int index, double taxRate) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems[index] = _lineItems[index].copyWith(taxRate: taxRate);
    notifyListeners();
  }

  /// Remove a line item at [index].
  void removeLineItem(int index) {
    if (index < 0 || index >= _lineItems.length) return;
    _lineItems.removeAt(index);
    notifyListeners();
  }

  // ── GST toggle ────────────────────────────────────────────────

  void toggleGst(bool value) {
    hasGst = value;
    // Recalculate tax for all line items
    for (int i = 0; i < _lineItems.length; i++) {
      if (_lineItems[i].isFromInventory) {
        final item = inventoryController.getById(_lineItems[i].itemId);
        _lineItems[i] = _lineItems[i].copyWith(
          taxRate: value ? (item?.taxRate ?? 0) : 0,
        );
      } else {
        // For manual items, reset tax rate
        _lineItems[i] = _lineItems[i].copyWith(
          taxRate: 0,
        );
      }
    }
    notifyListeners();
  }

  // ── Date ──────────────────────────────────────────────────────

  void setDate(DateTime date) {
    saleDate = date;
    notifyListeners();
  }

  // ── Save ──────────────────────────────────────────────────────

  String? _lastError;

  /// Last error message from [saveSale]. Useful for showing user feedback.
  String? get lastError => _lastError;

  /// Creates a [SaleModel] from current form state.
  SaleModel buildSale(String invoiceNumber) {
    final id = isEditMode ? _originalSale!.id : 'sale_${DateTime.now().millisecondsSinceEpoch}';
    return SaleModel(
      id: id,
      invoiceNumber: invoiceNumber,
      partyId: partyId,
      partyName: partyName,
      mobileNumber: mobileNumber,
      date: saleDate,
      hasGst: hasGst,
      lineItems: List.from(_lineItems),
      paymentMode: paymentMode,
      paidAmount: paidAmount,
      dueAmount: dueAmount,
    );
  }

  /// Pre-fills all form fields for editing an existing sale.
  void loadForEdit(SaleModel sale) {
    isEditMode = true;
    _originalSale = sale;
    partyId = sale.partyId;
    partyName = sale.partyName;
    mobileNumber = sale.mobileNumber;
    saleDate = sale.date;
    hasGst = sale.hasGst;
    _lineItems.clear();
    _lineItems.addAll(sale.lineItems);
    paymentMode = sale.paymentMode;
    if (paymentMode == 'split') {
      // For split, we don't know individual cash/card from stored data,
      // so set cashAmount = paidAmount and dueAmount = dueAmount
      cashAmount = sale.paidAmount;
      cardAmount = 0;
      splitDueAmount = sale.dueAmount;
    }
    notifyListeners();
  }

  /// Validates stock availability for all line items against Firestore.
  /// Returns null if all items have sufficient stock, or an error string.
  Future<String?> validateStock() async {
    for (final lineItem in _lineItems) {
      // Skip stock check for custom (non-inventory) items
      if (!lineItem.isFromInventory) continue;

      final item = await _firebase.getItemById(lineItem.itemId);

      if (item == null) {
        return 'Item "${lineItem.itemName}" not found in inventory';
      }

      if (item.stock < lineItem.quantity) {
        return 'Insufficient stock for "${lineItem.itemName}". '
            'Available: ${item.stock.toStringAsFixed(1)}, '
            'Required: ${lineItem.quantity.toStringAsFixed(1)}';
      }
    }
    return null; // all items have sufficient stock
  }

  /// Validates form + stock, saves to Firestore, then deducts stock.
  /// Returns the saved [SaleModel] on success, null on failure.
  /// Check [lastError] for the error message on failure.
  Future<SaleModel?> saveSale() async {
    print('>>> saveSale() STARTED');
    _lastError = null;

    // 1. Form validation
    final formError = validate();
    if (formError != null) {
      print('>>> Form validation failed: $formError');
      _lastError = formError;
      return null;
    }
    print('>>> Form OK | Party: $partyName | Items: ${_lineItems.length} | Total: $grandTotal');

    _isSaving = true;
    notifyListeners();

    try {
      // 2. Stock validation
      print('>>> Validating stock...');
      final stockError = await validateStock();
      if (stockError != null) {
        print('>>> Stock validation FAILED: $stockError');
        _lastError = stockError;
        return null;
      }
      print('>>> Stock validation PASSED');

      // 3. Auto-create/link party (Regular mode only)
      if (!isWalkIn && mobileNumber.trim().isNotEmpty) {
        print('>>> Finding or creating customer party...');
        final resolvedPartyId = await _firebase.findOrCreateParty(
          name: partyName,
          mobile: mobileNumber,
          type: 'customer',
        );
        if (resolvedPartyId.isNotEmpty) {
          partyId = resolvedPartyId;
          print('>>> Party linked: $partyId');
        }
      }

      // 4. Build the sale model
      String invoiceNumber;
      if (isEditMode) {
        invoiceNumber = _originalSale!.invoiceNumber;
        print('>>> Edit mode — keeping invoice: $invoiceNumber');
      } else {
        print('>>> Generating sequential invoice number...');
        invoiceNumber = await _firebase.generateInvoiceNumber();
      }
      final sale = buildSale(invoiceNumber);
      print('>>> SaleModel built — id: ${sale.id}, invoice: ${sale.invoiceNumber}');

      // 5. Save to Firestore
      if (isEditMode) {
        print('>>> === UPDATING SALE IN FIRESTORE ===');
        await _firebase.updateSale(sale);
      } else {
        print('>>> === SAVING SALE TO FIRESTORE ===');
        final saleData = sale.toMap();
        print('>>> Sale toMap() keys: ${saleData.keys.toList()}');
        final docId = await _firebase.addSale(sale);
        print('>>> === addSale returned: "$docId" ===');
      }

      // 6. Stock adjustment
      if (isEditMode) {
        print('>>> Reversing old stock...');
        // Restore stock from original sale items (pass negative to add back)
        for (final oldItem in _originalSale!.lineItems) {
          try {
            await _firebase.updateItemStock(oldItem.itemId, -oldItem.quantity);
          } catch (e) {
            print('>>> Stock restore failed for ${oldItem.itemName}: $e');
          }
        }
      }
      print('>>> Deducting new stock...');
      await _firebase.deductStockForSale(sale);
      print('>>> Stock adjusted');

      // 7. Record Due (do NOT update party balance yet)
      if (sale.dueAmount > 0) {
        try {
          await _firebase.recordDue(
            partyName: sale.partyName.isNotEmpty ? sale.partyName : 'Cash Sale',
            amount: sale.dueAmount,
            type: 'sale',
            referenceId: sale.id,
            phoneNumber: mobileNumber,
          );
        } catch (e) {
          debugPrint('>>> Due recording failed (non-fatal): $e');
        }
      }

      // 8. Update party balance (positive = customer owes more)
      if (partyId.isNotEmpty && sale.dueAmount > 0) {
        try {
          await _firebase.updatePartyBalance(partyId, sale.dueAmount);
          print('>>> Party balance updated: +${sale.dueAmount}');
        } catch (e) {
          debugPrint('>>> Party balance update failed (non-fatal): $e');
        }
      }

      print('>>> saveSale() SUCCESS');
      return sale;
    } catch (e, stack) {
      print('>>> saveSale() EXCEPTION: $e');
      print('>>> Stack: $stack');
      _lastError = 'Failed to save sale: $e';
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
      if (item.itemName.trim().isEmpty) return 'Item name cannot be empty';
      if (item.quantity <= 0) return 'Quantity must be greater than 0';
      if (item.rate <= 0) return 'Rate must be greater than 0';
    }
    if (paymentMode == 'split') {
      final diff = (cashAmount + cardAmount + splitDueAmount - grandTotal).abs();
      if (diff > 0.01) {
        return 'Amount mismatch! Cash + Card + Due must equal Total.';
      }
    }
    return null; // valid
  }
}

