import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../player_repository.dart';
import '../../models/models.dart';

class FirebasePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _db;

  FirebasePlayerRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Session>> watchPlayerSessions(String playerId) {
    return _db
        .collection('rsvps')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .asyncMap((snapshot) async {
      final sessionIds =
          snapshot.docs.map((doc) => doc.data()['sessionId'] as String).toSet();

      if (sessionIds.isEmpty) return [];

      final sessionDocs = await Future.wait(
        sessionIds.map((id) => _db.collection('sessions').doc(id).get()),
      );

      return sessionDocs
          .where((doc) => doc.exists)
          .map((doc) => Session.fromMap(doc.id, doc.data()!))
          .toList();
    });
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return Session.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<Rsvp?> getPlayerRsvp({
    required String sessionId,
    required String playerId,
  }) async {
    final snapshot = await _db
        .collection('rsvps')
        .where('sessionId', isEqualTo: sessionId)
        .where('playerId', isEqualTo: playerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Rsvp.fromMap(doc.id, doc.data());
  }

  @override
  Future<void> upsertRsvp({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String status,
    String? declineReason,
  }) async {
    final existing = await getPlayerRsvp(sessionId: sessionId, playerId: playerId);
    final oldStatus = existing?.status;

    final rsvpId = 'rsvp_${sessionId}_$playerId';
    final batch = _db.batch();

    batch.set(_db.collection('rsvps').doc(rsvpId), {
      'rsvpId': rsvpId,
      'sessionId': sessionId,
      'playerId': playerId,
      'playerName': playerName,
      'status': status,
      if (declineReason != null) 'declineReason': declineReason,
    }, SetOptions(merge: true));

    final sessionRef = _db.collection('sessions').doc(sessionId);
    if (status == 'confirmed' && oldStatus != 'confirmed') {
      batch.update(sessionRef, {'rsvpCount': FieldValue.increment(1)});
    } else if (status != 'confirmed' && oldStatus == 'confirmed') {
      batch.update(sessionRef, {'rsvpCount': FieldValue.increment(-1)});
    }

    await batch.commit();
  }

  @override
  Stream<List<Rsvp>> watchSessionRsvps(String sessionId) {
    return _db
        .collection('rsvps')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'confirmed')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Rsvp.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<List<String>> getConfirmedPlayerNames(String sessionId) async {
    final snapshot = await _db
        .collection('rsvps')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['playerName'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  Future<void> joinWaitlist({
    required String sessionId,
    required String playerId,
    required String playerName,
  }) async {
    final existing = await _db
        .collection('waitlist')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('position', descending: true)
        .limit(1)
        .get();

    final nextPosition =
        existing.docs.isEmpty ? 1 : (existing.docs.first.data()['position'] as int) + 1;

    final docRef = _db.collection('waitlist').doc();
    await docRef.set({
      'waitlistId': docRef.id,
      'sessionId': sessionId,
      'playerId': playerId,
      'playerName': playerName,
      'position': nextPosition,
      'status': 'waiting',
      'joinedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<Payment>> watchPlayerPayments(String playerId) {
    return _db
        .collection('payments')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Payment.fromMap(doc.id, doc.data()))
            .toList());
  }

  @override
  Future<void> markPaid({
    required String paymentId,
    required String transactionRef,
  }) async {
    await _db.collection('payments').doc(paymentId).update({
      'status': 'paid',
      'transactionRef': transactionRef,
      'paidAt': FieldValue.serverTimestamp(),
    });
  }
}
