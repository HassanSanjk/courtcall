import 'package:cloud_firestore/cloud_firestore.dart';
import '../payment_repository.dart';
import '../../models/models.dart';

class FirebasePaymentRepository implements PaymentRepository {
  final FirebaseFirestore _db;

  FirebasePaymentRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Payment>> watchPaymentsForSession(String sessionId) {
    return _db
        .collection('payments')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Payment.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> markAsPaid(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'paid',
      'transactionRef': 'MANUAL',
      'paidAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAsUnpaid(String paymentId) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'unpaid',
      'transactionRef': null,
      'paidAt': null,
    });
  }
}
