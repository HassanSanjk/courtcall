// features/maps/map_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../repositories/map_repository.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository _repo;

  List<Map<String, dynamic>> _allSessions = [];
  Map<String, dynamic>? _selectedSession;
  String? _selectedSport;
  double _maxPrice = 0;
  bool isLoading = true;

  MapViewModel({required MapRepository repo})
      : _repo = repo {
    _init();
  }

  double get minAvailablePrice {
    if (_allSessions.isEmpty) return 0;
    return _allSessions
        .map((s) => (s['price'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a < b ? a : b);
  }

  double get maxAvailablePrice {
    if (_allSessions.isEmpty) return 100;
    return _allSessions
        .map((s) => (s['price'] as num?)?.toDouble() ?? 0)
        .reduce((a, b) => a > b ? a : b);
  }

  List<Map<String, dynamic>> get sessions {
    var result = _allSessions;

    if (_selectedSport != null) {
      result = result.where((s) =>
        (s['sport'] as String?)?.toLowerCase() == _selectedSport!.toLowerCase()
      ).toList();
    }

    if (_maxPrice > 0) {
      result = result.where((s) =>
        ((s['price'] as num?)?.toDouble() ?? 0) <= _maxPrice
      ).toList();
    }

    return result;
  }

  List<String> get availableSports {
    final sports = _allSessions
        .map((s) => (s['sport'] as String?) ?? '')
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
    sports.sort();
    return sports;
  }

  Map<String, dynamic>? get selectedSession => _selectedSession;
  String? get selectedSport => _selectedSport;
  double get maxPrice => _maxPrice;

  void _init() {
    loadSessions(lat: 3.1390, lng: 101.6869);
  }

  Future<void> loadSessions({required double lat, required double lng}) async {
    isLoading = true;
    notifyListeners();

    final result = await _repo.getNearbySessions(lat: lat, lng: lng);
    _allSessions = result.cast<Map<String, dynamic>>();

    isLoading = false;
    notifyListeners();
  }

  void setSportFilter(String? sport) {
    _selectedSport = _selectedSport == sport ? null : sport;
    notifyListeners();
  }

  void setMaxPrice(double price) {
    _maxPrice = price;
    notifyListeners();
  }

  void clearFilters() {
    _selectedSport = null;
    _maxPrice = 0;
    notifyListeners();
  }

  void selectSession(Map<String, dynamic> session) {
    _selectedSession = session;
    notifyListeners();
  }

  void clearSelection() {
    _selectedSession = null;
    notifyListeners();
  }
}