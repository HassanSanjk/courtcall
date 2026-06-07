import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/repositories/mocks/mock_session_repository.dart';
import 'package:courtcall/features/organizer/cancellation/cancellation_viewmodel.dart';

void main() {
  late MockSessionRepository repo;
  late CancellationViewModel vm;

  setUp(() {
    repo = MockSessionRepository();
    vm = CancellationViewModel(repo: repo);
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
      await vm.confirmCancellation('session_1');
      expect(vm.isCancelling, isFalse);
    });

    test('confirmCancellation removes session from repository', () async {
      await vm.confirmCancellation('session_1');
      final sessions = await repo.watchUpcomingSessions('org_1').first;
      expect(sessions.any((s) => s.id == 'session_1'), isFalse);
    });

    test('errorMessage is null after successful cancellation', () async {
      await vm.confirmCancellation('session_1');
      expect(vm.errorMessage, isNull);
    });

    test('cancellation leaves other sessions intact', () async {
      await vm.confirmCancellation('session_1');
      final sessions = await repo.watchUpcomingSessions('org_1').first;
      expect(sessions.any((s) => s.id == 'session_2'), isTrue);
    });
  });
}
