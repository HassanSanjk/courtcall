

abstract class AvailabilityRepository {
  Stream<List<dynamic>> watchSlots(String venueId, String weekStart);
  Future<void> saveSlots(String venueId, List<Map<String, dynamic>> slots);
  Future<bool> isSlotAvailable(String venueId, int courtIndex, DateTime startTime, DateTime endTime);
  Future<void> markSlotBooked(String venueId, int courtIndex, DateTime startTime, DateTime endTime, String sessionId);
}