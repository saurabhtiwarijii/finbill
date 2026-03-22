/// FinBill — Print Settings Controller.
///
/// Manages the state and saving logic for the invoice print format.
///
/// File location: lib/features/menu/print_settings/print_settings_controller.dart
library;

import 'package:flutter/foundation.dart';
import '../../../../models/print_settings_model.dart';
import '../../../../services/firebase_service.dart';

class PrintSettingsController extends ChangeNotifier {
  PrintSettingsController() {
    _loadSettings();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── Form State ────────────────────────────────────────────────
  bool showLogo = true;
  bool showGst = true;
  bool showAddress = true;
  String invoicePrefix = 'INV-';
  String footerNote = 'Thank you for your business!';

  bool _isLoading = true;
  bool _isSaving = false;
  String? _lastError;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get lastError => _lastError;

  /// Loads existing settings from Firestore.
  Future<void> _loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      final settings = await _firebase.getPrintSettings();
      if (settings != null) {
        showLogo = settings.showLogo;
        showGst = settings.showGst;
        showAddress = settings.showAddress;
        invoicePrefix = settings.invoicePrefix;
        footerNote = settings.footerNote;
      }
    } catch (e) {
      print('PrintSettingsController._loadSettings error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateToggles({bool? showLogo, bool? showGst, bool? showAddress}) {
    if (showLogo != null) this.showLogo = showLogo;
    if (showGst != null) this.showGst = showGst;
    if (showAddress != null) this.showAddress = showAddress;
    notifyListeners();
  }

  void updateFields({String? invoicePrefix, String? footerNote}) {
    if (invoicePrefix != null) this.invoicePrefix = invoicePrefix.trim();
    if (footerNote != null) this.footerNote = footerNote.trim();
    notifyListeners();
  }

  /// Save settings to Firestore.
  Future<bool> saveSettings() async {
    _lastError = null;

    if (invoicePrefix.isEmpty) {
      _lastError = 'Invoice prefix cannot be empty';
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      final settings = PrintSettingsModel(
        showLogo: showLogo,
        showGst: showGst,
        showAddress: showAddress,
        invoicePrefix: invoicePrefix,
        footerNote: footerNote,
      );

      await _firebase.savePrintSettings(settings);
      return true;
    } catch (e) {
      print('PrintSettingsController.saveSettings error: $e');
      _lastError = 'Failed to save print settings.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
