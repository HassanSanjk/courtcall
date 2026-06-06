import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../venue_dashboard_repository.dart';

class FirebaseVenueDashboardRepository implements VenueDashboardRepository {
  final FirebaseFirestore _db;

  FirebaseVenueDashboardRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<Map<String, dynamic>> watchDashboardData(String venueId) {
    final controller = StreamController<Map<String, dynamic>>();

    StreamSubscription? venueSub;
    StreamSubscription? slotsSub;
    StreamSubscription? sessionsSub;

    String venueName = '';
    String ownerName = '';
    List<String> courtNames = [];
    List<Map<String, dynamic>> todaySlots = [];
    List<Map<String, dynamic>> upcomingSessions = [];

    void emit() {
      final schedule = _buildSchedule(todaySlots, courtNames);
      final todayBookings = todaySlots.where((s) => s['status'] == 'booked').length;
      final revenue = _computeExpectedRevenue(todaySlots);
      final bookings = _buildUpcomingBookings(upcomingSessions);

      if (!controller.isClosed) {
        controller.add({
          'venueId': venueId,
          'venueName': venueName,
          'ownerName': ownerName,
          'todayBookings': todayBookings,
          'expectedRevenue': 'RM $revenue',
          'courtNames': courtNames,
          'schedule': schedule,
          'upcomingBookings': bookings,
        });
      }
    }

    venueSub = _db.collection('venues').doc(venueId).snapshots().listen((doc) {
      final data = doc.data();
      if (data == null) return;
      venueName = data['name'] ?? '';
      courtNames = List<String>.from(data['courts'] ?? []);
      ownerName = data['ownerName'] as String? ?? 'Owner';
      emit();
    });

    final todayStart = _startOfToday();
    final todayEnd = todayStart.add(const Duration(days: 1));

    slotsSub = _db
        .collection('slots')
        .where('venueId', isEqualTo: venueId)
        .where('dateTimestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
        .where('dateTimestamp', isLessThan: Timestamp.fromDate(todayEnd))
        .orderBy('dateTimestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      todaySlots = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['slotId'] ?? doc.id,
          'courtIndex': data['courtIndex'],
          'timeLabel': data['timeLabel'],
          'status': data['status'],
          'playerName': data['sessionId'] != null ? 'BOOKED' : null,
        };
      }).toList();
      emit();
    });

    sessionsSub = _db
        .collection('sessions')
        .where('venueId', isEqualTo: venueId)
        .where('status', isEqualTo: 'upcoming')
        .orderBy('dateTimestamp', descending: false)
        .snapshots()
        .listen((snapshot) {
      upcomingSessions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': data['sessionId'] ?? doc.id,
          'time': data['time'] ?? '',
          'sessionName': '${data['venueName']} — ${data['court']}',
          'playerName': data['organizerName'] ?? '',
          'court': data['court'] ?? '',
          'isTentative': false,
        };
      }).toList();
      emit();
    });

    controller.onCancel = () {
      venueSub?.cancel();
      slotsSub?.cancel();
      sessionsSub?.cancel();
    };

    return controller.stream;
  }

  List<Map<String, dynamic>> _buildSchedule(
      List<Map<String, dynamic>> slots,
      List<String> courtNames) {
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final slot in slots) {
      final label = slot['timeLabel'] as String? ?? '';
      grouped.putIfAbsent(label, () => []);
      grouped[label]!.add(slot);
    }

    return grouped.entries.map((entry) {
      final timeSlots = entry.value;
      final courtSlots = List.generate(courtNames.length, (i) {
        final match = timeSlots.firstWhere(
          (s) => s['courtIndex'] == i,
          orElse: () => {'status': 'free', 'playerName': null},
        );
        return {
          'status': match['status'],
          'playerName': match['playerName'],
        };
      });
      return {
        'timeLabel': entry.key,
        'slots': courtSlots,
      };
    }).toList();
  }

  String _computeExpectedRevenue(List<Map<String, dynamic>> slots) {
    final booked = slots.where((s) => s['status'] == 'booked').length;
    return '${(booked * 50)}'; // rough estimate: RM 50 per slot
  }

  List<Map<String, dynamic>> _buildUpcomingBookings(
      List<Map<String, dynamic>> sessions) {
    return sessions.map((s) => {
      'time': s['time'],
      'sessionName': s['sessionName'],
      'playerName': s['playerName'],
      'court': s['court'],
      'isTentative': s['isTentative'],
    }).toList();
  }

  DateTime _startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}
