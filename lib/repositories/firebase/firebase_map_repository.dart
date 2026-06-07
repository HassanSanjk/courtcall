import 'package:cloud_firestore/cloud_firestore.dart';
import '../map_repository.dart';

class FirebaseMapRepository implements MapRepository {
  final FirebaseFirestore _db;

  FirebaseMapRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<List<dynamic>> getNearbySessions({
    required double lat,
    required double lng,
  }) async {
    final venuesSnap = await _db.collection('venues').get();

    final results = <Map<String, dynamic>>[];
    for (final venueDoc in venuesSnap.docs) {
      final venueData = venueDoc.data();
      final venueId = venueData['venueId'] ?? venueDoc.id;

      final sessionsSnap = await _db
          .collection('sessions')
          .where('venueId', isEqualTo: venueId)
          .where('status', isEqualTo: 'upcoming')
          .limit(3)
          .get();

      for (final sessionDoc in sessionsSnap.docs) {
        final sessionData = sessionDoc.data();
        results.add({
          'id': sessionData['sessionId'] ?? sessionDoc.id,
          'name': venueData['name'] ?? '',
          'court': sessionData['court'] ?? '',
          'sport': sessionData['sport'] ?? '',
          'lat': venueData['lat'] ?? lat,
          'lng': venueData['lng'] ?? lng,
          'price': sessionData['costPerPlayer'] ?? 0,
          'time': sessionData['time'] ?? '',
          'date': sessionData['date'] ?? '',
          'venueId': venueData['venueId'] ?? venueDoc.id,
          'imageUrl': venueData['imageUrl'] ?? '',
        });
      }
    }

    return results;
  }
}
