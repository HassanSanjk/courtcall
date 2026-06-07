import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../session_repository.dart';
import '../../models/models.dart';

class FirebaseSessionRepository implements SessionRepository {
  final FirebaseFirestore _db;

  FirebaseSessionRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Session>> watchUpcomingSessions(String organizerId) {
    return _db
        .collection('sessions')
        .where('organizerId', isEqualTo: organizerId)
        .snapshots()
        .map((snap) {
          final sessions = snap.docs
              .map((doc) => Session.fromMap(doc.id, doc.data()))
              .where((s) => s.status == 'upcoming')
              .toList();
          sessions.sort((a, b) => a.dateTimestamp.compareTo(b.dateTimestamp));
          return sessions;
        });
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return Session.fromMap(doc.id, doc.data()!);
  }

  @override
  Future<String> createSession(Map<String, dynamic> data) async {
    final ref = _db.collection('sessions').doc();
    final id = ref.id;
    final dateTimestamp = data['dateTimestamp'];
    await ref.set({
      'sessionId': id,
      'sport': data['sport'] ?? 'futsal',
      'organizerId': data['organizerId'] ?? '',
      'venueId': data['venueId'] ?? '',
      'venueName': data['venueName'] ?? '',
      'court': data['court'] ?? '',
      'date': data['date'] ?? '',
      'dateTimestamp': dateTimestamp is DateTime
          ? Timestamp.fromDate(dateTimestamp)
          : FieldValue.serverTimestamp(),
      'time': data['time'] ?? '',
      'maxPlayers': data['maxPlayers'] ?? 0,
      'rsvpCount': 0,
      'costPerPlayer': (data['costPerPlayer'] as num?)?.toDouble() ?? 0.0,
      'status': 'upcoming',
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException(
        'Session creation timed out — check Firestore security rules.',
      ),
    );
    return id;
  }

  @override
  Future<void> updateSession(String sessionId, Map<String, dynamic> data) async {
    await _db.collection('sessions').doc(sessionId).update(data);
  }

  @override
  Future<void> cancelSession(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'status': 'cancelled',
    });
  }

  @override
  Future<void> incrementRsvpCount(String sessionId) async {
    await _db.collection('sessions').doc(sessionId).update({
      'rsvpCount': FieldValue.increment(1),
    });
  }
}
