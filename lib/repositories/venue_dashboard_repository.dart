// repositories/venue_dashboard_repository.dart

abstract class VenueDashboardRepository {
  Stream<Map<String, dynamic>> watchDashboardData(String venueId);
}