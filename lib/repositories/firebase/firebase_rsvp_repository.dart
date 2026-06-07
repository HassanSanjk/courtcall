import 'package:cloud_firestore/cloud_firestore.dart';
import '../rsvp_repository.dart';
import '../../models/models.dart';

class FirebaseRsvpRepository implements RsvpRepository {
  final FirebaseFirestore _db;

  FirebaseRsvpRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Rsvp>> watchRsvpsForSession(String sessionId) {
    return _db
        .collection('rsvps')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => Rsvp.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> updateRsvpStatus(
    String rsvpId,
    String status, {
    String? declineReason,
  }) async {
    await _db.collection('rsvps').doc(rsvpId).update({
      'status': status,
      if (declineReason != null) 'declineReason': declineReason,
    });
  }
}
