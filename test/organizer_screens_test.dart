import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:courtcall/features/organizer/dashboard/dashboard_screen.dart';
import 'package:courtcall/features/organizer/create_session/create_session_screen.dart';
import 'package:courtcall/features/organizer/rsvp_tracker/rsvp_tracker_screen.dart';
import 'package:courtcall/features/organizer/payment_ledger/payment_ledger_screen.dart';
import 'package:courtcall/features/organizer/cancellation/cancellation_screen.dart';

Widget wrapApp(Widget child) {
  return MaterialApp(home: child);
}

void main() {
  group('Organizer Dashboard', () {
    testWidgets('renders session card and action buttons', (tester) async {
      await tester.pumpWidget(wrapApp(const DashboardScreen()));

      expect(find.text('CourtCall'), findsOneWidget);
      expect(find.text('Nexus Futsal \u2014 Court 3'), findsOneWidget);
      expect(find.text('Create\nSession'), findsOneWidget);
      expect(find.text('RSVP\nTracker'), findsOneWidget);
      expect(find.text('Payment\nLedger'), findsOneWidget);
      expect(find.text('Cancel\nSession'), findsOneWidget);
    });

    testWidgets('shows RSVP progress bar', (tester) async {
      await tester.pumpWidget(wrapApp(const DashboardScreen()));

      expect(find.text('RSVP Progress'), findsOneWidget);
      expect(find.text('9 of 12'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
  });

  group('Create Session', () {
    testWidgets('renders form with all fields', (tester) async {
      await tester.pumpWidget(wrapApp(const CreateSessionScreen()));

      expect(find.text('New Session'), findsOneWidget);
      expect(find.text('SPORT'), findsOneWidget);
      expect(find.text('VENUE'), findsOneWidget);
      expect(find.text('DATE'), findsOneWidget);
      expect(find.text('TIME'), findsOneWidget);
      expect(find.text('MAX PLAYERS'), findsOneWidget);
      expect(find.text('COST PER PLAYER (RM)'), findsOneWidget);
      expect(find.text('NOTES (OPTIONAL)'), findsOneWidget);
      expect(find.text('Create Session'), findsOneWidget);
    });

    testWidgets('shows 2 players minimum', (tester) async {
      await tester.pumpWidget(wrapApp(const CreateSessionScreen()));

      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('sport dropdown defaults to Futsal', (tester) async {
      await tester.pumpWidget(wrapApp(const CreateSessionScreen()));

      expect(find.text('Futsal'), findsOneWidget);
    });
  });

  group('RSVP Tracker', () {
    testWidgets('renders player list with status badges', (tester) async {
      await tester.pumpWidget(wrapApp(const RsvpTrackerScreen()));

      expect(find.text('RSVP Tracker'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
      expect(find.text('Ali Hassan'), findsOneWidget);
      expect(find.text('Sarah Lim'), findsOneWidget);
      expect(find.text('Mike Chen'), findsOneWidget);
    });

    testWidgets('shows correct stat counts', (tester) async {
      await tester.pumpWidget(wrapApp(const RsvpTrackerScreen()));

      expect(find.text('5'), findsOneWidget);   // confirmed
      expect(find.text('3'), findsOneWidget);   // pending
      expect(find.text('9'), findsOneWidget);   // total
    });
  });

  group('Payment Ledger', () {
    testWidgets('renders payment list with amounts', (tester) async {
      await tester.pumpWidget(wrapApp(const PaymentLedgerScreen()));

      expect(find.text('Payment Ledger'), findsOneWidget);
      expect(find.text('COLLECTED'), findsOneWidget);
      expect(find.text('OUTSTANDING'), findsOneWidget);
      expect(find.text('RM 75.00'), findsOneWidget);
      expect(find.text('RM 45.00'), findsOneWidget);
      expect(find.text('Ali Hassan'), findsOneWidget);
      expect(find.text('Sarah Lim'), findsOneWidget);
    });

    testWidgets('shows PAID and PENDING badges', (tester) async {
      await tester.pumpWidget(wrapApp(const PaymentLedgerScreen()));

      expect(find.text('PAID'), findsWidgets);
      expect(find.text('PENDING'), findsWidgets);
    });
  });

  group('Cancel Session', () {
    testWidgets('renders session cards with cancel buttons', (tester) async {
      await tester.pumpWidget(wrapApp(const CancellationScreen()));

      expect(find.text('Cancel Session'), findsWidgets);
      expect(find.text('FUTSAL'), findsOneWidget);
      expect(find.text('Nexus \u2014 Court 3'), findsOneWidget);
      expect(find.text('BADMINTON'), findsOneWidget);
      expect(find.text('BASKETBALL'), findsOneWidget);
    });

    testWidgets('tapping cancel shows confirmation dialog', (tester) async {
      await tester.pumpWidget(wrapApp(const CancellationScreen()));

      final cancelButtons = find.text('Cancel Session');
      await tester.tap(cancelButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Cancel Session?'), findsOneWidget);
      expect(find.text('Keep Session'), findsOneWidget);
      expect(find.text('Yes, Cancel'), findsOneWidget);
    });
  });
}
