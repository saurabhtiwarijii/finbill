/// FinBill — Business Profile Controller.
///
/// Manages form state and saving logic for the business profile.
///
/// File location: lib/features/menu/business_profile/business_profile_controller.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../models/business_model.dart';
import '../../../../services/firebase_service.dart';

class BusinessProfileController extends ChangeNotifier {
  BusinessProfileController() {
    _loadProfile();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── Form State ────────────────────────────────────────────────
  String name = '';
  String email = '';
  String phone = '';
  String gstNumber = '';
  String address = '';
  String description = '';
  String? logoBase64;

  bool _isLoading = true;
  bool _isSaving = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get lastError => _lastError;

  /// Loads existing profile data if available.
  Future<void> _loadProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      final profile = await _firebase.getBusinessProfile();
      if (profile != null) {
        name = profile.name;
        email = profile.email;
        phone = profile.phone;
        gstNumber = profile.gstNumber;
        address = profile.address;
        description = profile.description;
        logoBase64 = profile.logoBase64;
      }
    } catch (e) {
      print('BusinessProfileController._loadProfile error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update field values from UI.
  void updateField({
    String? name,
    String? email,
    String? phone,
    String? gstNumber,
    String? address,
    String? description,
    String? logoBase64,
  }) {
    if (name != null) this.name = name.trim();
    if (email != null) this.email = email.trim();
    if (phone != null) this.phone = phone.trim();
    if (gstNumber != null) this.gstNumber = gstNumber.trim();
    if (address != null) this.address = address.trim();
    if (description != null) this.description = description.trim();
    if (logoBase64 != null) this.logoBase64 = logoBase64;
    notifyListeners();
  }

  /// Validate inputs.
  String? validate() {
    if (name.isEmpty) return 'Business name is required';
    return null;
  }

  /// Save profile to Firestore.
  Future<bool> saveProfile() async {
    _lastError = null;

    final error = validate();
    if (error != null) {
      _lastError = error;
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final business = BusinessModel(
        id: _firebase.businessId,
        name: name,
        email: email,
        phone: phone,
        gstNumber: gstNumber,
        address: address,
        description: description,
        logoBase64: logoBase64,
      );

      await _firebase.saveBusinessProfile(business);
      return true;
    } catch (e) {
      print('BusinessProfileController.saveProfile error: $e');
      _lastError = 'Failed to save business profile.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  /// Picks an image from the gallery, converts it to base64, and saves it.
  Future<bool> pickLogo() async {
    _lastError = null;

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 300,
        maxHeight: 300,
        imageQuality: 50,
      );

      if (image == null) return false; // User cancelled

      _isLoading = true; // Show loading state while processing
      notifyListeners();
      
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);
      
      logoBase64 = base64String;
      await saveProfile(); // Auto-save the new logo
      return true;
    } catch (e) {
      print('BusinessProfileController.pickLogo error: $e');
      _lastError = 'Failed to process logo.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
