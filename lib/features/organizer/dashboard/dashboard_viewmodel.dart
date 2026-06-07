import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../../repositories/session_repository.dart';
import '../../../repositories/payment_repository.dart';
import '../../../models/models.dart';

class DashboardViewModel extends ChangeNotifier {
  final SessionRepository _sessionRepo;
  final PaymentRepository _paymentRepo;
  final String organizerId;

  List<Session> _sessions = [];
  bool _loading = true;
  final Map<String, List<Payment>> _paymentsBySession = {};

  StreamSubscription<List<Session>>? _sessionSub;
  final List<StreamSubscription<List<Payment>>> _paymentSubs = [];

  DashboardViewModel({
    required SessionRepository sessionRepo,
    required PaymentRepository paymentRepo,
    required this.organizerId,
  })  : _sessionRepo = sessionRepo,
        _paymentRepo = paymentRepo {
    _init();
  }

  List<Session> get sessions => _sessions;
  bool get loading => _loading;

  int get totalSessions => _sessions.length;
  int get totalPlayers => _sessions.fold(0, (sum, s) => sum + s.maxPlayers);

  int get unpaidCount =>
      _paymentsBySession.values
          .expand((p) => p)
          .where((p) => p.status != 'paid')
          .length;

  void _init() {
    _sessionSub = _sessionRepo.watchUpcomingSessions(organizerId).listen((list) {
      _sessions = list;
      _loading = false;
      _updatePaymentListeners(list);
      notifyListeners();
    });
  }

  void _updatePaymentListeners(List<Session> sessions) {
    for (final sub in _paymentSubs) {
      sub.cancel();
    }
    _paymentSubs.clear();
    _paymentsBySession.clear();

    for (final session in sessions) {
      final sub = _paymentRepo
          .watchPaymentsForSession(session.sessionId)
          .listen((payments) {
        _paymentsBySession[session.sessionId] = payments;
        notifyListeners();
      });
      _paymentSubs.add(sub);
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    for (final sub in _paymentSubs) {
      sub.cancel();
    }
    super.dispose();
  }
}
