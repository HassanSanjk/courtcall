// features/maps/map_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../repositories/map_repository.dart';
import '../../repositories/mocks/mock_map_repository.dart';

class MapViewModel extends ChangeNotifier {
  final MapRepository _repo;

  List<Map<String, dynamic>> _sessions = [];
  Map<String, dynamic>? _selectedSession;
  bool isLoading = true;

  MapViewModel({MapRepository? repo})
      : _repo = repo ?? MockMapRepository() {
    _init();
  }

  List<Map<String, dynamic>> get sessions => _sessions;
  Map<String, dynamic>? get selectedSession => _selectedSession;

  void _init() {
    loadSessions(lat: 3.1390, lng: 101.6869);
  }

  Future<void> loadSessions({required double lat, required double lng}) async {
    isLoading = true;
    notifyListeners();

    final result = await _repo.getNearbySessions(lat: lat, lng: lng);
    _sessions = result.cast<Map<String, dynamic>>();

    isLoading = false;
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