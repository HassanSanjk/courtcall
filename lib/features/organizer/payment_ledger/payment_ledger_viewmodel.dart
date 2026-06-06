import 'package:flutter/foundation.dart';
import '../../../repositories/payment_repository.dart';
import '../../../repositories/mocks/mock_payment_repository.dart';
import '../../../models/payment.dart';

class PaymentLedgerViewModel extends ChangeNotifier {
  final PaymentRepository _repo;
  final String sessionId;

  List<Payment> _payments = [];
  bool loading = true;

  static const double courtCost = 120.0;

  PaymentLedgerViewModel({
    PaymentRepository? repo,
    this.sessionId = 'session_1',
  }) : _repo = repo ?? MockPaymentRepository() {
    _repo.watchPaymentsForSession(sessionId).listen((list) {
      _payments = list;
      loading = false;
      notifyListeners();
    });
  }

  List<Payment> get payments => _payments;
  int get playerCount => _payments.length;

  double get totalCollected =>
      _payments.fold(0.0, (sum, p) => p.paid ? sum + p.amount : sum);

  double get totalOwed =>
      _payments.fold(0.0, (sum, p) => sum + p.amount);

  double get outstanding => totalOwed - totalCollected;

  Future<void> markAsPaid(String paymentId) async {
    await _repo.markAsPaid(paymentId);
  }

  Future<void> markAsUnpaid(String paymentId) async {
    await _repo.markAsUnpaid(paymentId);
  }

  void exportSummary() {
    // Placeholder — implement export/share in Firebase phase
  }
}
