/// FinBill — Parties controller.
///
/// Manages the parties list state backed by Firestore via [FirebaseService].
/// Subscribes to a real-time stream of parties, with local search filtering.
///
/// File location: lib/features/parties/controllers/parties_controller.dart
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../models/party_model.dart';
import '../../../services/firebase_service.dart';

class PartiesController extends ChangeNotifier {
  PartiesController() {
    _subscribe();
  }

  final FirebaseService _firebase = FirebaseService.instance;

  // ── State ─────────────────────────────────────────────────────
  List<PartyModel> _parties = [];
  List<PartyModel> _filteredParties = [];
  String _searchQuery = '';
  bool _isLoading = true;
  StreamSubscription<List<PartyModel>>? _subscription;

  List<PartyModel> get parties =>
      _searchQuery.isEmpty ? _parties : _filteredParties;
  bool get isLoading => _isLoading;
  bool get isEmpty => parties.isEmpty;

  // ── Tab Filtering ─────────────────────────────────────────────
  
  List<PartyModel> getCustomers() =>
      parties.where((p) => p.type == PartyType.customer).toList();

  List<PartyModel> getVendors() =>
      parties.where((p) => p.type == PartyType.supplier).toList();

  /// Total receivable (sum of positive balances).
  double get totalReceivable =>
      _parties.where((p) => p.balance > 0).fold(0, (s, p) => s + p.balance);

  /// Total payable (sum of absolute negative balances).
  double get totalPayable => _parties
      .where((p) => p.balance < 0)
      .fold(0, (s, p) => s + p.balance.abs());

  // ── Real-time stream ──────────────────────────────────────────

  void _subscribe() {
    _subscription = _firebase.getPartiesStream().listen(
      (parties) {
        _parties = parties;
        _applySearch();
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Parties stream error: $e');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  /// Manual reload.
  Future<void> loadParties() async {
    _isLoading = true;
    notifyListeners();

    try {
      _parties = await _firebase.getParties();
      _applySearch();
    } catch (e) {
      debugPrint('Parties load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────

  Future<void> addParty(PartyModel party) async {
    await _firebase.addParty(party);
  }

  Future<void> deleteParty(String partyId) async {
    await _firebase.deleteParty(partyId);
  }

  // ── Search ────────────────────────────────────────────────────

  void search(String query) {
    _searchQuery = query.trim().toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    if (_searchQuery.isEmpty) {
      _filteredParties = _parties;
    } else {
      _filteredParties = _parties.where((party) {
        return party.name.toLowerCase().contains(_searchQuery) ||
            party.mobile.toLowerCase().contains(_searchQuery);
      }).toList();
    }
  }

  /// Lookup by ID.
  PartyModel? getById(String id) {
    try {
      return _parties.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
