import 'package:flutter/material.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/mocks/mock_session_repository.dart';

class CreateSessionViewModel extends ChangeNotifier {
  final SessionRepository _repo;

  String selectedSport = 'Futsal';
  int maxPlayers = 12;
  DateTime? selectedDate;
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  bool isSaving = false;
  String? errorMessage;

  CreateSessionViewModel({SessionRepository? repo})
      : _repo = repo ?? MockSessionRepository();

  void setSport(String sport) {
    selectedSport = sport;
    notifyListeners();
  }

  void setMaxPlayers(int value) {
    maxPlayers = value;
    notifyListeners();
  }

  void setDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void setStartTime(TimeOfDay time) {
    startTime = time;
    notifyListeners();
  }

  void setEndTime(TimeOfDay time) {
    endTime = time;
    notifyListeners();
  }

  Future<bool> createSession({
    required String venue,
    required String cost,
    required String notes,
  }) async {
    if (venue.trim().isEmpty || selectedDate == null || startTime == null || endTime == null) {
      errorMessage = 'Please fill in Venue, Date, Start Time, and End Time.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _repo.createSession({
        'sport': selectedSport,
        'venueName': venue.trim(),
        'courtName': '',
        'date': _formatDate(selectedDate!),
        'startTime': _formatTime(startTime!),
        'endTime': _formatTime(endTime!),
        'maxPlayers': maxPlayers,
        'confirmedCount': 0,
        'costPerPlayer': double.tryParse(cost.trim()) ?? 0.0,
        'courtCost': 0.0,
        'status': 'upcoming',
        'organizerId': 'org_1',
      });
      return true;
    } catch (e) {
      errorMessage = 'Failed to create session. Please try again.';
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatTime(TimeOfDay t) {
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final m = t.minute.toString().padLeft(2, '0');
    final period = t.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}
