import '../models/models.dart';

abstract class RsvpRepository {
  Stream<List<Rsvp>> watchRsvpsForSession(String sessionId);
  Future<void> updateRsvpStatus(String rsvpId, String status, {String? declineReason});
}
