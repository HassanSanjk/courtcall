// TODO: replace dynamic with Payment model once defined by Hassan.
abstract class PaymentRepository {
  Stream<List<dynamic>> watchPaymentsForSession(String sessionId);
  Future<void> markAsPaid(String paymentId);
  Future<void> markAsUnpaid(String paymentId);
}
