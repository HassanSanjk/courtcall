import 'package:flutter/foundation.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/mocks/mock_session_repository.dart';

class CancellationViewModel extends ChangeNotifier {
  final SessionRepository _repo;

  String selectedReason = 'Court unavailable';
  bool notifyPlayers = true;
  bool isCancelling = false;
  String? errorMessage;

  CancellationViewModel({SessionRepository? repo})
      : _repo = repo ?? MockSessionRepository();

  static const List<String> reasons = [
    'Court unavailable',
    'Not enough players',
    'Weather conditions',
    'Other',
  ];

  void setReason(String reason) {
    selectedReason = reason;
    notifyListeners();
  }

  void setNotify(bool value) {
    notifyPlayers = value;
    notifyListeners();
  }

  String get previewMessage =>
      'CourtCall: Friday Futsal at Nexus has been cancelled by Azri. '
      'Reason: ${selectedReason.toLowerCase()}. Your slot has been released.';

  Future<void> confirmCancellation(String sessionId) async {
    isCancelling = true;
    errorMessage = null;
    notifyListeners();
    try {
      await _repo.cancelSession(sessionId);
    } catch (e) {
      errorMessage = 'Failed to cancel session. Please try again.';
    } finally {
      isCancelling = false;
      notifyListeners();
    }
  }
}
