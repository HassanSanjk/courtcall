// TODO: replace dynamic with Rsvp model once defined by Hassan.
abstract class RsvpRepository {
  Stream<List<dynamic>> watchRsvpsForSession(String sessionId);
  Future<void> updateRsvpStatus(String rsvpId, String status);
}
