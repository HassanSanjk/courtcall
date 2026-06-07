import 'package:courtcall/repositories/rsvp_repository.dart';
import 'package:courtcall/models/models.dart';

class MockRsvpRepository implements RsvpRepository {
  static final List<Rsvp> _rsvps = [
    Rsvp(rsvpId: 'rsvp_1', sessionId: 'session_1', playerId: 'player_1', playerName: 'Alice Johnson', status: 'confirmed'),
    Rsvp(rsvpId: 'rsvp_2', sessionId: 'session_1', playerId: 'player_2', playerName: 'Bob Smith', status: 'pending'),
    Rsvp(rsvpId: 'rsvp_3', sessionId: 'session_1', playerId: 'player_3', playerName: 'Charlie Davis', status: 'confirmed'),
  ];

  @override
  Stream<List<Rsvp>> watchRsvpsForSession(String sessionId) =>
      Stream.value(_rsvps.where((r) => r.sessionId == sessionId).toList());

  @override
  Future<void> updateRsvpStatus(String rsvpId, String status, {String? declineReason}) => Future.value();
}
