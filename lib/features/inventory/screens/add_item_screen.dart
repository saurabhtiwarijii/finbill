/// FinBill — Add / Edit item screen.
///
/// Form screen for creating a new inventory item or editing an
/// existing one. All fields are validated before save. On save,
/// the item is added/updated in [InventoryController] and the
/// screen pops with the result.
///
/// File location: lib/features/inventory/screens/add_item_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/primary_button.dart';
import '../../../models/item_model.dart';
import '../controllers/inventory_controller.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({
    super.key,
    required this.controller,
    this.editItem,
  });

  final InventoryController controller;
  final ItemModel? editItem;

  bool get isEditing => editItem != null;

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _sellPriceCtrl;
  late final TextEditingController _buyPriceCtrl;
  late final TextEditingController _stockCtrl;
  late final TextEditingController _alertCtrl;
  late final TextEditingController _taxCtrl;

  String _selectedUnit = 'pcs';

  static const _units = ['pcs', 'kg', 'g', 'liter', 'ml', 'box', 'dozen'];

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;

    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _sellPriceCtrl = TextEditingController(
      text: item != null ? item.sellPrice.toString() : '',
    );
    _buyPriceCtrl = TextEditingController(
      text: item != null ? item.buyPrice.toString() : '',
    );
    _stockCtrl = TextEditingController(
      text: item != null ? item.stock.toString() : '',
    );
    _alertCtrl = TextEditingController(
      text: item != null ? item.alertLevel.toString() : '',
    );
    _taxCtrl = TextEditingController(
      text: item != null ? item.taxRate.toString() : '',
    );
    _selectedUnit = item?.unit ?? 'pcs';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sellPriceCtrl.dispose();
    _buyPriceCtrl.dispose();
    _stockCtrl.dispose();
    _alertCtrl.dispose();
    _taxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Item' : 'Add Item'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Item Name ───────────────────────────────────
              _buildLabel('Item Name *'),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Toor Dal, Basmati Rice',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Item name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Unit ────────────────────────────────────────
              _buildLabel('Unit'),
              const SizedBox(height: AppSizes.sm),
              DropdownButtonFormField<String>(
                initialValue: _selectedUnit,
                decoration: const InputDecoration(),
                items: _units.map((u) {
                  return DropdownMenuItem(value: u, child: Text(u));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedUnit = v);
                },
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Pricing row ─────────────────────────────────
              _buildLabel('Pricing'),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _sellPriceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Sell Price (₹)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _buyPriceCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Buy Price (₹)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Stock row ───────────────────────────────────
              _buildLabel('Stock & Alerts'),
              const SizedBox(height: AppSizes.sm),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Opening Stock ($_selectedUnit)',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.md),
                  Expanded(
                    child: TextFormField(
                      controller: _alertCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: 'Alert Level ($_selectedUnit)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.lg),

              // ── Tax Rate ────────────────────────────────────
              _buildLabel('Tax Rate'),
              const SizedBox(height: AppSizes.sm),
              TextFormField(
                controller: _taxCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                decoration: const InputDecoration(
                  labelText: 'Tax Rate (%)',
                  hintText: 'e.g. 18',
                ),
              ),
              const SizedBox(height: AppSizes.xl),

              // ── Buttons ─────────────────────────────────────
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
                      label: AppStrings.save,
                      isExpanded: true,
                      onPressed: _saveItem,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(text, style: AppTextStyles.label);
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final item = ItemModel(
      id: widget.editItem?.id ?? widget.controller.generateId(),
      name: _nameCtrl.text.trim(),
      unit: _selectedUnit,
      sellPrice: double.tryParse(_sellPriceCtrl.text) ?? 0,
      buyPrice: double.tryParse(_buyPriceCtrl.text) ?? 0,
      stock: double.tryParse(_stockCtrl.text) ?? 0,
      taxRate: double.tryParse(_taxCtrl.text) ?? 0,
      alertLevel: int.tryParse(_alertCtrl.text) ?? 0,
    );

    if (widget.isEditing) {
      await widget.controller.updateItem(item);
    } else {
      await widget.controller.addItem(item);
    }

    if (mounted) Navigator.of(context).pop(item);
  }
}
