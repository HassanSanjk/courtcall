import 'package:flutter/foundation.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/mocks/mock_session_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final SessionRepository _repo;

  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;

  DashboardViewModel({SessionRepository? repo})
      : _repo = repo ?? MockSessionRepository() {
    _init();
  }

  List<Map<String, dynamic>> get sessions => _sessions;
  bool get loading => _loading;

  int get totalSessions => _sessions.length;
  int get totalPlayers => _sessions.fold(
      0, (sum, s) => sum + ((s['maxPlayers'] as int?) ?? 0));

  void _init() {
    _repo.watchUpcomingSessions('org_1').listen((list) {
      _sessions = list.cast<Map<String, dynamic>>();
      _loading = false;
      notifyListeners();
    });
  }
}
