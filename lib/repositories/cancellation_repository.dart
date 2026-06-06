// repositories/cancellation_repository.dart

abstract class CancellationRepository {
  Stream<Map<String, dynamic>> watchCancellationAlert(String venueId);
  Future<void> markSlotAvailable(String venueId, String slotId);
}