// repositories/mocks/mock_analytics_repository.dart

import 'package:courtcall/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  static final Map<String, Map<String, dynamic>> _data = {
    'thisWeek': {
      'totalRevenue': 'RM 4,500',
      'trend': '+12%',
      'isTrendPositive': true,
      'periodLabel': "THIS WEEK'S REVENUE",
      'bars': [
        {'value': 300.0, 'isHighlighted': false},
        {'value': 500.0, 'isHighlighted': false},
        {'value': 450.0, 'isHighlighted': false},
        {'value': 600.0, 'isHighlighted': false},
        {'value': 800.0, 'isHighlighted': true},
        {'value': 1100.0, 'isHighlighted': true},
        {'value': 750.0, 'isHighlighted': false},
      ],
      'dayLabels': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'sessions': 45,
      'cancelled': 3,
      'noShowRate': '5%',
      'topOrganizers': [
        {'name': 'Azri', 'sessions': 12, 'revenue': 'RM 1,800'},
        {'name': 'Syafiq', 'sessions': 8, 'revenue': 'RM 1,200'},
        {'name': 'Danial', 'sessions': 6, 'revenue': 'RM 900'},
      ],
    },
    'thisMonth': {
      'totalRevenue': 'RM 14,250',
      'trend': '+8%',
      'isTrendPositive': true,
      'periodLabel': "THIS MONTH'S REVENUE",
      'bars': [
        {'value': 2000.0, 'isHighlighted': false},
        {'value': 3500.0, 'isHighlighted': true},
        {'value': 4500.0, 'isHighlighted': true},
        {'value': 4250.0, 'isHighlighted': false},
      ],
      'dayLabels': ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
      'sessions': 168,
      'cancelled': 11,
      'noShowRate': '8.5%',
      'topOrganizers': [
        {'name': 'Azri', 'sessions': 42, 'revenue': 'RM 6,300'},
        {'name': 'Hafiz', 'sessions': 30, 'revenue': 'RM 4,500'},
        {'name': 'Syafiq', 'sessions': 22, 'revenue': 'RM 3,300'},
      ],
    },
    'allTime': {
      'totalRevenue': 'RM 98,400',
      'trend': '+24%',
      'isTrendPositive': true,
      'periodLabel': 'ALL TIME REVENUE',
      'bars': [
        {'value': 5000.0, 'isHighlighted': false},
        {'value': 7200.0, 'isHighlighted': false},
        {'value': 9800.0, 'isHighlighted': false},
        {'value': 11000.0, 'isHighlighted': false},
        {'value': 14500.0, 'isHighlighted': false},
        {'value': 18000.0, 'isHighlighted': true},
        {'value': 19200.0, 'isHighlighted': true},
        {'value': 13700.0, 'isHighlighted': false},
      ],
      'dayLabels': ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'],
      'sessions': 1240,
      'cancelled': 87,
      'noShowRate': '6.2%',
      'topOrganizers': [
        {'name': 'Azri', 'sessions': 310, 'revenue': 'RM 46,500'},
        {'name': 'Hafiz', 'sessions': 240, 'revenue': 'RM 36,000'},
        {'name': 'Syafiq', 'sessions': 198, 'revenue': 'RM 29,700'},
      ],
    },
  };

  @override
  Stream<Map<String, dynamic>> watchAnalytics(
          String venueId, String period) =>
      Stream.value(_data[period] ?? _data['thisWeek']!);
}