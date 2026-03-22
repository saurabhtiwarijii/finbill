/// FinBill — Add Party screen.
///
/// Form to create a new customer or supplier with name, mobile,
/// and type selection.
///
/// File location: lib/features/parties/screens/add_party_screen.dart
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/party_model.dart';
import '../../../services/firebase_service.dart';
import '../../../widgets/primary_button.dart';

class AddPartyScreen extends StatefulWidget {
  const AddPartyScreen({super.key});

  @override
  State<AddPartyScreen> createState() => _AddPartyScreenState();
}

class _AddPartyScreenState extends State<AddPartyScreen> {
  final _nameCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  PartyType _type = PartyType.customer;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Party')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Type Selector ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Party Type', style: AppTextStyles.label),
                  const SizedBox(height: AppSizes.md),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeChip(
                          label: 'Customer',
                          icon: Icons.person_outline,
                          isSelected: _type == PartyType.customer,
                          color: AppColors.primary,
                          onTap: () => setState(
                              () => _type = PartyType.customer),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: _TypeChip(
                          label: 'Vendor',
                          icon: Icons.store_outlined,
                          isSelected: _type == PartyType.supplier,
                          color: AppColors.secondary,
                          onTap: () => setState(
                              () => _type = PartyType.supplier),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSizes.lg),

            // ── Name field ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSizes.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: _type == PartyType.customer
                          ? 'Customer Name'
                          : 'Vendor Name',
                      hintText: 'Enter name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  // ── Mobile field ──────────────────────────────
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Row(
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
                  label: _isSaving ? 'Saving...' : AppStrings.save,
                  isExpanded: true,
                  isLoading: _isSaving,
                  onPressed: _isSaving ? null : _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final party = PartyModel(
        id: 'party_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        mobile: _mobileCtrl.text.trim(),
        type: _type,
        balance: 0,
      );

      await FirebaseService.instance.addParty(party);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Party added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(party);
    } catch (e) {
      debugPrint('AddParty error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add party: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Type selection chip
// ═══════════════════════════════════════════════════════════════════

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.md,
          vertical: AppSizes.sm + 4,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          border: Border.all(
            color: isSelected ? color : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: isSelected ? color : AppColors.textHint),
            const SizedBox(width: AppSizes.sm),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
