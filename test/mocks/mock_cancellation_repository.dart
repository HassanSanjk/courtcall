// repositories/mocks/mock_cancellation_repository.dart

import 'package:courtcall/repositories/cancellation_repository.dart';

class MockCancellationRepository implements CancellationRepository {
  static final Map<String, dynamic> _alert = {
    'slotId': 'slot_3',
    'venueId': 'venue_1',
    'sessionName': 'Friday Futsal',
    'organizerName': 'Azri',
    'court': 'Court 1',
    'timeRange': '8:00 PM - 10:00 PM',
    'dateLabel': '9 May 2026, Friday',
    'lostRevenue': 'RM 120',
    'depositCollected': 'RM 50 deposit was collected.',
    'noticeHours': 2,
    'history': [
      {
        'prefixText': 'Azri has cancelled ',
        'highlightText': '3 times',
        'suffixText': ' this month.',
        'isWarning': true,
      },
      {
        'prefixText': 'Azri has completed ',
        'highlightText': '12 sessions',
        'suffixText': ' successfully.',
        'isWarning': false,
      },
    ],
  };

  @override
  Stream<Map<String, dynamic>> watchCancellationAlert(String venueId) =>
      Stream.value(_alert);

  @override
  Future<void> markSlotAvailable(String venueId, String slotId) =>
      Future.value();
}