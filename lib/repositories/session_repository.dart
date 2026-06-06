// TODO: replace dynamic with Session model once defined by Hassan.
abstract class SessionRepository {
  Stream<List<dynamic>> watchUpcomingSessions(String organizerId);
  Future<String> createSession(Map<String, dynamic> data);
  Future<void> updateSession(String sessionId, Map<String, dynamic> data);
  Future<void> cancelSession(String sessionId);
}
