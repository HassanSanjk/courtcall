// features/venue/availability/availability_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/availability_repository.dart';
import '../../../repositories/mocks/mock_availability_repository.dart';

class AvailabilityViewModel extends ChangeNotifier {
  final AvailabilityRepository _repo;
  final String _venueId;

  List<Map<String, dynamic>> _slots = [];
  bool isLoading = true;
  bool isSaving = false;
  bool hasChanges = false;
  int selectedCourtIndex = 0;
  String _weekStart = _todayWeekStart();

  final List<String> courts = ['Court 1', 'Court 2', 'Court 3', 'VIP Court'];

  AvailabilityViewModel({AvailabilityRepository? repo, required String venueId})
      : _repo = repo ?? MockAvailabilityRepository(),
        _venueId = venueId {
    _init();
  }

  static String _todayWeekStart() {
    final now = DateTime.now();
    final daysFromMonday = now.weekday - DateTime.monday;
    final monday = now.subtract(Duration(days: daysFromMonday));
    return monday.toIso8601String().substring(0, 10);
  }

  List<Map<String, dynamic>> get slots => _slots;

  // Group slots by date for the UI
  List<Map<String, dynamic>> get groupedDays {
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final slot in _slots) {
      if (slot['courtIndex'] != selectedCourtIndex) continue;
      final date = slot['date'] as String;
      grouped.putIfAbsent(date, () => {
        'date': date,
        'dateLabel': slot['dateLabel'],
        'isToday': slot['isToday'],
        'slots': <Map<String, dynamic>>[],
      });
      (grouped[date]!['slots'] as List).add(slot);
    }
    return grouped.values.toList();
  }

  String get weekRangeLabel => _weekStart; // formatted by UI if needed

  void _init() {
    _repo.watchSlots(_venueId, _weekStart).listen((list) {
      _slots = list.cast<Map<String, dynamic>>();
      isLoading = false;
      notifyListeners();
    });
  }

  void selectCourt(int index) {
    selectedCourtIndex = index;
    hasChanges = false;
    notifyListeners();
  }

  void previousWeek() {
    final date = DateTime.parse(_weekStart).subtract(const Duration(days: 7));
    _weekStart = date.toIso8601String().substring(0, 10);
    _init();
  }

  void nextWeek() {
    final date = DateTime.parse(_weekStart).add(const Duration(days: 7));
    _weekStart = date.toIso8601String().substring(0, 10);
    _init();
  }

  void toggleSlot(String slotId, bool value) {
    _slots = _slots.map((s) {
      if (s['id'] == slotId &&
          (s['status'] == 'available' || s['status'] == 'open')) {
        return {
          ...s,
          'isEnabled': value,
          'status': value ? 'available' : 'open',
        };
      }
      return s;
    }).toList();
    hasChanges = true;
    notifyListeners();
  }

  Future<void> saveChanges() async {
    isSaving = true;
    notifyListeners();

    await _repo.saveSlots(_venueId, _slots);

    isSaving = false;
    hasChanges = false;
    notifyListeners();
  }
}