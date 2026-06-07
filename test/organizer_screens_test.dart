import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:courtcall/models/models.dart';
import 'package:courtcall/repositories/session_repository.dart';
import 'package:courtcall/repositories/payment_repository.dart';
import 'mocks/mock_session_repository.dart';
import 'mocks/mock_payment_repository.dart';
import 'mocks/mock_rsvp_repository.dart';
import 'mocks/mock_venue_repository.dart';
import 'package:courtcall/repositories/venue_repository.dart';
import 'package:courtcall/repositories/auth_repository.dart';
import 'package:courtcall/features/auth/auth_viewmodel.dart';
import 'package:courtcall/features/organizer/dashboard/dashboard_screen.dart';
import 'package:courtcall/features/organizer/create_session/create_session_screen.dart';
import 'package:courtcall/features/organizer/create_session/create_session_viewmodel.dart';
import 'package:courtcall/features/organizer/rsvp_tracker/rsvp_tracker_screen.dart';
import 'package:courtcall/features/organizer/rsvp_tracker/rsvp_tracker_viewmodel.dart';
import 'package:courtcall/features/organizer/payment_ledger/payment_ledger_screen.dart';
import 'package:courtcall/features/organizer/payment_ledger/payment_ledger_viewmodel.dart';
import 'package:courtcall/features/organizer/cancellation/cancellation_screen.dart';
import 'package:courtcall/features/organizer/cancellation/cancellation_viewmodel.dart';

Widget wrapApp(Widget child) {
  return MaterialApp(home: child);
}

final mockSession = Session(
  sessionId: 'session_1',
  organizerId: 'org_1',
  venueId: 'v1',
  venueName: 'Nexus Futsal',
  court: 'Court 3',
  date: 'Friday, 9 May',
  dateTimestamp: DateTime(2026, 5, 9),
  time: '8:00 PM–10:00 PM',
  maxPlayers: 12,
  rsvpCount: 7,
  costPerPlayer: 15.0,
  status: 'upcoming',
  createdAt: DateTime(2026, 5, 1),
  sport: 'Futsal',
);

void main() {
  group('Organizer Dashboard', () {
    testWidgets('renders KPIs and session list', (tester) async {
      final sessionRepo = MockSessionRepository();
      final paymentRepo = MockPaymentRepository();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<SessionRepository>.value(value: sessionRepo),
            Provider<PaymentRepository>.value(value: paymentRepo),
            ChangeNotifierProvider(
              create: (_) => AuthViewModel(
                authRepository: MockAuthRepository(),
              ),
            ),
          ],
          child: wrapApp(const DashboardScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Dashboard shows the KPI row with session count
      expect(find.text('Upcoming'), findsOneWidget);
    });
  });

  group('Create Session', () {
    testWidgets('renders form with sport selector', (tester) async {
      final repo = MockSessionRepository();
      final venueRepo = MockVenueRepository();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<SessionRepository>.value(value: repo),
            Provider<VenueRepository>.value(value: venueRepo),
          ],
          child: wrapApp(
            ChangeNotifierProvider(
              create: (_) => CreateSessionViewModel(
                sessionRepo: repo,
                venueRepo: venueRepo,
                organizerId: 'org_1',
              ),
              child: const CreateSessionScreen(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('New Session'), findsOneWidget);
      expect(find.text('Futsal'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      expect(find.text('Create & Invite Squad'), findsOneWidget);
    });
  });

  group('RSVP Tracker', () {
    testWidgets('renders filter pills', (tester) async {
      final rsvpRepo = MockRsvpRepository();
      final paymentRepo = MockPaymentRepository();
      final sessionRepo = MockSessionRepository();
      await tester.pumpWidget(
        wrapApp(
          ChangeNotifierProvider(
            create: (_) => RsvpTrackerViewModel(
              rsvpRepo: rsvpRepo,
              paymentRepo: paymentRepo,
              sessionRepo: sessionRepo,
              session: mockSession,
            ),
            child: RsvpTrackerScreen(session: mockSession),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Going'), findsOneWidget);
      expect(find.textContaining('Maybe'), findsOneWidget);
      expect(find.textContaining('Out'), findsOneWidget);
    });
  });

  group('Payment Ledger', () {
    testWidgets('renders payment summary', (tester) async {
      final repo = MockPaymentRepository();
      await tester.pumpWidget(
        wrapApp(
          ChangeNotifierProvider(
            create: (_) => PaymentLedgerViewModel(
              paymentRepo: repo,
              sessionId: 'session_1',
            ),
            child: const PaymentLedgerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('COLLECTED'), findsOneWidget);
      expect(find.text('Player Ledger'), findsOneWidget);
    });
  });

  group('Cancel Session', () {
    testWidgets('renders cancel form with session details', (tester) async {
      final repo = MockSessionRepository();
      await tester.pumpWidget(
        wrapApp(
          ChangeNotifierProvider(
            create: (_) => CancellationViewModel(
              sessionRepo: repo,
              sessionId: 'session_1',
              session: mockSession,
            ),
            child: CancellationScreen(session: mockSession),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel Session'), findsOneWidget);
      expect(find.text('Confirm Cancellation'), findsOneWidget);
    });
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> get authStateChanges => Stream.value(null);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    return AppUser(uid: 'test_uid', name: 'Test', email: email, role: 'organizer');
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password, required String role}) async {
    return AppUser(uid: 'test_uid', name: name, email: email, role: role);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordReset(String email) async {}
}
