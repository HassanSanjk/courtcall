// repositories/mocks/mock_map_repository.dart

import 'package:courtcall/repositories/map_repository.dart';

class MockMapRepository implements MapRepository {
  static final List<Map<String, dynamic>> _sessions = [
    {
      'id': 'map_session_1',
      'name': 'Nexus Futsal',
      'court': 'Court 1',
      'sport': 'Futsal',
      'lat': 3.1390,
      'lng': 101.6869,
      'price': 25.0,
      'time': '8:00 PM – 10:00 PM',
      'date': 'Friday, 9 May',
      'venueId': 'venue_1',
      'imageUrl': '',
    },
    {
      'id': 'map_session_2',
      'name': 'Arena Futsal',
      'court': 'Court 3',
      'sport': 'Futsal',
      'lat': 3.1450,
      'lng': 101.6950,
      'price': 20.0,
      'time': '7:00 PM – 9:00 PM',
      'date': 'Friday, 9 May',
      'venueId': 'venue_2',
      'imageUrl': '',
    },
    {
      'id': 'map_session_3',
      'name': 'Pro Futsal KL',
      'court': 'Court 2',
      'sport': 'Futsal',
      'lat': 3.1320,
      'lng': 101.6800,
      'price': 30.0,
      'time': '9:00 PM – 11:00 PM',
      'date': 'Friday, 9 May',
      'venueId': 'venue_3',
      'imageUrl': '',
    },
    {
      'id': 'map_session_4',
      'name': 'City Sports Hub',
      'court': 'VIP Court',
      'sport': 'Badminton',
      'lat': 3.1500,
      'lng': 101.7000,
      'price': 40.0,
      'time': '6:00 PM – 8:00 PM',
      'date': 'Friday, 9 May',
      'venueId': 'venue_4',
      'imageUrl': '',
    },
  ];

  @override
  Future<List<dynamic>> getNearbySessions({
    required double lat,
    required double lng,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _sessions;
  }
}