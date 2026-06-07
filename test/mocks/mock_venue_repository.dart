import 'package:courtcall/models/models.dart';
import 'package:courtcall/repositories/venue_repository.dart';

class MockVenueRepository implements VenueRepository {
  @override
  Future<String> createVenue(Map<String, dynamic> venueData) async {
    return 'mock_venue_id';
  }

  @override
  Future<List<Venue>> getAllVenues() async {
    return [];
  }

  @override
  Future<Map<String, dynamic>?> getVenueByOwnerId(String ownerId) async {
    return null;
  }

  @override
  Future<Map<String, dynamic>?> getVenueById(String venueId) async {
    return null;
  }

  @override
  Future<void> generateSlots(
    String venueId,
    int courtCount,
    int startHour,
    int endHour,
  ) async {}

  @override
  Future<void> updateVenueImage(String venueId, String imageUrl) async {}
}
