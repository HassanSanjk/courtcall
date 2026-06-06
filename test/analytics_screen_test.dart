import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:courtcall/features/venue/analytics/analytics_screen.dart';
import 'package:courtcall/repositories/analytics_repository.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

Widget Function(Widget) testAppBuilder = (Widget child) => MaterialApp.router(
  routerConfig: GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => child),
    ],
  ),
);

void main() {
  testWidgets('shows loading then renders analytics', (tester) async {
    final repo = MockAnalyticsRepository();
    final controller = StreamController<Map<String, dynamic>>();
    when(() => repo.watchAnalytics(any(), any())).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(
      testAppBuilder(AnalyticsScreen(venueId: 'test_venue', repo: repo)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add({
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
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Revenue Analytics'), findsOneWidget);
    expect(find.text('RM 4,500'), findsOneWidget);
    expect(find.text("THIS WEEK'S REVENUE"), findsOneWidget);
    expect(find.text('SESSIONS'), findsOneWidget);
    expect(find.text('CANCELLED'), findsOneWidget);
    expect(find.text('NO-SHOW'), findsOneWidget);
    expect(find.text('Top Organizers'), findsOneWidget);
    expect(find.text('Azri'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('This Month'), findsOneWidget);
    expect(find.text('All Time'), findsOneWidget);
    await controller.close();
  });
}
