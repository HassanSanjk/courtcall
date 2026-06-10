import 'dart:async';
import 'package:courtcall/models/models.dart';
import 'package:courtcall/repositories/player_repository.dart';

/// Mock implementation of [PlayerRepository].
///
/// Returns realistic in-memory data so all Player screens can be
/// developed and tested without a live Firestore connection.
/// Swap this for [FirebasePlayerRepository] in app.dart providers
/// when the real backend is ready.
class MockPlayerRepository implements PlayerRepository {
  // ── Seed data ─────────────────────────────────────────────────────────

  final List<Session> _sessions = [
    Session(
      sessionId: 'session_001',
      organizerId: 'organizer_001',
      venueId: 'venue_001',
      venueName: 'Nexus Futsal, Cheras',
      court: 'Court 3',
      date: 'Friday, 9 May',
      dateTimestamp: DateTime(2025, 5, 9, 20, 0),
      time: '8:00PM-10:00PM',
      maxPlayers: 12,
      rsvpCount: 8,
      costPerPlayer: 15.0,
      status: 'upcoming',
      createdAt: DateTime(2025, 5, 1),
      sport: 'futsal',
    ),
    Session(
      sessionId: 'session_002',
      organizerId: 'organizer_002',
      venueId: 'venue_002',
      venueName: 'SportsRally Arena, PJ',
      court: 'Court 1',
      date: 'Sunday, 11 May',
      dateTimestamp: DateTime(2025, 5, 11, 9, 0),
      time: '9:00AM-11:00AM',
      maxPlayers: 4,
      rsvpCount: 4,
      costPerPlayer: 18.0,
      status: 'upcoming',
      createdAt: DateTime(2025, 5, 2),
      sport: 'badminton',
    ),
    Session(
      sessionId: 'session_003',
      organizerId: 'organizer_001',
      venueId: 'venue_001',
      venueName: 'Nexus Futsal, Cheras',
      court: 'Court 2',
      date: 'Friday, 2 May',
      dateTimestamp: DateTime(2025, 5, 2, 20, 0),
      time: '8:00PM-10:00PM',
      maxPlayers: 12,
      rsvpCount: 10,
      costPerPlayer: 15.0,
      status: 'completed',
      createdAt: DateTime(2025, 4, 28),
      sport: 'futsal',
    ),
    Session(
      sessionId: 'session_004',
      organizerId: 'organizer_003',
      venueId: 'venue_003',
      venueName: 'Mega Court KL',
      court: 'Court 1',
      date: 'Tuesday, 6 May',
      dateTimestamp: DateTime(2025, 5, 6, 20, 0),
      time: '8:00PM-10:00PM',
      maxPlayers: 10,
      rsvpCount: 8,
      costPerPlayer: 15.0,
      status: 'completed',
      createdAt: DateTime(2025, 4, 30),
      sport: 'futsal',
    ),
  ];

  final Map<String, Rsvp> _rsvps = {
    'rsvp_session_001_player_001': const Rsvp(
      rsvpId: 'rsvp_session_001_player_001',
      sessionId: 'session_001',
      playerId: 'player_001',
      playerName: 'Hussein',
      status: 'pending',
    ),
    'rsvp_session_002_player_001': const Rsvp(
      rsvpId: 'rsvp_session_002_player_001',
      sessionId: 'session_002',
      playerId: 'player_001',
      playerName: 'Hussein',
      status: 'pending',
    ),
    'rsvp_session_003_player_001': const Rsvp(
      rsvpId: 'rsvp_session_003_player_001',
      sessionId: 'session_003',
      playerId: 'player_001',
      playerName: 'Hussein',
      status: 'confirmed',
    ),
    'rsvp_session_004_player_001': const Rsvp(
      rsvpId: 'rsvp_session_004_player_001',
      sessionId: 'session_004',
      playerId: 'player_001',
      playerName: 'Hussein',
      status: 'confirmed',
    ),
  };

  // Confirmed player names per session for avatar rows.
  final Map<String, List<String>> _sessionPlayerNames = {
    'session_001': ['Azri', 'Hafiz', 'Syafiq', 'Danial', 'Faris', 'Imran', 'Kamal', 'Zikri'],
    'session_002': ['Syafiq', 'Danial', 'Kamal', 'Faris'],
    'session_003': ['Azri', 'Hussein', 'Syafiq', 'Faris', 'Imran', 'Danial', 'Kamal', 'Zikri', 'Hafiz', 'Ali'],
    'session_004': ['Hussein', 'Azri', 'Syafiq', 'Faris', 'Imran', 'Danial', 'Kamal', 'Zikri'],
  };

