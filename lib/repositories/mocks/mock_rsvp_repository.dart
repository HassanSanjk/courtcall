import '../rsvp_repository.dart';

class MockRsvpRepository implements RsvpRepository {
  static final List<Map<String, dynamic>> _rsvps = [
    {
      'id': 'rsvp_1',
      'sessionId': 'session_1',
      'playerId': 'player_1',
      'playerName': 'Alice Johnson',
      'status': 'confirmed',
    },
    {
      'id': 'rsvp_2',
      'sessionId': 'session_1',
      'playerId': 'player_2',
      'playerName': 'Bob Smith',
      'status': 'pending',
    },
    {
      'id': 'rsvp_3',
      'sessionId': 'session_1',
      'playerId': 'player_3',
      'playerName': 'Charlie Davis',
      'status': 'confirmed',
    },
  ];

  @override
  Stream<List<dynamic>> watchRsvpsForSession(String sessionId) =>
      Stream.value(_rsvps.where((r) => r['sessionId'] == sessionId).toList());

  @override
  Future<void> updateRsvpStatus(String rsvpId, String status) => Future.value();
}
