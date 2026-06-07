import 'package:flutter/foundation.dart';
import '../../../repositories/session_repository.dart';
import '../../../models/models.dart';

class CancellationViewModel extends ChangeNotifier {
  final SessionRepository _repo;
  final String sessionId;
  final Session session;

  String selectedReason = 'Court unavailable';
  bool notifyPlayers = true;
  bool isCancelling = false;
  String? errorMessage;

  CancellationViewModel({
    required SessionRepository sessionRepo,
    required this.sessionId,
    required this.session,
  }) : _repo = sessionRepo;

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
      'CourtCall: ${session.sport} at ${session.venueName} has been cancelled. '
      'Reason: ${selectedReason.toLowerCase()}. Your slot has been released.';

  Future<void> confirmCancellation() async {
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
