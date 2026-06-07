import 'dart:async';
import 'package:courtcall/repositories/payment_repository.dart';
import 'package:courtcall/models/models.dart';

class MockPaymentRepository implements PaymentRepository {
  final List<Payment> _payments = [
    Payment(paymentId: 'pay_1', playerId: 'p1', playerName: 'Azri',   sessionId: 'session_1', amount: 15.0, status: 'paid'),
    Payment(paymentId: 'pay_2', playerId: 'p2', playerName: 'Hafiz',  sessionId: 'session_1', amount: 15.0, status: 'unpaid'),
    Payment(paymentId: 'pay_3', playerId: 'p3', playerName: 'Syafiq', sessionId: 'session_1', amount: 15.0, status: 'paid'),
    Payment(paymentId: 'pay_4', playerId: 'p4', playerName: 'Danial', sessionId: 'session_1', amount: 15.0, status: 'unpaid'),
    Payment(paymentId: 'pay_5', playerId: 'p5', playerName: 'Faris',  sessionId: 'session_1', amount: 15.0, status: 'paid'),
    Payment(paymentId: 'pay_6', playerId: 'p6', playerName: 'Imran',  sessionId: 'session_1', amount: 15.0, status: 'paid'),
    Payment(paymentId: 'pay_7', playerId: 'p7', playerName: 'Kamal',  sessionId: 'session_1', amount: 15.0, status: 'paid'),
    Payment(paymentId: 'pay_8', playerId: 'p8', playerName: 'Zikri',  sessionId: 'session_1', amount: 15.0, status: 'unpaid'),
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
    final idx = _payments.indexWhere((p) => p.paymentId == paymentId);
    if (idx != -1) {
      _payments[idx] = Payment(
        paymentId: _payments[idx].paymentId,
        playerId: _payments[idx].playerId,
        playerName: _payments[idx].playerName,
        sessionId: _payments[idx].sessionId,
        amount: _payments[idx].amount,
        status: 'paid',
      );
      _ctrl.add(List.from(_payments));
    }
  }

  @override
  Future<void> markAsUnpaid(String paymentId) async {
    final idx = _payments.indexWhere((p) => p.paymentId == paymentId);
    if (idx != -1) {
      _payments[idx] = Payment(
        paymentId: _payments[idx].paymentId,
        playerId: _payments[idx].playerId,
        playerName: _payments[idx].playerName,
        sessionId: _payments[idx].sessionId,
        amount: _payments[idx].amount,
        status: 'unpaid',
      );
      _ctrl.add(List.from(_payments));
    }
  }

  void dispose() => _ctrl.close();
}
