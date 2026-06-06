import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cancellation_repository.dart';

class FirebaseCancellationRepository implements CancellationRepository {
  final FirebaseFirestore _db;

  FirebaseCancellationRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<Map<String, dynamic>> watchCancellationAlert(String venueId) {
    final controller = StreamController<Map<String, dynamic>>();

    StreamSubscription? recentSub;

    void emit(Map<String, dynamic>? recent) {
      if (recent == null) {
        if (!controller.isClosed) {
          controller.add({
            'slotId': '',
            'venueId': venueId,
            'sessionName': 'No recent cancellations',
            'organizerName': '',
            'court': '',
            'timeRange': '',
            'dateLabel': '',
            'lostRevenue': 'RM 0',
            'depositCollected': 'No deposit.',
            'noticeHours': 0,
            'history': <Map<String, dynamic>>[],
          });
        }
        return;
      }

      if (!controller.isClosed) {
        controller.add(recent);
      }
    }

    recentSub = _db
        .collection('cancellations')
        .where('venueId', isEqualTo: venueId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isEmpty) {
        emit(null);
        return;
      }

      final doc = snapshot.docs.first.data();
      final sessionId = doc['sessionId'] as String?;

      String sessionName = '';
      String organizerName = doc['organizerName'] as String? ?? '';
      String court = doc['court'] as String? ?? '';

      if (sessionId != null) {
        final sessionDoc = await _db.collection('sessions').doc(sessionId).get();
        final sessionData = sessionDoc.data();
        if (sessionData != null) {
          sessionName = sessionData['venueName'] as String? ?? '';
          court = sessionData['court'] as String? ?? court;
        }
      }

      final lostRevenue = doc['lostRevenue'] ?? 0;
      final depositCollected = doc['depositCollected'] ?? 0;
      final noticeHours = doc['noticeHours'] ?? 0;

      final history = await _buildHistory(venueId, doc['organizerId'] as String?, doc['organizerName'] as String? ?? '');

      emit({
        'slotId': doc['slotId'] ?? '',
        'venueId': venueId,
        'sessionName': sessionName,
        'organizerName': organizerName,
        'court': court,
        'timeRange': doc['timeRange'] ?? '',
        'dateLabel': doc['dateLabel'] ?? '',
        'lostRevenue': 'RM $lostRevenue',
        'depositCollected': depositCollected > 0
            ? 'RM $depositCollected deposit was collected.'
            : 'No deposit.',
        'noticeHours': noticeHours,
        'history': history,
      });
    });

    controller.onCancel = () {
      recentSub?.cancel();
    };

    return controller.stream;
  }

  Future<List<Map<String, dynamic>>> _buildHistory(
      String venueId, String? organizerId, String organizerName) async {
    final history = <Map<String, dynamic>>[];

    if (organizerId == null) return history;

    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final cancellationsThisMonth = await _db
        .collection('cancellations')
        .where('venueId', isEqualTo: venueId)
        .where('organizerId', isEqualTo: organizerId)
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
        .count()
        .get();

    final cancelCount = cancellationsThisMonth.count ?? 0;
    history.add({
      'prefixText': '$organizerName has cancelled ',
      'highlightText': '$cancelCount times',
      'suffixText': cancelCount == 1 ? ' this month.' : ' this month.',
      'isWarning': cancelCount > 0,
    });

    final completedSessions = await _db
        .collection('sessions')
        .where('organizerId', isEqualTo: organizerId)
        .where('status', isEqualTo: 'completed')
        .count()
        .get();

    final completedCount = completedSessions.count ?? 0;
    history.add({
      'prefixText': '$organizerName has completed ',
      'highlightText': '$completedCount sessions',
      'suffixText': ' successfully.',
      'isWarning': false,
    });

    return history;
  }

  @override
  Future<void> markSlotAvailable(String venueId, String slotId) async {
    if (slotId.isEmpty) return;
    await _db.collection('slots').doc(slotId).update({
      'status': 'available',
      'isEnabled': true,
      'sessionId': null,
    });
  }
}
