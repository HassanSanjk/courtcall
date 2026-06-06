import 'dart:async';
import '../payment_repository.dart';
import '../../models/payment.dart';

class MockPaymentRepository implements PaymentRepository {
  final List<Payment> _payments = [
    const Payment(id: 'pay_1', playerId: 'p1', playerName: 'Azri',   initials: 'AZ', sessionId: 'session_1', amount: 15.0, paid: true),
    const Payment(id: 'pay_2', playerId: 'p2', playerName: 'Hafiz',  initials: 'HF', sessionId: 'session_1', amount: 15.0, paid: false),
    const Payment(id: 'pay_3', playerId: 'p3', playerName: 'Syafiq', initials: 'SY', sessionId: 'session_1', amount: 15.0, paid: true),
    const Payment(id: 'pay_4', playerId: 'p4', playerName: 'Danial', initials: 'DN', sessionId: 'session_1', amount: 15.0, paid: false),
    const Payment(id: 'pay_5', playerId: 'p5', playerName: 'Faris',  initials: 'FR', sessionId: 'session_1', amount: 15.0, paid: true),
    const Payment(id: 'pay_6', playerId: 'p6', playerName: 'Imran',  initials: 'IM', sessionId: 'session_1', amount: 15.0, paid: true),
    const Payment(id: 'pay_7', playerId: 'p7', playerName: 'Kamal',  initials: 'KM', sessionId: 'session_1', amount: 15.0, paid: true),
    const Payment(id: 'pay_8', playerId: 'p8', playerName: 'Zikri',  initials: 'ZK', sessionId: 'session_1', amount: 15.0, paid: false),
  ];

  final _ctrl = StreamController<List<Payment>>.broadcast();

  @override
  Stream<List<Payment>> watchPaymentsForSession(String sessionId) async* {
    yield _payments.where((p) => p.sessionId == sessionId).toList();
    yield* _ctrl.stream
        .map((all) => all.where((p) => p.sessionId == sessionId).toList());
  }

  @override
  Future<void> markAsPaid(String paymentId) async {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(paid: true);
      _ctrl.add(List.from(_payments));
    }
  }

  @override
  Future<void> markAsUnpaid(String paymentId) async {
    final idx = _payments.indexWhere((p) => p.id == paymentId);
    if (idx != -1) {
      _payments[idx] = _payments[idx].copyWith(paid: false);
      _ctrl.add(List.from(_payments));
    }
  }
}
