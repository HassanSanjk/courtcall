import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../player_repository.dart';
import '../../models/models.dart';

class FirebasePlayerRepository implements PlayerRepository {
  final FirebaseFirestore _db;

  FirebasePlayerRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Sessions ──────────────────────────────────────────────────────────────

  @override
  Stream<List<Session>> watchPlayerSessions(String playerId) {
    final controller = StreamController<List<Session>>.broadcast();

    List<Session> discovered = [];
    List<Session> rsvpLinked = [];

    void emit() {
      final merged = <String, Session>{};
      for (final s in discovered) {
        merged[s.sessionId] = s;
      }
      for (final s in rsvpLinked) {
        merged[s.sessionId] = s;
      }
      controller.add(merged.values.toList());
    }

    // All upcoming sessions visible to any player (open discovery)
    final upcomingSub = _db
        .collection('sessions')
        .where('status', isEqualTo: 'upcoming')
        .orderBy('dateTimestamp')
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => Session.fromMap(doc.id, doc.data())).toList())
        .listen((sessions) {
      discovered = sessions;
      emit();
    });

    // Sessions the player already has an RSVP for — filtered to upcoming only
    // so cancelled sessions stop appearing after the organizer cancels.
    final rsvpSub = _db
        .collection('rsvps')
        .where('playerId', isEqualTo: playerId)
        .snapshots()
        .asyncMap<List<Session>>((snapshot) async {
      final sessionIds =
          snapshot.docs.map((doc) => doc.data()['sessionId'] as String).toSet();
      if (sessionIds.isEmpty) return [];

      final sessionDocs = await Future.wait(
        sessionIds.map((id) => _db.collection('sessions').doc(id).get()),
      );
      return sessionDocs
          .where((doc) => doc.exists)
          .where((doc) => (doc.data()!['status'] as String?) == 'upcoming')
          .map((doc) => Session.fromMap(doc.id, doc.data()!))
          .toList();
    }).listen((sessions) {
      rsvpLinked = sessions;
      emit();
    });

    controller.onCancel = () {
      upcomingSub.cancel();
      rsvpSub.cancel();
    };

    return controller.stream;
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    final doc = await _db.collection('sessions').doc(sessionId).get();
    if (!doc.exists) return null;
    return Session.fromMap(doc.id, doc.data()!);
  }

  // ── RSVPs ─────────────────────────────────────────────────────────────────

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

  /// Creates or updates a player's RSVP for a session.
  ///
  /// When a player goes from non-confirmed → confirmed:
  ///   • rsvpCount on the session doc increments
  ///   • A payment doc is created (status='unpaid') if one does not exist yet
  ///
  /// When a player goes from confirmed → non-confirmed:
  ///   • rsvpCount decrements
  ///   • The first waitlist entry is promoted to confirmed
  @override
  Future<void> upsertRsvp({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String status,
    String? declineReason,
    double amount = 0.0,
  }) async {
    final existing =
        await getPlayerRsvp(sessionId: sessionId, playerId: playerId);
    final oldStatus = existing?.status;

    final rsvpId = 'rsvp_${sessionId}_$playerId';
    final batch = _db.batch();

    batch.set(
      _db.collection('rsvps').doc(rsvpId),
      {
        'rsvpId': rsvpId,
        'sessionId': sessionId,
        'playerId': playerId,
        'playerName': playerName,
        'status': status,
        if (declineReason != null) 'declineReason': declineReason,
        'respondedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    final sessionRef = _db.collection('sessions').doc(sessionId);

    if (status == 'confirmed' && oldStatus != 'confirmed') {
      // Increment the confirmed player count on the session.
      batch.update(sessionRef, {'rsvpCount': FieldValue.increment(1)});

      // Create the payment record if it doesn't exist yet.
      // merge: true means re-confirming after having paid doesn't reset status.
      final paymentId = 'pay_${sessionId}_$playerId';
      batch.set(
        _db.collection('payments').doc(paymentId),
        {
          'paymentId': paymentId,
          'sessionId': sessionId,
          'playerId': playerId,
          'playerName': playerName,
          'amount': amount,
          'status': 'unpaid',
        },
        SetOptions(merge: true),
      );
    } else if (status != 'confirmed' && oldStatus == 'confirmed') {
      batch.update(sessionRef, {'rsvpCount': FieldValue.increment(-1)});
    }

    await batch.commit();

    // After decrementing, promote the first waitlist entry outside the batch
    // so the batch stays atomic for the RSVP change itself.
    if (status != 'confirmed' && oldStatus == 'confirmed') {
      await _promoteNextWaitlistEntry(sessionId);
    }
  }

  /// Promotes the first waiting entry to confirmed and creates their RSVP +
  /// increments rsvpCount in a single batch.
  Future<void> _promoteNextWaitlistEntry(String sessionId) async {
    final waitlistSnap = await _db
        .collection('waitlist')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'waiting')
        .orderBy('position')
        .limit(1)
        .get();

    if (waitlistSnap.docs.isEmpty) return;

    final entry = waitlistSnap.docs.first;
    final data = entry.data();
    final promotedPlayerId = data['playerId'] as String;
    final promotedPlayerName = data['playerName'] as String;

    // Fetch session to get the current cost for the payment doc.
    final sessionDoc =
        await _db.collection('sessions').doc(sessionId).get();
    final amount =
        (sessionDoc.data()?['costPerPlayer'] as num?)?.toDouble() ?? 0.0;

    final batch = _db.batch();

    // Mark waitlist entry as promoted.
    batch.update(entry.reference, {'status': 'promoted'});

    // Create confirmed RSVP for the promoted player.
    final rsvpId = 'rsvp_${sessionId}_$promotedPlayerId';
    batch.set(
      _db.collection('rsvps').doc(rsvpId),
      {
        'rsvpId': rsvpId,
        'sessionId': sessionId,
        'playerId': promotedPlayerId,
        'playerName': promotedPlayerName,
        'status': 'confirmed',
        'respondedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // Increment rsvpCount back up.
    batch.update(
      _db.collection('sessions').doc(sessionId),
      {'rsvpCount': FieldValue.increment(1)},
    );

    // Create payment doc for promoted player.
    final paymentId = 'pay_${sessionId}_$promotedPlayerId';
    batch.set(
      _db.collection('payments').doc(paymentId),
      {
        'paymentId': paymentId,
        'sessionId': sessionId,
        'playerId': promotedPlayerId,
        'playerName': promotedPlayerName,
        'amount': amount,
        'status': 'unpaid',
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// Streams all RSVPs for a session (confirmed + pending + declined).
  /// Used by [RsvpConfirmationViewModel] to compute going/maybe/out tallies.
  @override
  Stream<List<Rsvp>> watchSessionRsvps(String sessionId) {
    return _db
        .collection('rsvps')
        .where('sessionId', isEqualTo: sessionId)
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

  // ── Waitlist ──────────────────────────────────────────────────────────────

  @override
  Future<void> joinWaitlist({
    required String sessionId,
    required String playerId,
    required String playerName,
  }) async {
    final snapshot = await _db
        .collection('waitlist')
        .where('sessionId', isEqualTo: sessionId)
        .where('status', isEqualTo: 'waiting')
        .get();

    final nextPosition = snapshot.docs.length + 1;

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

  // ── Payments ──────────────────────────────────────────────────────────────

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
