import 'dart:async';
import '../session_repository.dart';
import '../../models/session.dart';

class MockSessionRepository implements SessionRepository {
  final List<Session> _sessions = [
    const Session(
      id: 'session_1',
      sport: 'Futsal',
      venueName: 'Nexus Futsal',
      courtName: 'Court 3',
      date: '2026-05-19',
      startTime: '8:00 PM',
      endTime: '10:00 PM',
      maxPlayers: 10,
      confirmedCount: 7,
      costPerPlayer: 15.0,
      courtCost: 120.0,
      status: 'upcoming',
    ),
    const Session(
      id: 'session_2',
      sport: 'Badminton',
      venueName: 'Westside Arena',
      courtName: 'Court 2',
      date: '2026-05-22',
      startTime: '9:00 AM',
      endTime: '11:00 AM',
      maxPlayers: 4,
      confirmedCount: 2,
      costPerPlayer: 10.0,
      courtCost: 60.0,
      status: 'upcoming',
    ),
    const Session(
      id: 'session_3',
      sport: 'Futsal',
      venueName: 'Northpark Courts',
      courtName: 'Court B',
      date: '2026-05-24',
      startTime: '6:00 PM',
      endTime: '8:00 PM',
      maxPlayers: 8,
      confirmedCount: 5,
      costPerPlayer: 15.0,
      courtCost: 120.0,
      status: 'upcoming',
    ),
  ];

  final _ctrl = StreamController<List<Session>>.broadcast();

  @override
  Stream<List<Session>> watchUpcomingSessions(String organizerId) async* {
    yield List.from(_sessions);
    yield* _ctrl.stream;
  }

  @override
  Future<String> createSession(Map<String, dynamic> data) async {
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _sessions.add(Session.fromJson({...data, 'id': id}));
    _ctrl.add(List.from(_sessions));
    return id;
  }

  @override
  Future<void> updateSession(String sessionId, Map<String, dynamic> data) async {}

  @override
  Future<void> cancelSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    _ctrl.add(List.from(_sessions));
  }

  void dispose() => _ctrl.close();
}
