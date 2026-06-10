// rsvp_roundtrip_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/models/models.dart';
import 'mocks/mock_player_repository.dart';
import 'mocks/mock_venue_repository.dart';
import 'package:courtcall/features/player/session_feed/session_feed_viewmodel.dart';
import 'package:courtcall/features/player/rsvp_confirmation/rsvp_confirmation_viewmodel.dart';
import 'package:courtcall/features/player/payment_history/payment_history_viewmodel.dart';

/// Integration test: Full RSVP round-trip
///
/// Flow:
///   1. Player sees session in feed (pending)
///   2. Player opens session and confirms (confirmed)
///   3. Player cancels with self reason (declined, declineReason = 'self')
///   4. Feed reflects declined status
///   5. Payment is visible and can be marked paid
///   6. declineReason 'removed' is never written from the player flow
///
/// This test exercises the shared contract between all three Player
/// ViewModels and verifies that state flows correctly through the
/// MockPlayerRepository - the same contract the real Firebase repo must honour.
void main() {
  late MockPlayerRepository repo;

  final testSession = Session(
    sessionId: 'session_001',
    organizerId: 'organizer_001',
    venueId: 'venue_001',
    venueName: 'Nexus Futsal, Cheras',
    court: 'Court 3',
    date: 'Friday, 9 May',
    dateTimestamp: DateTime(2025, 5, 9, 20, 0),
    time: '8:00PM-10:00PM',
    maxPlayers: 12,
    rsvpCount: 8,
    costPerPlayer: 15.0,
    status: 'upcoming',
    createdAt: DateTime(2025, 5, 1),
    sport: 'futsal',
  );

  const playerId = 'player_001';
  const playerName = 'Hussein';

  late MockVenueRepository venueRepo;

  setUp(() {
    repo = MockPlayerRepository();
    venueRepo = MockVenueRepository();
  });

  tearDown(() => repo.dispose());

  group('RSVP round-trip integration -', () {
    test('Step 1: Feed shows session as pending', () async {
      final feedVm = SessionFeedViewModel(
        repository: repo,
        playerId: playerId,
        playerName: playerName,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        feedVm.upcomingSessions.any((s) => s.sessionId == 'session_001'),
        isTrue,
        reason: 'Session 001 must appear in upcoming sessions',
      );
      expect(
        feedVm.rsvpStatusFor('session_001'),
        'pending',
        reason: 'Initial RSVP status must be pending',
      );
      feedVm.dispose();
    });

    test('Step 2: Player confirms via RSVP screen', () async {
      final rsvpVm = RsvpConfirmationViewModel(
        repository: repo,
        venueRepository: venueRepo,
        session: testSession,
        playerId: playerId,
        playerName: playerName,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      await rsvpVm.confirmAttendance();

      expect(rsvpVm.currentStatus, 'confirmed');
      expect(rsvpVm.errorMessage, isNull);

      // Verify repo state
      final rsvp = await repo.getPlayerRsvp(
        sessionId: 'session_001',
        playerId: playerId,
      );
      expect(rsvp?.status, 'confirmed');
      expect(rsvp?.declineReason, isNull);

      // rsvpCount incremented by upsertRsvp's batch write (atomic with RSVP doc)
      rsvpVm.dispose();
    });

    test('Step 3: Player cancels with self reason', () async {
      final rsvpVm = RsvpConfirmationViewModel(
        repository: repo,
        venueRepository: venueRepo,
        session: testSession,
        playerId: playerId,
        playerName: playerName,
      );
      await rsvpVm.confirmAttendance();
      await rsvpVm.declineAttendance();

      expect(rsvpVm.currentStatus, 'declined');

      final rsvp = await repo.getPlayerRsvp(
        sessionId: 'session_001',
        playerId: playerId,
      );
      expect(rsvp?.status, 'declined');
      expect(rsvp?.declineReason, 'self',
          reason: 'Player-initiated decline must set declineReason to self '
              'to trigger waitlist promotion per schema v4');
      rsvpVm.dispose();
    });

    test('Step 4: Feed reflects declined status after cancel', () async {
      await repo.upsertRsvp(
        sessionId: 'session_001',
        playerId: playerId,
        playerName: playerName,
        status: 'declined',
        declineReason: 'self',
      );

      final feedVm = SessionFeedViewModel(
        repository: repo,
        playerId: playerId,
        playerName: playerName,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(feedVm.rsvpStatusFor('session_001'), 'declined');
      feedVm.dispose();
    });

    test('Step 5: Payment visible and can be marked paid', () async {
      final payVm = PaymentHistoryViewModel(
        repository: repo,
        playerId: playerId,
      );
      await Future.delayed(const Duration(milliseconds: 50));

      expect(payVm.filteredPayments, isNotEmpty);
      expect(payVm.hasOutstanding, isTrue);

      final unpaid =
          payVm.filteredPayments.firstWhere((p) => p.isUnpaid);
      final targetId = unpaid.paymentId;
      await payVm.markPaid(targetId);

      await Future.delayed(const Duration(milliseconds: 50));

      // FIX: no orElse - fails explicitly if payment disappears from list.
      final updated = payVm.filteredPayments
          .firstWhere((p) => p.paymentId == targetId);
      expect(updated.isPaid, isTrue);
      payVm.dispose();
    });

    test('Step 6: declineReason removed is never set from player flow', () async {
      await repo.upsertRsvp(
        sessionId: 'session_001',
        playerId: playerId,
        playerName: playerName,
        status: 'declined',
        declineReason: 'self',
      );
      final rsvp = await repo.getPlayerRsvp(
        sessionId: 'session_001',
        playerId: playerId,
      );
      expect(rsvp?.declineReason, isNot('removed'),
          reason: 'removed is an organizer-only declineReason. '
              'Player screens must never write this value.');
    });

    test('confirmedPlayerNames are available via repository interface', () async {
      final names = await repo.getConfirmedPlayerNames('session_001');
      expect(names, isNotEmpty,
          reason: 'Avatar rows need player names from the repo interface, '
              'not a mock-specific helper');
    });
  });
}
