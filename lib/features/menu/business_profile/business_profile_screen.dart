/// FinBill — Business Profile Screen.
///
/// UI form for creating or updating the business profile.
///
/// File location: lib/features/menu/business_profile/business_profile_screen.dart
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../widgets/primary_button.dart';
import 'business_profile_controller.dart';

class BusinessProfileScreen extends StatefulWidget {
  const BusinessProfileScreen({super.key});

  @override
  State<BusinessProfileScreen> createState() => _BusinessProfileScreenState();
}

class _BusinessProfileScreenState extends State<BusinessProfileScreen> {
  final _controller = BusinessProfileController();
  final _formKey = GlobalKey<FormState>();

  // Controllers for initial values once loaded
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstController = TextEditingController();
  final _addressController = TextEditingController();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChange);
  }

  void _onControllerChange() {
    if (_controller.isLoading) return;

    // Populate controllers once data is loaded (only once setup is not really needed if we do it here, but we check if empty)
    if (_nameController.text.isEmpty && _controller.name.isNotEmpty) {
      _nameController.text = _controller.name;
      _emailController.text = _controller.email;
      _phoneController.text = _controller.phone;
      _gstController.text = _controller.gstNumber;
      _addressController.text = _controller.address;
      _descController.text = _controller.description;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChange);
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _gstController.dispose();
    _addressController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    // Force field updates before saving just in case
    _controller.updateField(
      name: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      gstNumber: _gstController.text,
      address: _addressController.text,
      description: _descController.text,
    );

    final success = await _controller.saveProfile();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Business Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final msg = _controller.lastError ?? 'Failed to save profile';
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
        title: const Text('Business Profile'),
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
                  // Header
                  const Text(
                    'Business Details',
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppSizes.md),
                  const Text(
                    'Update your core business information. This will appear on invoices.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSizes.xl),
                  
                  // Logo Upload
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppColors.surface,
                          backgroundImage: _controller.logoBase64 != null
                              ? MemoryImage(base64Decode(_controller.logoBase64!))
                              : null,
                          child: _controller.logoBase64 == null
                              ? const Icon(Icons.business, size: 40, color: AppColors.textSecondary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: () async {
                              final success = await _controller.pickLogo();
                              if (!mounted) return;
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Logo uploaded successfully!'), backgroundColor: Colors.green),
                                );
                              } else if (_controller.lastError != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(_controller.lastError!), backgroundColor: Colors.red),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(AppSizes.sm),
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSizes.xl),

                  // Fields
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Business Name *',
                      hintText: 'e.g. Acme Corp',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g. 9876543210',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'e.g. contact@acme.com',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _gstController,
                    decoration: const InputDecoration(
                      labelText: 'GST Number',
                      hintText: 'e.g. 29ABCDE1234F1Z5',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _addressController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      hintText: 'Full business address...',
                    ),
                  ),
                  const SizedBox(height: AppSizes.md),

                  TextFormField(
                    controller: _descController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Short description of your business...',
                    ),
                  ),
                  const SizedBox(height: AppSizes.xxl),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          label: AppStrings.cancel,
                          variant: PrimaryButtonVariant.outlined,
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: AppSizes.md),
                      Expanded(
                        child: PrimaryButton(
                          label: _controller.isSaving ? 'Saving...' : AppStrings.save,
                          isLoading: _controller.isSaving,
                          onPressed: _controller.isSaving ? null : _saveProfile,
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
