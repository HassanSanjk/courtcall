import '../models/session.dart';

abstract class SessionRepository {
  Stream<List<Session>> watchUpcomingSessions(String organizerId);
  Future<String> createSession(Map<String, dynamic> data);
  Future<void> updateSession(String sessionId, Map<String, dynamic> data);
  Future<void> cancelSession(String sessionId);
}
