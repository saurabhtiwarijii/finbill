import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/account_settings_controller.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late final AccountSettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AccountSettingsController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    final success = await _controller.saveSettings();
    
    if (!mounted) return;
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account settings saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (!_controller.formKey.currentState!.validate()) {
      // Error is handled by form field validation UI
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save settings. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Account Settings'),
        centerTitle: false,
      ),
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return SafeArea(
            child: Form(
              key: _controller.formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Owner Profile',
                            style: AppTextStyles.h3,
                          ),
                          const SizedBox(height: AppSizes.xs),
                          const Text(
                            'Manage your personal details and contact information.',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: AppSizes.xl),

                          // Owner Name
                          const Text('Owner Name', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: AppSizes.xs),
                          TextFormField(
                            controller: _controller.ownerNameController,
                            validator: _controller.validateName,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Enter owner name',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Mobile Number
                          const Text('Mobile Number', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: AppSizes.xs),
                          TextFormField(
                            controller: _controller.mobileController,
                            validator: _controller.validateMobile,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            decoration: const InputDecoration(
                              hintText: '10-digit mobile number',
                              prefixIcon: Icon(Icons.phone_outlined),
                              counterText: '',
                            ),
                          ),
                          const SizedBox(height: AppSizes.lg),

                          // Email
                          const Text('Email Address', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: AppSizes.xs),
                          TextFormField(
                            controller: _controller.emailController,
                            validator: _controller.validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              hintText: 'Enter email address',
                              prefixIcon: Icon(Icons.email_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Save Button
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: Border(
                        top: BorderSide(color: AppColors.cardBorder),
                      ),
                    ),
                    child: ElevatedButton(
                      onPressed: _controller.isSaving ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: AppSizes.md),
                      ),
                      child: _controller.isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Save Changes',
                              style: AppTextStyles.bodyLarge,
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
