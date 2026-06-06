import 'package:cloud_firestore/cloud_firestore.dart';
import '../venue_repository.dart';

class FirebaseVenueRepository implements VenueRepository {
  final FirebaseFirestore _db;

  FirebaseVenueRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>?> getVenueByOwnerId(String ownerId) async {
    final snapshot = await _db
        .collection('venues')
        .where('ownerId', isEqualTo: ownerId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return {'venueId': doc.id, ...doc.data()};
  }

  @override
  Future<String> createVenue(Map<String, dynamic> venueData) async {
    final docRef = _db.collection('venues').doc();
    await docRef.set({
      'venueId': docRef.id,
      ...venueData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  @override
  Future<void> generateSlots(
    String venueId,
    int courtCount,
    int startHour,
    int endHour,
  ) async {
    final batch = _db.batch();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    for (int dayOffset = 0; dayOffset < 14; dayOffset++) {
      final date = today.add(Duration(days: dayOffset));
      final dayName = days[date.weekday - 1];
      final dateStr = '$dayName, ${date.day} ${months[date.month - 1]}';

      for (int courtIndex = 0; courtIndex < courtCount; courtIndex++) {
        for (int hour = startHour; hour < endHour; hour++) {
          final period = hour < 12 ? 'AM' : 'PM';
          final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
          final timeLabel = '$displayHour:00 $period';

          final slotId = '${venueId}_c${courtIndex}_d${dayOffset}_h$hour';

          final docRef = _db.collection('slots').doc(slotId);
          batch.set(docRef, {
            'slotId': slotId,
            'venueId': venueId,
            'courtIndex': courtIndex,
            'date': dateStr,
            'dateTimestamp': Timestamp.fromDate(DateTime(
              date.year, date.month, date.day, hour,
            )),
            'timeLabel': timeLabel,
            'status': 'available',
            'isEnabled': true,
            'sessionId': null,
          });
        }
      }
    }

    await batch.commit();
  }
}
