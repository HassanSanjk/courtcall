import '../models/payment.dart';

abstract class PaymentRepository {
  Stream<List<Payment>> watchPaymentsForSession(String sessionId);
  Future<void> markAsPaid(String paymentId);
  Future<void> markAsUnpaid(String paymentId);
}
