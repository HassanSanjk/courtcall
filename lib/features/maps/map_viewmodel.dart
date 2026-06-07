import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../repositories/map_repository.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository _repo;

  List<Map<String, dynamic>> _allSessions = [];
  Map<String, dynamic>? _selectedSession;
  String? _selectedSport;
  double _maxPrice = 0;
  bool isLoading = true;
  bool isLocating = false;
  String? locationError;

  MapViewModel({required MapRepository repo}) : _repo = repo {
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
      result = result
          .where((s) =>
              (s['sport'] as String?)?.toLowerCase() ==
              _selectedSport!.toLowerCase())
          .toList();
    }

    if (_maxPrice > 0) {
      result = result
          .where((s) => ((s['price'] as num?)?.toDouble() ?? 0) <= _maxPrice)
          .toList();
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

  /// Requests location permission, gets the device position, reloads sessions
  /// around that position, and returns the [Position] so the screen can move
  /// the camera. Returns null if permission is denied or location is off.
  Future<Position?> goToMyLocation() async {
    locationError = null;
    isLocating = true;
    notifyListeners();

    try {
      // Check if location services are enabled at OS level.
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        locationError = 'Location services are turned off on your device.';
        return null;
      }

      // Check / request permission.
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          locationError = 'Location permission was denied.';
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        locationError =
            'Location permission is permanently denied. Enable it in Settings.';
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reload map pins centred on the real location.
      await loadSessions(lat: position.latitude, lng: position.longitude);
      return position;
    } catch (_) {
      locationError = 'Could not determine your location. Try again.';
      return null;
    } finally {
      isLocating = false;
      notifyListeners();
    }
  }

  void clearLocationError() {
    locationError = null;
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
