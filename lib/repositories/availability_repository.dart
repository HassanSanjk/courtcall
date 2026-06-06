// repositories/availability_repository.dart

abstract class AvailabilityRepository {
  Stream<List<dynamic>> watchSlots(String venueId, String weekStart);
  Future<void> saveSlots(String venueId, List<Map<String, dynamic>> slots);
}