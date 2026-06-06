// session_feed_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/models/models.dart';
import 'package:courtcall/repositories/mock_player_repository.dart';
import 'package:courtcall/features/player/session_feed/session_feed_viewmodel.dart';

void main() {
  late MockPlayerRepository repo;
  late SessionFeedViewModel vm;

  setUp(() {
    repo = MockPlayerRepository();
    vm = SessionFeedViewModel(
      repository: repo,
      playerId: 'player_001',
      playerName: 'Hussein',
    );
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  group('SessionFeedViewModel —', () {
    test('loads upcoming sessions on init', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.upcomingSessions, isNotEmpty);
    });

    test('separates upcoming from past sessions', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      for (final s in vm.upcomingSessions) {
        expect(s.status, 'upcoming');
      }
      for (final s in vm.pastSessions) {
        expect(s.status, isNot('upcoming'));
      }
    });

    test('confirmAttendance sets rsvp status to confirmed', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      const sessionId = 'session_001';

      await vm.confirmAttendance(sessionId);

      expect(vm.rsvpStatusFor(sessionId), 'confirmed');
    });

    test('declineAttendance sets rsvp status to declined', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      const sessionId = 'session_001';

      await vm.declineAttendance(sessionId);

      expect(vm.rsvpStatusFor(sessionId), 'declined');
    });

    test('declineAttendance passes declineReason self', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      const sessionId = 'session_001';

      await vm.declineAttendance(sessionId);

      final rsvp = await repo.getPlayerRsvp(
        sessionId: sessionId,
        playerId: 'player_001',
      );
      expect(rsvp?.declineReason, 'self');
    });

    test('session is not loading after action completes', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      const sessionId = 'session_001';

      await vm.confirmAttendance(sessionId);

      expect(vm.isSessionLoading(sessionId), false);
    });

    test('clearError removes error message', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      vm.clearError();
      expect(vm.errorMessage, isNull);
    });

    test('upcoming sessions sorted by dateTimestamp ascending', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final sessions = vm.upcomingSessions;
      for (int i = 1; i < sessions.length; i++) {
        expect(
          sessions[i].dateTimestamp
                  .isAfter(sessions[i - 1].dateTimestamp) ||
              sessions[i].dateTimestamp
                  .isAtSameMomentAs(sessions[i - 1].dateTimestamp),
          isTrue,
        );
      }
    });

    test('confirmedPlayerNamesFor returns names from repository', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final names = vm.confirmedPlayerNamesFor('session_001');
      expect(names, isNotEmpty);
    });
  });
}
