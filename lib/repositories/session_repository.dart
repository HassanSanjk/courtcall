import '../models/models.dart';

abstract class SessionRepository {
  Stream<List<Session>> watchUpcomingSessions(String organizerId);
  Future<Session?> getSession(String sessionId);
  Future<String> createSession(Map<String, dynamic> data);
  Future<void> updateSession(String sessionId, Map<String, dynamic> data);
  Future<void> cancelSession(String sessionId);
  Future<void> incrementRsvpCount(String sessionId);
}
