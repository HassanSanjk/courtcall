// repositories/mocks/mock_venue_dashboard_repository.dart

import 'package:courtcall/repositories/venue_dashboard_repository.dart';

class MockVenueDashboardRepository implements VenueDashboardRepository {
  static final Map<String, dynamic> _data = {
    'venueId': 'venue_1',
    'venueName': 'Nexus Futsal',
    'ownerName': 'En. Hafiz',
    'todayBookings': 12,
    'expectedRevenue': 'RM 1.2k',
    'courtNames': ['Court 1', 'Court 2', 'Court 3'],
    'schedule': [
      {
        'timeLabel': '6 PM',
        'slots': [
          {'status': 'available', 'playerName': 'Hafiz (P)'},
          {'status': 'free', 'playerName': null},
          {'status': 'booked', 'playerName': 'BOOKED'},
        ],
      },
      {
        'timeLabel': '7 PM',
        'slots': [
          {'status': 'booked', 'playerName': 'BOOKED'},
          {'status': 'booked', 'playerName': 'BOOKED'},
          {'status': 'booked', 'playerName': 'BOOKED'},
        ],
      },
      {
        'timeLabel': '8 PM',
        'slots': [
          {'status': 'available', 'playerName': 'Azri (P)'},
          {'status': 'booked', 'playerName': 'BOOKED'},
          {'status': 'blocked', 'playerName': null},
        ],
      },
      {
        'timeLabel': '9 PM',
        'slots': [
          {'status': 'booked', 'playerName': 'BOOKED'},
          {'status': 'free', 'playerName': null},
          {'status': 'blocked', 'playerName': null},
        ],
      },
      {
        'timeLabel': '10 PM',
        'slots': [
          {'status': 'free', 'playerName': null},
          {'status': 'free', 'playerName': null},
          {'status': 'maintenance', 'playerName': null},
        ],
      },
    ],
    'upcomingBookings': [
      {
        'time': '8PM',
        'sessionName': 'Friday Futsal',
        'playerName': 'Azri',
        'court': 'Court 1',
        'isTentative': false,
      },
      {
        'time': '9PM',
        'sessionName': 'Futsal Malam',
        'playerName': 'Syafiq',
        'court': 'Court 2',
        'isTentative': false,
      },
      {
        'time': '10PM',
        'sessionName': 'Casual Kick',
        'playerName': 'Danial',
        'court': 'Court 1',
        'isTentative': true,
      },
    ],
  };

  @override
  Stream<Map<String, dynamic>> watchDashboardData(String venueId) =>
      Stream.value(_data);
}