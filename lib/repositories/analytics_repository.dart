// repositories/analytics_repository.dart

abstract class AnalyticsRepository {
  Stream<Map<String, dynamic>> watchAnalytics(String venueId, String period);
}