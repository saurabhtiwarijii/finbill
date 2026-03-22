import 'package:flutter/foundation.dart';

/// FinBill — App State Service.
///
/// Global truth store for application-wide state that controls overall
/// access (like whether the user has completed their mandatory profile).
class AppStateService extends ChangeNotifier {
  AppStateService._();
  static final AppStateService instance = AppStateService._();

  bool _isProfileComplete = false;

  bool get isProfileComplete => _isProfileComplete;

  void setProfileComplete(bool value) {
    if (_isProfileComplete == value) return;
    _isProfileComplete = value;
    notifyListeners();
  }
}
