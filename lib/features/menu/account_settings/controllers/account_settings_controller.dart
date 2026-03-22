import 'package:flutter/material.dart';
import '../../../../services/firebase_service.dart';
import '../../../../services/app_state_service.dart';

class AccountSettingsController extends ChangeNotifier {
  AccountSettingsController() {
    loadSettings();
  }

  bool isLoading = true;
  bool isSaving = false;

  final ownerNameController = TextEditingController();
  final mobileController = TextEditingController();
  final emailController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  Future<void> loadSettings() async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await FirebaseService.instance.getAccountSettings();
      if (data != null) {
        ownerNameController.text = data['ownerName'] as String? ?? '';
        mobileController.text = data['mobile'] as String? ?? '';
        emailController.text = data['email'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('Error loading account settings: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> saveSettings() async {
    if (!formKey.currentState!.validate()) {
      return false; // Validation failed
    }

    isSaving = true;
    notifyListeners();

    try {
      final data = {
        'ownerName': ownerNameController.text.trim(),
        'mobile': mobileController.text.trim(),
        'email': emailController.text.trim(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await FirebaseService.instance.saveAccountSettings(data);
      AppStateService.instance.setProfileComplete(true);

      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error saving account settings: $e');
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  // ── Validators ──────────────────────────────────────────────────

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Owner Name is required';
    }
    return null;
  }

  String? validateMobile(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile Number is required';
    }
    final digitsPattern = RegExp(r'^\d{10}$');
    if (!digitsPattern.hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailPattern = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailPattern.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  void dispose() {
    ownerNameController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
