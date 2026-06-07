import 'package:flutter_test/flutter_test.dart';
import 'mocks/mock_session_repository.dart';
import 'mocks/mock_payment_repository.dart';
import 'package:courtcall/features/organizer/dashboard/dashboard_viewmodel.dart';

void main() {
  late MockSessionRepository sessionRepo;
  late MockPaymentRepository paymentRepo;
  late DashboardViewModel vm;

  setUp(() {
    sessionRepo = MockSessionRepository();
    paymentRepo = MockPaymentRepository();
    vm = DashboardViewModel(
      sessionRepo: sessionRepo,
      paymentRepo: paymentRepo,
      organizerId: 'org_1',
    );
  });

  tearDown(() {
    vm.dispose();
    sessionRepo.dispose();
    paymentRepo.dispose();
  });

  group('DashboardViewModel —', () {
    test('loading is false after sessions arrive', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.loading, isFalse);
    });

    test('sessions is not empty after loading', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.sessions, isNotEmpty);
    });

    test('totalSessions equals sessions length', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.totalSessions, vm.sessions.length);
    });

    test('totalSessions matches mock data count', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.totalSessions, 3);
    });

    test('totalPlayers sums maxPlayers across all sessions', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      // session_1=10, session_2=4, session_3=8 → 22
      expect(vm.totalPlayers, 22);
    });

    test('unpaidCount reflects real unpaid payments across sessions', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      // mock has 3 unpaid payments for session_1; session_2/3 have none
      expect(vm.unpaidCount, 3);
    });

    test('sessions contain expected sport types', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final sports = vm.sessions.map((s) => s.sport).toSet();
      expect(sports, containsAll(['Futsal', 'Badminton']));
    });

    test('sessions have valid dates', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      for (final s in vm.sessions) {
        expect(s.date, isNotEmpty,
            reason: 'Session ${s.sessionId} has empty date');
      }
    });

    test('totalPlayers matches manual sum', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final expected = vm.sessions.fold(0, (sum, s) => sum + s.maxPlayers);
      expect(vm.totalPlayers, expected);
    });
  });
}
