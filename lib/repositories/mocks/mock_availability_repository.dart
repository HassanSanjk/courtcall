// repositories/mocks/mock_availability_repository.dart

import '../availability_repository.dart';

class MockAvailabilityRepository implements AvailabilityRepository {
  static final List<Map<String, dynamic>> _slots = [
    {
      'id': 'slot_1',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-09',
      'dateLabel': 'Friday, 9 May',
      'isToday': true,
      'timeLabel': '6:00 PM',
      'status': 'available',
      'isEnabled': true,
    },
    {
      'id': 'slot_2',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-09',
      'dateLabel': 'Friday, 9 May',
      'isToday': true,
      'timeLabel': '7:00 PM',
      'status': 'available',
      'isEnabled': true,
    },
    {
      'id': 'slot_3',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-09',
      'dateLabel': 'Friday, 9 May',
      'isToday': true,
      'timeLabel': '8:00 PM',
      'status': 'maintenance',
      'isEnabled': false,
    },
    {
      'id': 'slot_4',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-09',
      'dateLabel': 'Friday, 9 May',
      'isToday': true,
      'timeLabel': '9:00 PM',
      'status': 'booked',
      'isEnabled': false,
    },
    {
      'id': 'slot_5',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-09',
      'dateLabel': 'Friday, 9 May',
      'isToday': true,
      'timeLabel': '10:00 PM',
      'status': 'open',
      'isEnabled': false,
    },
    {
      'id': 'slot_6',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-10',
      'dateLabel': 'Saturday, 10 May',
      'isToday': false,
      'timeLabel': '6:00 PM',
      'status': 'booked',
      'isEnabled': false,
    },
    {
      'id': 'slot_7',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-10',
      'dateLabel': 'Saturday, 10 May',
      'isToday': false,
      'timeLabel': '7:00 PM',
      'status': 'booked',
      'isEnabled': false,
    },
    {
      'id': 'slot_8',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-10',
      'dateLabel': 'Saturday, 10 May',
      'isToday': false,
      'timeLabel': '8:00 PM',
      'status': 'available',
      'isEnabled': true,
    },
    {
      'id': 'slot_9',
      'venueId': 'venue_1',
      'weekStart': '2026-05-09',
      'courtIndex': 0,
      'date': '2026-05-10',
      'dateLabel': 'Saturday, 10 May',
      'isToday': false,
      'timeLabel': '9:00 PM',
      'status': 'open',
      'isEnabled': false,
    },
  ];

  @override
  Stream<List<dynamic>> watchSlots(String venueId, String weekStart) =>
      Stream.value(
        _slots
            .where((s) =>
                s['venueId'] == venueId && s['weekStart'] == weekStart)
            .toList(),
      );

  @override
  Future<void> saveSlots(
          String venueId, List<Map<String, dynamic>> slots) =>
      Future.value();
}