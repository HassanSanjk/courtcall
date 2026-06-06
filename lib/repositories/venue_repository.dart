abstract class VenueRepository {
  Future<Map<String, dynamic>?> getVenueByOwnerId(String ownerId);
  Future<String> createVenue(Map<String, dynamic> venueData);
  Future<void> generateSlots(
    String venueId,
    int courtCount,
    int startHour,
    int endHour,
  );
}
