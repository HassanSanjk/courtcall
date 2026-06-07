import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:courtcall/features/venue/cancellation_alert/cancellation_alert_screen.dart';
import 'package:courtcall/repositories/cancellation_repository.dart';

class MockCancellationRepository extends Mock implements CancellationRepository {}

Widget Function(Widget) testAppBuilder = (Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows loading then renders alert details', (tester) async {
    final repo = MockCancellationRepository();
    final controller = StreamController<Map<String, dynamic>>();
    when(() => repo.watchCancellationAlert(any())).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(
      testAppBuilder(CancellationAlertScreen(venueId: 'test_venue', repo: repo)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add({
      'slotId': 'slot_3',
      'sessionName': 'Friday Futsal',
      'organizerName': 'Azri',
      'court': 'Court 1',
      'timeRange': '8:00 PM – 10:00 PM',
      'dateLabel': '9 May 2026, Friday',
      'lostRevenue': 'RM 120',
      'depositCollected': 'RM 50 deposit was collected.',
      'noticeHours': 2,
      'history': [
        {'prefixText': 'Azri has cancelled ', 'highlightText': '3 times', 'suffixText': ' this month.', 'isWarning': true},
        {'prefixText': 'Azri has completed ', 'highlightText': '12 sessions', 'suffixText': ' successfully.', 'isWarning': false},
      ],
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Cancellation Alert'), findsOneWidget);
    expect(find.text('Late Cancellation'), findsOneWidget);
    expect(find.text('Friday Futsal'), findsOneWidget);
    expect(find.text('BOOKING DETAILS'), findsOneWidget);
    expect(find.text('LOST REVENUE'), findsOneWidget);
    expect(find.text('RM 120'), findsOneWidget);
    expect(find.text('Cancellation History'), findsOneWidget);
    expect(find.textContaining('Azri'), findsNWidgets(3));
    expect(find.text('Mark Slot Available'), findsOneWidget);
    expect(find.textContaining('Contact Organizer'), findsOneWidget);
    await controller.close();
  });
}
