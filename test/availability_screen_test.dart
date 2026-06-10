import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:courtcall/features/venue/availability/availability_screen.dart';
import 'package:courtcall/repositories/availability_repository.dart';

class MockAvailabilityRepository extends Mock implements AvailabilityRepository {}

Widget Function(Widget) testAppBuilder = (Widget child) => MaterialApp(home: child);

void main() {
  testWidgets('shows loading then renders slots', (tester) async {
    final repo = MockAvailabilityRepository();
    final controller = StreamController<List<dynamic>>();
    when(() => repo.watchSlots(any(), any())).thenAnswer((_) => controller.stream);

    await tester.pumpWidget(
      testAppBuilder(AvailabilityScreen(venueId: 'test_venue', courts: ['Court 1', 'Court 2'], repo: repo)),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    controller.add([
      {'id': 'slot_1', 'courtIndex': 0, 'date': '2026-05-09', 'dateLabel': 'Friday, 9 May', 'isToday': true, 'timeLabel': '6:00 PM', 'status': 'available', 'isEnabled': true},
      {'id': 'slot_2', 'courtIndex': 0, 'date': '2026-05-09', 'dateLabel': 'Friday, 9 May', 'isToday': true, 'timeLabel': '7:00 PM', 'status': 'available', 'isEnabled': true},
      {'id': 'slot_4', 'courtIndex': 0, 'date': '2026-05-09', 'dateLabel': 'Friday, 9 May', 'isToday': true, 'timeLabel': '9:00 PM', 'status': 'booked', 'isEnabled': false},
    ]);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Manage Courts'), findsOneWidget);
    expect(find.text('6:00 PM'), findsOneWidget);
    expect(find.text('7:00 PM'), findsOneWidget);
    expect(find.text('BOOKED'), findsOneWidget);
    await controller.close();
  });
}
