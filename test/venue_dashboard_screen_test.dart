import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:courtcall/features/venue/venue_dashboard/venue_dashboard_screen.dart';
import 'package:courtcall/repositories/venue_dashboard_repository.dart';

class MockVenueDashboardRepository extends Mock implements VenueDashboardRepository {}

Widget Function(Widget) testAppBuilder = (Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows loading indicator then renders KPIs', (tester) async {
    final repo = MockVenueDashboardRepository();
    final controller = StreamController<Map<String, dynamic>>();
    when(() => repo.watchDashboardData(any())).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(
      testAppBuilder(VenueDashboardScreen(venueId: 'test_venue', repo: repo)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add({
      'venueName': 'Nexus Futsal',
      'ownerName': 'En. Hafiz',
      'todayBookings': 12,
      'expectedRevenue': 'RM 1.2k',
      'courtNames': ['Court 1', 'Court 2', 'Court 3'],
      'schedule': [
        {'timeLabel': '6 PM', 'slots': [
          {'status': 'available', 'playerName': 'Hafiz (P)'},
          {'status': 'free', 'playerName': null},
          {'status': 'booked', 'playerName': 'BOOKED'},
        ]},
      ],
      'upcomingBookings': [
        {'time': '8PM', 'sessionName': 'Friday Futsal', 'playerName': 'Azri', 'court': 'Court 1', 'isTentative': false},
      ],
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Nexus Futsal'), findsOneWidget);
    expect(find.text("TODAY'S BOOKINGS"), findsOneWidget);
    expect(find.text('EXPECTED REV'), findsOneWidget);
    expect(find.text('Court Availability · Today'), findsOneWidget);
    expect(find.text('Upcoming Bookings'), findsOneWidget);
    expect(find.text('Friday Futsal'), findsOneWidget);
    await controller.close();
  });
}