  // FIX: pay_002 was incorrectly pointing to session_003.
  // pay_002 = Tuesday Futsal (session_004), pay_003 = Sunday Badminton (session_002).
  final List<Payment> _payments = [
    const Payment(
      paymentId: 'pay_001',
      sessionId: 'session_004',
      playerId: 'player_001',
      playerName: 'Hussein',
      amount: 15.0,
      status: 'unpaid',
      sessionName: 'Tuesday Futsal',
      sessionDate: '6 May 2025',
    ),
    const Payment(
      paymentId: 'pay_002',
      sessionId: 'session_003',  // Friday Futsal at Nexus
      playerId: 'player_001',
      playerName: 'Hussein',
      amount: 15.0,
      status: 'unpaid',
      sessionName: 'Friday Futsal',
      sessionDate: '2 May 2025',
    ),
    const Payment(
      paymentId: 'pay_003',
      sessionId: 'session_002',  // FIX: was session_003, should be the badminton session
      playerId: 'player_001',
      playerName: 'Hussein',
      amount: 18.0,
      status: 'paid',
      sessionName: 'Sunday Badminton',
      sessionDate: '11 May 2025',
    ),
    const Payment(
      paymentId: 'pay_004',
      sessionId: 'session_003',
      playerId: 'player_001',
      playerName: 'Hussein',
      amount: 15.0,
      status: 'paid',
      sessionName: 'Friday Futsal',
      sessionDate: '2 May 2025',
    ),
  ];

  // ── StreamControllers ─────────────────────────────────────────────────

  final _sessionsController = StreamController<List<Session>>.broadcast();
  final _paymentsController = StreamController<List<Payment>>.broadcast();
  final Map<String, StreamController<List<Rsvp>>> _rsvpControllers = {};

  // ── PlayerRepository implementation ──────────────────────────────────

  @override
  Stream<List<Session>> watchPlayerSessions(String playerId) {
    Future.microtask(() => _sessionsController.add(_sessions));
    return _sessionsController.stream;
  }

  @override
  Future<Session?> getSession(String sessionId) async {
    try {
      return _sessions.firstWhere((s) => s.sessionId == sessionId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Rsvp?> getPlayerRsvp({
    required String sessionId,
    required String playerId,
  }) async {
    final key = 'rsvp_${sessionId}_$playerId';
    return _rsvps[key];
  }

  @override
  Future<void> upsertRsvp({
    required String sessionId,
    required String playerId,
    required String playerName,
    required String status,
    String? declineReason,
    double amount = 0.0,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final key = 'rsvp_${sessionId}_$playerId';
    _rsvps[key] = Rsvp(
      rsvpId: key,
      sessionId: sessionId,
      playerId: playerId,
      playerName: playerName,
      status: status,
      declineReason: declineReason,
    );

    // Refresh sessions stream
    _sessionsController.add(_sessions);

    // Refresh rsvp stream for this session
    _emitRsvpsForSession(sessionId);
  }

  @override
  Stream<List<Rsvp>> watchSessionRsvps(String sessionId) {
    _rsvpControllers[sessionId] ??=
        StreamController<List<Rsvp>>.broadcast();
    Future.microtask(() => _emitRsvpsForSession(sessionId));
    return _rsvpControllers[sessionId]!.stream;
  }

  void _emitRsvpsForSession(String sessionId) {
    final rsvps = _rsvps.values
        .where((r) => r.sessionId == sessionId && r.isConfirmed)
        .toList();
    _rsvpControllers[sessionId]?.add(rsvps);
  }

  /// FIX: Implements the interface method - no longer a mock-specific helper.
  /// The real Firebase implementation should query confirmed RSVPs for the
  /// session and return their playerName values.
  @override
  Future<List<String>> getConfirmedPlayerNames(String sessionId) async {
    return _sessionPlayerNames[sessionId] ?? [];
  }

  @override
  Future<void> joinWaitlist({
    required String sessionId,
    required String playerId,
    required String playerName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Mock - no-op; position logic handled by Firestore transaction in real impl.
  }

  @override
  Stream<List<Payment>> watchPlayerPayments(String playerId) {
    Future.microtask(() => _paymentsController.add(_payments));
    return _paymentsController.stream;
  }

  @override
  Future<void> markPaid({
    required String paymentId,
    required String transactionRef,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _payments.indexWhere((p) => p.paymentId == paymentId);
    if (index != -1) {
      _payments[index] = _payments[index].copyWith(
        status: 'paid',
        transactionRef: transactionRef,
        paidAt: DateTime.now(),
      );
      _paymentsController.add(_payments);
    }
  }

  /// Close all open StreamControllers.
  ///
  /// Call this in [tearDown] of any test that creates a [MockPlayerRepository]
  /// to avoid "StreamController garbage-collected while listeners were active"
  /// warnings.
  void dispose() {
    _sessionsController.close();
    _paymentsController.close();
    for (final controller in _rsvpControllers.values) {
      controller.close();
    }
    _rsvpControllers.clear();
  }
}
