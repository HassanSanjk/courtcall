import 'dart:async';
import 'package:courtcall/repositories/session_repository.dart';
import 'package:courtcall/models/models.dart';

class MockSessionRepository implements SessionRepository {
  final List<Session> _sessions = [
    Session(
      sessionId: 'session_1',
      organizerId: 'org_1',
      venueId: 'v1',
      venueName: 'Nexus Futsal',
      court: 'Court 3',
      date: '2026-05-19',
      dateTimestamp: DateTime(2026, 5, 19),
      time: '8:00 PM-10:00 PM',
      maxPlayers: 10,
      rsvpCount: 7,
      costPerPlayer: 15.0,
      status: 'upcoming',
      createdAt: DateTime(2026, 5, 10),
      sport: 'Futsal',
    ),
    Session(
      sessionId: 'session_2',
      organizerId: 'org_1',
      venueId: 'v2',
      venueName: 'Westside Arena',
      court: 'Court 2',
      date: '2026-05-22',
      dateTimestamp: DateTime(2026, 5, 22),
      time: '9:00 AM-11:00 AM',
      maxPlayers: 4,
      rsvpCount: 2,
      costPerPlayer: 10.0,
      status: 'upcoming',
      createdAt: DateTime(2026, 5, 10),
      sport: 'Badminton',
    ),
    Session(
      sessionId: 'session_3',
      organizerId: 'org_1',
      venueId: 'v3',
      venueName: 'Northpark Courts',
      court: 'Court B',
      date: '2026-05-24',
      dateTimestamp: DateTime(2026, 5, 24),
      time: '6:00 PM-8:00 PM',
      maxPlayers: 8,
      rsvpCount: 5,
      costPerPlayer: 15.0,
      status: 'upcoming',
      createdAt: DateTime(2026, 5, 10),
      sport: 'Futsal',
    ),
  ];

  final _ctrl = StreamController<List<Session>>.broadcast();

  @override
  Stream<List<Session>> watchUpcomingSessions(String organizerId) async* {
    yield List.from(_sessions);
    yield* _ctrl.stream;
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
  Future<String> createSession(Map<String, dynamic> data) async {
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessions.add(Session.fromMap(id, data));
    _ctrl.add(List.from(_sessions));
    return id;
  }

  @override
  Future<void> updateSession(String sessionId, Map<String, dynamic> data) async {}

  @override
  Future<void> cancelSession(String sessionId) async {
    _sessions.removeWhere((s) => s.sessionId == sessionId);
    _ctrl.add(List.from(_sessions));
  }

  @override
  Future<void> incrementRsvpCount(String sessionId) async {
    final idx = _sessions.indexWhere((s) => s.sessionId == sessionId);
    if (idx == -1) return;
    final old = _sessions[idx];
    _sessions[idx] = Session(
      sessionId: old.sessionId,
      organizerId: old.organizerId,
      venueId: old.venueId,
      venueName: old.venueName,
      court: old.court,
      date: old.date,
      dateTimestamp: old.dateTimestamp,
      time: old.time,
      maxPlayers: old.maxPlayers,
      rsvpCount: old.rsvpCount + 1,
      costPerPlayer: old.costPerPlayer,
      status: old.status,
      createdAt: old.createdAt,
      sport: old.sport,
    );
    _ctrl.add(List.from(_sessions));
  }

  void dispose() => _ctrl.close();
}
