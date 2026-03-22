/// FinBill — Inventory list screen.
///
/// Displays all inventory items as expandable cards with search and
/// a FAB to add new items. Uses [InventoryController] for state.
///
/// File location: lib/features/inventory/screens/inventory_screen.dart
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/custom_search_bar.dart';
import '../../../widgets/empty_state_widget.dart';
import '../../../widgets/custom_floating_button.dart';
import '../../../models/item_model.dart';
import '../controllers/inventory_controller.dart';
import '../widgets/item_card.dart';
import 'add_item_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final _controller = InventoryController();

  @override
  void initState() {
    super.initState();
    _controller.loadItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.manageInventory),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          return Column(
            children: [
              // ── Stats bar ─────────────────────────────────────
              if (!_controller.isEmpty) _buildStatsBar(),

              // ── Search ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(AppSizes.md),
                child: CustomSearchBar(
                  hintText: AppStrings.searchInventory,
                  onChanged: _controller.search,
                ),
              ),

              // ── Content ──────────────────────────────────────
              Expanded(
                child: _controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _controller.isEmpty
                        ? const EmptyStateWidget(
                            message: AppStrings.noItems,
                            subtitle: 'Add items to track your inventory',
                            icon: Icons.inventory_2_outlined,
                          )
                        : _buildItemList(),
              ),
            ],
          );
        },
      ),

      // ── FAB: Add Item ─────────────────────────────────────────
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        label: AppStrings.addItem,
        heroTag: 'inventory_fab',
        onPressed: () => _navigateToAddItem(),
      ),
    );
  }

  // ── Stats bar ─────────────────────────────────────────────────

  Widget _buildStatsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.sm + 4,
      ),
      color: AppColors.surface,
      child: Row(
        children: [
          _statChip(
            '${_controller.totalItems} items',
            Icons.inventory_2_outlined,
            AppColors.primary,
          ),
          const SizedBox(width: AppSizes.sm),
          if (_controller.lowStockCount > 0)
            _statChip(
              '${_controller.lowStockCount} low stock',
              Icons.warning_amber_rounded,
              AppColors.warning,
            ),
        ],
      ),
    );
  }

  Widget _statChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Item list ─────────────────────────────────────────────────

  Widget _buildItemList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.md,
        0,
        AppSizes.md,
        AppSizes.xxl + AppSizes.xl, // room for FAB
      ),
      itemCount: _controller.items.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSizes.sm),
      itemBuilder: (context, index) {
        final item = _controller.items[index];
        return ItemCard(
          item: item,
          onEdit: () => _navigateToAddItem(editItem: item),
          onDelete: () => _confirmDelete(item),
        );
      },
    );
  }

  // ── Navigation ────────────────────────────────────────────────

  Future<void> _navigateToAddItem({ItemModel? editItem}) async {
    final result = await Navigator.of(context).push<ItemModel>(
      MaterialPageRoute(
        builder: (_) => AddItemScreen(
          controller: _controller,
          editItem: editItem,
        ),
      ),
    );
    // result is non-null if an item was saved
    if (result != null && mounted) {
      // Controller already has the item — just trigger rebuild
    }
  }

  // ── Delete confirmation ───────────────────────────────────────

  void _confirmDelete(ItemModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              _controller.deleteItem(item.id);
              Navigator.of(ctx).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }
}
