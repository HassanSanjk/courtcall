import '../payment_repository.dart';

class MockPaymentRepository implements PaymentRepository {
  static final List<Map<String, dynamic>> _payments = [
    {
      'id': 'payment_1',
      'sessionId': 'session_1',
      'playerId': 'player_1',
      'playerName': 'Alice Johnson',
      'amount': 25.00,
      'status': 'paid',
    },
    {
      'id': 'payment_2',
      'sessionId': 'session_1',
      'playerId': 'player_2',
      'playerName': 'Bob Smith',
      'amount': 25.00,
      'status': 'unpaid',
    },
    {
      'id': 'payment_3',
      'sessionId': 'session_1',
      'playerId': 'player_3',
      'playerName': 'Charlie Davis',
      'amount': 25.00,
      'status': 'paid',
    },
  ];

  @override
  Stream<List<dynamic>> watchPaymentsForSession(String sessionId) =>
      Stream.value(_payments.where((p) => p['sessionId'] == sessionId).toList());

  @override
  Future<void> markAsPaid(String paymentId) => Future.value();

  @override
  Future<void> markAsUnpaid(String paymentId) => Future.value();
}
