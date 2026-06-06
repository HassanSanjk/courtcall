import 'package:cloud_firestore/cloud_firestore.dart';
import '../availability_repository.dart';

class FirebaseAvailabilityRepository implements AvailabilityRepository {
  final FirebaseFirestore _db;

  FirebaseAvailabilityRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<dynamic>> watchSlots(String venueId, String weekStart) {
    final start = DateTime.parse(weekStart);
    final end = start.add(const Duration(days: 7));
    final today = DateTime.now();

    return _db
        .collection('slots')
        .where('venueId', isEqualTo: venueId)
        .where('dateTimestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('dateTimestamp', isLessThan: Timestamp.fromDate(end))
        .orderBy('dateTimestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final dateTs = data['dateTimestamp'] as Timestamp?;
        final docDate = dateTs?.toDate();
        return {
          'id': data['slotId'] ?? doc.id,
          'venueId': data['venueId'],
          'courtIndex': data['courtIndex'],
          'date': data['date'],
          'dateLabel': data['dateLabel'] ?? _formatDateLabel(docDate),
          'isToday': _isSameDay(docDate, today),
          'timeLabel': data['timeLabel'],
          'status': data['status'],
          'isEnabled': data['isEnabled'] ?? false,
          'sessionId': data['sessionId'],
        };
      }).toList();
    });
  }

  @override
  Future<void> saveSlots(String venueId, List<Map<String, dynamic>> slots) async {
    final batch = _db.batch();
    for (final slot in slots) {
      final id = slot['id'] as String?;
      if (id == null) continue;
      final docRef = _db.collection('slots').doc(id);
      batch.set(docRef, {
        'slotId': id,
        'venueId': venueId,
        'courtIndex': slot['courtIndex'],
        'date': slot['date'],
        'dateTimestamp': slot['dateTimestamp'],
        'dateLabel': slot['dateLabel'],
        'timeLabel': slot['timeLabel'],
        'status': slot['status'],
        'isEnabled': slot['isEnabled'],
        'sessionId': slot['sessionId'],
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _formatDateLabel(DateTime? date) {
    if (date == null) return '';
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
  }
}
