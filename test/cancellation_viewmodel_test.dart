import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/models/models.dart';
import 'mocks/mock_session_repository.dart';
import 'package:courtcall/features/organizer/cancellation/cancellation_viewmodel.dart';

void main() {
  late MockSessionRepository repo;
  late CancellationViewModel vm;
  final mockSession = Session(
    sessionId: 'session_1',
    organizerId: 'org_1',
    venueId: 'v1',
    venueName: 'Test Venue',
    court: 'Court 1',
    date: '2026-05-19',
    dateTimestamp: DateTime(2026, 5, 19),
    time: '8:00 PM–10:00 PM',
    maxPlayers: 10,
    rsvpCount: 5,
    costPerPlayer: 15.0,
    status: 'upcoming',
    createdAt: DateTime(2026, 5, 10),
    sport: 'Futsal',
  );

  setUp(() {
    repo = MockSessionRepository();
    vm = CancellationViewModel(
      sessionRepo: repo,
      sessionId: 'session_1',
      session: mockSession,
    );
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  group('CancellationViewModel —', () {
    test('default reason is Court unavailable', () {
      expect(vm.selectedReason, 'Court unavailable');
    });

    test('default notifyPlayers is true', () {
      expect(vm.notifyPlayers, isTrue);
    });

    test('default isCancelling is false', () {
      expect(vm.isCancelling, isFalse);
    });

    test('default errorMessage is null', () {
      expect(vm.errorMessage, isNull);
    });

    test('reasons list has 4 items', () {
      expect(CancellationViewModel.reasons.length, 4);
    });

    test('reasons list contains all expected options', () {
      expect(CancellationViewModel.reasons, containsAll([
        'Court unavailable',
        'Not enough players',
        'Weather conditions',
        'Other',
      ]));
    });

    test('setReason changes selectedReason', () {
      vm.setReason('Weather conditions');
      expect(vm.selectedReason, 'Weather conditions');
    });

    test('setReason notifies listeners', () {
      int count = 0;
      vm.addListener(() => count++);
      vm.setReason('Other');
      expect(count, 1);
    });

    test('setNotify changes notifyPlayers to false', () {
      vm.setNotify(false);
      expect(vm.notifyPlayers, isFalse);
    });

    test('setNotify notifies listeners', () {
      int count = 0;
      vm.addListener(() => count++);
      vm.setNotify(false);
      expect(count, 1);
    });

    test('previewMessage contains the selected reason in lowercase', () {
      vm.setReason('Weather conditions');
      expect(vm.previewMessage, contains('weather conditions'));
    });

    test('previewMessage updates when reason changes', () {
      vm.setReason('Not enough players');
      expect(vm.previewMessage, contains('not enough players'));
      expect(vm.previewMessage, isNot(contains('court unavailable')));
    });

    test('isCancelling is false after confirmCancellation completes', () async {
      await vm.confirmCancellation();
      expect(vm.isCancelling, isFalse);
    });

    test('confirmCancellation removes session from repository', () async {
      await vm.confirmCancellation();
      final sessions = await repo.watchUpcomingSessions('org_1').first;
      expect(sessions.any((s) => s.sessionId == 'session_1'), isFalse);
    });

    test('errorMessage is null after successful cancellation', () async {
      await vm.confirmCancellation();
      expect(vm.errorMessage, isNull);
    });

    test('cancellation leaves other sessions intact', () async {
      await vm.confirmCancellation();
      final sessions = await repo.watchUpcomingSessions('org_1').first;
      expect(sessions.any((s) => s.sessionId == 'session_2'), isTrue);
    });
  });
}
