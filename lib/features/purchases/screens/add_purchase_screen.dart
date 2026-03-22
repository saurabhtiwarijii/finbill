/// FinBill — Add Purchase screen.
///
/// Full purchase creation form with:
///   1. Supplier info (name, mobile)
///   2. Date picker
///   3. GST toggle
///   4. Line items (from inventory) with quantity/rate editing
///   5. Dynamic subtotal / tax / grand total
///   6. Save / Cancel
///
/// File location: lib/features/purchases/screens/add_purchase_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../widgets/primary_button.dart';
import '../../../models/party_model.dart';
import '../../../models/purchase_model.dart';
import '../../../services/firebase_service.dart';
import '../../inventory/controllers/inventory_controller.dart';
import '../controllers/add_purchase_controller.dart';
import '../widgets/purchase_line_item_row.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key, this.existingPurchase});

  final PurchaseModel? existingPurchase;

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  late final InventoryController _inventoryController;
  late final AddPurchaseController _controller;

  final _partyCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _partyFocusNode = FocusNode();
  List<PartyModel> _parties = [];
  bool _isAutoFilling = false;

  @override
  void initState() {
    super.initState();
    _inventoryController = InventoryController();
    _controller = AddPurchaseController(
      inventoryController: _inventoryController,
    );

    // Load parties once for autocomplete
    FirebaseService.instance.getParties().then((parties) {
      if (mounted) setState(() => _parties = parties);
    });

    // Pre-fill if editing
    if (widget.existingPurchase != null) {
      _controller.loadForEdit(widget.existingPurchase!);
      _partyCtrl.text = widget.existingPurchase!.partyName;
      _mobileCtrl.text = widget.existingPurchase!.mobileNumber;
    }
  }

  @override
  void dispose() {
    _partyCtrl.dispose();
    _mobileCtrl.dispose();
    _partyFocusNode.dispose();
    _controller.dispose();
    _inventoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_controller.isEditMode ? 'Edit Purchase' : 'Add Purchase'),
        actions: [
          TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) =>
                  Text(DateFormatter.formatRelative(_controller.purchaseDate)),
            ),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPartySection(),
                      const SizedBox(height: AppSizes.lg),
                      _buildGstToggle(),
                      const SizedBox(height: AppSizes.md),
                      _buildItemsSection(),
                      const SizedBox(height: AppSizes.lg),
                      _buildPaymentSection(),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Section builders
  // ═══════════════════════════════════════════════════════════════

  Widget _buildPartySection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with toggle
          Row(
            children: [
              const Text('Supplier Details', style: AppTextStyles.bodyMedium),
              const Spacer(),
              _partyModeChip('Walk-in', true),
              const SizedBox(width: AppSizes.xs),
              _partyModeChip('Regular', false),
            ],
          ),
          const SizedBox(height: AppSizes.md),

          // Supplier name (with or without autocomplete)
          if (_controller.isWalkIn)
            TextFormField(
              controller: _partyCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Supplier Name',
                hintText: 'Supplier / vendor name',
                prefixIcon: Icon(Icons.store_outlined, size: 20),
              ),
              onChanged: (v) => _controller.partyName = v,
            )
          else
            _buildSupplierAutocomplete(),
          const SizedBox(height: AppSizes.md),

          // Mobile number
          TextFormField(
            controller: _mobileCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            decoration: const InputDecoration(
              labelText: 'Mobile Number',
              hintText: '10-digit mobile',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
            onChanged: (v) => _controller.mobileNumber = v,
          ),
        ],
      ),
    );
  }

  Widget _partyModeChip(String label, bool isWalkIn) {
    final selected = _controller.isWalkIn == isWalkIn;
    return GestureDetector(
      onTap: () => _controller.toggleWalkIn(isWalkIn),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierAutocomplete() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<PartyModel>(
          textEditingController: _partyCtrl,
          focusNode: _partyFocusNode,
          optionsBuilder: (textEditingValue) {
            final query = textEditingValue.text;
            if (query.length < 2) return [];
            final q = query.toLowerCase();
            return _parties
                .where((p) =>
                    p.type == PartyType.supplier &&
                    p.name.toLowerCase().contains(q))
                .take(8)
                .toList();
          },
          displayStringForOption: (party) => party.name,
          onSelected: (party) {
            _isAutoFilling = true;
            _controller.selectParty(party.id, party.name, party.mobile);
            _mobileCtrl.text = party.mobile;
            _isAutoFilling = false;
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Container(
                  width: constraints.maxWidth,
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: options.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(AppSizes.md),
                          child: Text('No suppliers found',
                              style: AppTextStyles.caption),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final party = options.elementAt(i);
                            return InkWell(
                              onTap: () => onSelected(party),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSizes.md,
                                  vertical: AppSizes.sm,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.store_outlined,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(party.name,
                                              style:
                                                  AppTextStyles.bodyMedium,
                                              maxLines: 1,
                                              overflow:
                                                  TextOverflow.ellipsis),
                                          if (party.mobile.isNotEmpty)
                                            Text(party.mobile,
                                                style:
                                                    AppTextStyles.caption),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, textController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Supplier Name',
                hintText: 'Type to search suppliers',
                prefixIcon:
                    const Icon(Icons.store_outlined, size: 20),
                suffixIcon: _controller.partyId.isNotEmpty
                    ? const Icon(Icons.check_circle,
                        color: AppColors.success, size: 20)
                    : null,
              ),
              onChanged: (v) {
                if (!_isAutoFilling) {
                  _controller.partyName = v;
                  _controller.clearPartySelection();
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildGstToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 20, color: AppColors.iconDefault),
          const SizedBox(width: AppSizes.md),
          const Expanded(
            child: Text('Include GST', style: AppTextStyles.bodyMedium),
          ),
          Switch(
            value: _controller.hasGst,
            onChanged: _controller.toggleGst,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Items', style: AppTextStyles.label),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _controller.addEmptyLineItem(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text(AppStrings.addItem),
            ),
          ],
        ),
        const SizedBox(height: AppSizes.sm),

        if (!_controller.hasItems)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSizes.xl),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppSizes.radiusMd),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                const Icon(Icons.add_shopping_cart_outlined,
                    size: 40, color: AppColors.textHint),
                const SizedBox(height: AppSizes.sm),
                Text(
                  'No items added yet',
                  style: AppTextStyles.caption.copyWith(fontSize: 14),
                ),
                const SizedBox(height: AppSizes.sm),
                TextButton(
                  onPressed: () => _controller.addEmptyLineItem(),
                  child: const Text('Tap to add items'),
                ),
              ],
            ),
          )
        else
          ...List.generate(_controller.lineItems.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.sm),
              child: PurchaseLineItemRow(
                key: ValueKey('line_item_$i'),
                index: i,
                lineItem: _controller.lineItems[i],
                hasGst: _controller.hasGst,
                inventoryItems: _controller.availableItems,
                onNameChanged: (n) => _controller.updateItemName(i, n),
                onQuantityChanged: (q) => _controller.updateQuantity(i, q),
                onRateChanged: (r) => _controller.updateRate(i, r),
                onTaxRateChanged: (t) => _controller.updateTaxRate(i, t),
                onRemove: () => _controller.removeLineItem(i),
                onPickFromInventory: () => _showItemPicker(i),
                onInventoryItemSelected: (item) => _controller.populateFromInventory(i, item),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Mode', style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSizes.md),
          Row(
            children: [
              _paymentChip('cash', 'Cash', Icons.money_rounded),
              const SizedBox(width: AppSizes.sm),
              _paymentChip('card', 'Card', Icons.credit_card_rounded),
              const SizedBox(width: AppSizes.sm),
              _paymentChip('due', 'Due', Icons.schedule_rounded),
              const SizedBox(width: AppSizes.sm),
              _paymentChip('split', 'Split', Icons.call_split_rounded),
            ],
          ),
          if (_controller.paymentMode == 'split') ...[
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _controller.cashAmount > 0 ? _controller.cashAmount.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cash Amount',
                      prefixIcon: Icon(Icons.money_rounded, size: 20),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        _controller.setCashAmount(double.tryParse(v) ?? 0),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: TextFormField(
                    initialValue: _controller.cardAmount > 0 ? _controller.cardAmount.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Card Amount',
                      prefixIcon: Icon(Icons.credit_card_rounded, size: 20),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        _controller.setCardAmount(double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _controller.splitDueAmount > 0 ? _controller.splitDueAmount.toString() : '',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Due Amount',
                      prefixIcon: Icon(Icons.schedule_rounded, size: 20),
                      isDense: true,
                    ),
                    onChanged: (v) =>
                        _controller.setSplitDueAmount(double.tryParse(v) ?? 0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            if ((_controller.cashAmount + _controller.cardAmount + _controller.splitDueAmount - _controller.grandTotal).abs() > 0.01)
              Text(
                'Amount mismatch! Cash + Card + Due must equal Total.',
                style: AppTextStyles.caption.copyWith(color: AppColors.error),
              ),
          ],
        ],
      ),
    );
  }

  Widget _paymentChip(String mode, String label, IconData icon) {
    final isSelected = _controller.paymentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => _controller.setPaymentMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.iconDefault),
              const SizedBox(height: 2),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Bottom bar
  // ═══════════════════════════════════════════════════════════════

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.cardBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_controller.hasItems) ...[
              _totalRow('Subtotal', _controller.subtotal),
              if (_controller.hasGst)
                _totalRow('Tax', _controller.totalTax,
                    color: AppColors.success),
              const Divider(height: AppSizes.md),
              _totalRow(
                'Grand Total',
                _controller.grandTotal,
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: AppSizes.md),
            ],
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: AppStrings.cancel,
                    variant: PrimaryButtonVariant.outlined,
                    isExpanded: true,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: AppSizes.md),
                Expanded(
                  child: PrimaryButton(
                    label: _controller.isSaving
                        ? 'Saving...'
                        : _controller.isEditMode
                            ? 'UPDATE'
                            : AppStrings.save,
                    isExpanded: true,
                    isLoading: _controller.isSaving,
                    onPressed:
                        _controller.isSaving ? null : _savePurchase,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double amount,
      {TextStyle? style, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style ?? AppTextStyles.bodyMedium),
          Text(
            CurrencyFormatter.format(amount),
            style: (style ?? AppTextStyles.bodyMedium).copyWith(color: color),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  //  Actions
  // ═══════════════════════════════════════════════════════════════

  void _showItemPicker(int index) {
    final items = _controller.availableItems;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No inventory items. Add items in Menu → Inventory.'),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusLg),
        ),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, scrollCtrl) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: AppSizes.sm),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(AppSizes.md),
                  child: Text('Select Item', style: AppTextStyles.h3),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.all(AppSizes.sm),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSizes.xs),
                    itemBuilder: (_, i) {
                      final item = items[i];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(AppSizes.sm),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius:
                                BorderRadius.circular(AppSizes.radiusSm),
                          ),
                          child: const Icon(Icons.inventory_2_outlined,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(item.name,
                            style: AppTextStyles.bodyMedium),
                        subtitle: Text(
                          '${CurrencyFormatter.format(item.buyPrice)} / ${item.unit}  •  Stock: ${item.stock}',
                          style: AppTextStyles.caption,
                        ),
                        trailing: const Icon(Icons.add_circle_outline,
                            color: AppColors.primary),
                        onTap: () {
                          _controller.populateFromInventory(index, item);
                          Navigator.of(ctx).pop();
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _controller.purchaseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      _controller.setDate(picked);
    }
  }

  Future<void> _savePurchase() async {
    debugPrint('──── _savePurchase (screen) triggered ────');

    final error = _controller.validate();
    if (error != null) {
      debugPrint('✗ Screen validation failed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    debugPrint('Calling controller.savePurchase()...');
    final purchase = await _controller.savePurchase();
    debugPrint(
        'controller.savePurchase() returned: ${purchase != null ? 'SUCCESS' : 'NULL'}');

    if (!mounted) {
      debugPrint('✗ Widget not mounted after save');
      return;
    }

    if (purchase != null) {
      debugPrint('✓ Navigating back with purchase ${purchase.id}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(purchase);
    } else {
      debugPrint('✗ Save returned null — showing error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Failed to save purchase. Check debug console for details.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
