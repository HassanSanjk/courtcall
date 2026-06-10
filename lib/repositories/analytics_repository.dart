

abstract class AnalyticsRepository {
  Stream<Map<String, dynamic>> watchAnalytics(String venueId, String period);
}