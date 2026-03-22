/// FinBill — Purchase line item card widget.
///
/// Renders a fully editable item card with:
///   - Editable item name with real-time autocomplete suggestions
///   - Suffix icon to open full inventory picker
///   - Quantity, Rate, GST fields
///   - Computed total display
///   - Remove button
///
/// File location: lib/features/purchases/widgets/purchase_line_item_row.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/purchase_model.dart';
import '../../../models/item_model.dart';

class PurchaseLineItemRow extends StatefulWidget {
  const PurchaseLineItemRow({
    super.key,
    required this.index,
    required this.lineItem,
    required this.hasGst,
    required this.inventoryItems,
    required this.onNameChanged,
    required this.onQuantityChanged,
    required this.onRateChanged,
    required this.onTaxRateChanged,
    required this.onRemove,
    required this.onPickFromInventory,
    required this.onInventoryItemSelected,
  });

  final int index;
  final PurchaseLineItem lineItem;
  final bool hasGst;
  final List<ItemModel> inventoryItems;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<double> onQuantityChanged;
  final ValueChanged<double> onRateChanged;
  final ValueChanged<double> onTaxRateChanged;
  final VoidCallback onRemove;
  final VoidCallback onPickFromInventory;
  final ValueChanged<ItemModel> onInventoryItemSelected;

  @override
  State<PurchaseLineItemRow> createState() => _PurchaseLineItemRowState();
}

class _PurchaseLineItemRowState extends State<PurchaseLineItemRow> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _qtyCtrl;
  late final TextEditingController _rateCtrl;
  late final TextEditingController _taxCtrl;
  final FocusNode _nameFocus = FocusNode();

  bool _isAutofilling = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.lineItem.itemName);
    _qtyCtrl = TextEditingController(
      text: widget.lineItem.quantity == 1 ? '1' : _formatNum(widget.lineItem.quantity),
    );
    _rateCtrl = TextEditingController(
      text: widget.lineItem.rate == 0 ? '' : _formatNum(widget.lineItem.rate),
    );
    _taxCtrl = TextEditingController(
      text: widget.lineItem.taxRate == 0 ? '' : _formatNum(widget.lineItem.taxRate),
    );
  }

  @override
  void didUpdateWidget(covariant PurchaseLineItemRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.lineItem.itemName != widget.lineItem.itemName &&
        widget.lineItem.isFromInventory) {
      _nameCtrl.text = widget.lineItem.itemName;
      _nameCtrl.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameCtrl.text.length),
      );
    }
    if (oldWidget.lineItem.rate != widget.lineItem.rate &&
        widget.lineItem.isFromInventory) {
      _rateCtrl.text = widget.lineItem.rate == 0 ? '' : _formatNum(widget.lineItem.rate);
    }
    if (oldWidget.lineItem.taxRate != widget.lineItem.taxRate &&
        widget.lineItem.isFromInventory) {
      _taxCtrl.text = widget.lineItem.taxRate == 0 ? '' : _formatNum(widget.lineItem.taxRate);
    }
  }

  String _formatNum(double v) {
    return v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);
  }

  List<ItemModel> _filterItems(String query) {
    if (query.length < 2) return [];
    final q = query.toLowerCase();
    return widget.inventoryItems
        .where((item) => item.name.toLowerCase().contains(q))
        .take(10)
        .toList();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _qtyCtrl.dispose();
    _rateCtrl.dispose();
    _taxCtrl.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          // ── Header: item number + badge + remove ────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                ),
                child: Text(
                  'Item ${widget.index + 1}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (widget.lineItem.isFromInventory) ...[
                const SizedBox(width: AppSizes.xs),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                  ),
                  child: Text(
                    'Inventory',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              InkWell(
                onTap: widget.onRemove,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.sm),

          // ── Item Name with Autocomplete ──────────────────
          _buildNameFieldWithAutocomplete(),
          const SizedBox(height: AppSizes.md),

          // ── Qty, Rate, GST row ──────────────────────────
          Row(
            children: [
              Expanded(
                child: _CompactField(
                  label: 'Qty',
                  controller: _qtyCtrl,
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    if (val != null) widget.onQuantityChanged(val);
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              Expanded(
                child: _CompactField(
                  label: 'Rate (\u20b9)',
                  controller: _rateCtrl,
                  onChanged: (v) {
                    final val = double.tryParse(v);
                    if (val != null) widget.onRateChanged(val);
                  },
                ),
              ),
              const SizedBox(width: AppSizes.sm),
              if (widget.hasGst)
                Expanded(
                  child: _CompactField(
                    label: 'GST %',
                    controller: _taxCtrl,
                    onChanged: (v) {
                      final val = double.tryParse(v);
                      if (val != null) widget.onTaxRateChanged(val);
                    },
                  ),
                ),
              if (!widget.hasGst) const SizedBox(width: AppSizes.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total', style: AppTextStyles.caption),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(widget.lineItem.total),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Tax info line ───────────────────────────────
          if (widget.hasGst && widget.lineItem.taxRate > 0) ...[
            const SizedBox(height: AppSizes.xs),
            Text(
              'Tax ${_formatNum(widget.lineItem.taxRate)}%: ${CurrencyFormatter.format(widget.lineItem.taxAmount)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.success,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNameFieldWithAutocomplete() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return RawAutocomplete<ItemModel>(
          textEditingController: _nameCtrl,
          focusNode: _nameFocus,
          optionsBuilder: (textEditingValue) {
            return _filterItems(textEditingValue.text);
          },
          displayStringForOption: (item) => item.name,
          onSelected: (ItemModel item) {
            _isAutofilling = true;
            widget.onInventoryItemSelected(item);
            _isAutofilling = false;
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
                          child: Text(
                            'No items found',
                            style: AppTextStyles.caption,
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final item = options.elementAt(index);
                            return InkWell(
                              onTap: () => onSelected(item),
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
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Icon(
                                        Icons.inventory_2_outlined,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: AppSizes.sm),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: AppTextStyles.bodyMedium,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            '${CurrencyFormatter.format(item.buyPrice)} / ${item.unit}',
                                            style: AppTextStyles.caption,
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (item.taxRate > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'GST ${_formatNum(item.taxRate)}%',
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.success,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
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
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            return TextFormField(
              controller: textController,
              focusNode: focusNode,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: 'Item Name',
                hintText: 'Type to search or enter custom item',
                isDense: true,
                prefixIcon: const Icon(Icons.edit_outlined, size: 18),
                suffixIcon: IconButton(
                  icon: const Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Browse Inventory',
                  onPressed: widget.onPickFromInventory,
                ),
              ),
              onChanged: (value) {
                if (!_isAutofilling) {
                  widget.onNameChanged(value);
                }
              },
            );
          },
        );
      },
    );
  }
}

/// Compact numeric field used for inline quantity/rate/gst editing.
class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 4),
        SizedBox(
          height: 36,
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
            ],
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.sm,
                vertical: 6,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
