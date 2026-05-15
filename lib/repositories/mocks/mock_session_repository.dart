import '../session_repository.dart';

class MockSessionRepository implements SessionRepository {
  static final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'session_1',
      'title': 'Monday Night 5v5',
      'date': '2026-05-19',
      'time': '20:00',
      'venue': 'Downtown Court',
      'organizerId': 'org_1',
      'status': 'upcoming',
      'maxPlayers': 10,
    },
    {
      'id': 'session_2',
      'title': 'Weekend Doubles',
      'date': '2026-05-22',
      'time': '09:00',
      'venue': 'Westside Arena',
      'organizerId': 'org_1',
      'status': 'upcoming',
      'maxPlayers': 4,
    },
    {
      'id': 'session_3',
      'title': 'Friday Friendly',
      'date': '2026-05-24',
      'time': '18:00',
      'venue': 'Northpark Courts',
      'organizerId': 'org_1',
      'status': 'upcoming',
      'maxPlayers': 8,
    },
  ];

  @override
  Stream<List<dynamic>> watchUpcomingSessions(String organizerId) =>
      Stream.value(List.from(_sessions));

  @override
  Future<String> createSession(Map<String, dynamic> data) =>
      Future.value('session_${DateTime.now().millisecondsSinceEpoch}');

  @override
  Future<void> updateSession(String sessionId, Map<String, dynamic> data) =>
      Future.value();

  @override
  Future<void> cancelSession(String sessionId) => Future.value();
}
