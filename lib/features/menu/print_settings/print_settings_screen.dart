/// FinBill — Print Settings Screen.
///
/// UI form for configuring invoice print appearance.
///
/// File location: lib/features/menu/print_settings/print_settings_screen.dart
library;

import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/primary_button.dart';
import 'print_settings_controller.dart';

class PrintSettingsScreen extends StatefulWidget {
  const PrintSettingsScreen({super.key});

  @override
  State<PrintSettingsScreen> createState() => _PrintSettingsScreenState();
}

class _PrintSettingsScreenState extends State<PrintSettingsScreen> {
  final _controller = PrintSettingsController();
  final _formKey = GlobalKey<FormState>();

  final _prefixController = TextEditingController();
  final _footerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (_controller.isLoading) return;

    if (_prefixController.text.isEmpty && _controller.invoicePrefix.isNotEmpty) {
      _prefixController.text = _controller.invoicePrefix;
      _footerController.text = _controller.footerNote;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    _prefixController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    _controller.updateFields(
      invoicePrefix: _prefixController.text,
      footerNote: _footerController.text,
    );

    final success = await _controller.saveSettings();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Print Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final msg = _controller.lastError ?? 'Failed to save settings';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Print Settings'),
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Invoice Branding',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSizes.sm),
                  const Text(
                    'Configure what information appears on your printed invoices and PDFs.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Toggles
                  SwitchListTile(
                    title: const Text('Show Business Logo', style: AppTextStyles.bodyLarge),
                    contentPadding: EdgeInsets.zero,
                    value: _controller.showLogo,
                    onChanged: (val) => _controller.updateToggles(showLogo: val),
                  ),
                  const Divider(),

                  SwitchListTile(
                    title: const Text('Show GST Details', style: AppTextStyles.bodyLarge),
                    contentPadding: EdgeInsets.zero,
                    value: _controller.showGst,
                    onChanged: (val) => _controller.updateToggles(showGst: val),
                  ),
                  const Divider(),

                  SwitchListTile(
                    title: const Text('Show Full Address', style: AppTextStyles.bodyLarge),
                    contentPadding: EdgeInsets.zero,
                    value: _controller.showAddress,
                    onChanged: (val) => _controller.updateToggles(showAddress: val),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Text Fields
                  TextFormField(
                    controller: _prefixController,
                    decoration: const InputDecoration(
                      labelText: 'Invoice Prefix *',
                      hintText: 'e.g. INV-',
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Prefix is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _footerController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Footer Note',
                      hintText: 'e.g. Thank you for your business!',
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: 'Cancel',
                          variant: PrimaryButtonVariant.outlined,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: PrimaryButton(
                          label: _controller.isSaving ? 'Saving...' : 'Save Settings',
                          isLoading: _controller.isSaving,
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _saveSettings();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
