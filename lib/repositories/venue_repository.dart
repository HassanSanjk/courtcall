import '../models/models.dart';

abstract class VenueRepository {
  Future<Map<String, dynamic>?> getVenueByOwnerId(String ownerId);
  Future<Map<String, dynamic>?> getVenueById(String venueId);
  Future<List<Venue>> getAllVenues();
  Future<String> createVenue(Map<String, dynamic> venueData);
  Future<void> generateSlots(
    String venueId,
    int courtCount,
    int startHour,
    int endHour,
  );
  Future<void> updateVenueImage(String venueId, String imageUrl);
}
