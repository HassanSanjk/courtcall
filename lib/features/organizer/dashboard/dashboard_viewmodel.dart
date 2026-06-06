import 'package:flutter/foundation.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/mocks/mock_session_repository.dart';
import '../../../models/session.dart';

class DashboardViewModel extends ChangeNotifier {
  final SessionRepository _repo;

  List<Session> _sessions = [];
  bool _loading = true;

  DashboardViewModel({SessionRepository? repo})
      : _repo = repo ?? MockSessionRepository() {
    _init();
  }

  List<Session> get sessions => _sessions;
  bool get loading => _loading;

  int get totalSessions => _sessions.length;
  int get totalPlayers => _sessions.fold(0, (sum, s) => sum + s.maxPlayers);

  // TODO: wire to PaymentRepository in Firebase phase
  int get unpaidCount => 0;

  void _init() {
    _repo.watchUpcomingSessions('org_1').listen((list) {
      _sessions = list;
      _loading = false;
      notifyListeners();
    });
  }
}
