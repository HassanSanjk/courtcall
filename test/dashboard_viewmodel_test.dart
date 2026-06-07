import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/repositories/mocks/mock_session_repository.dart';
import 'package:courtcall/features/organizer/dashboard/dashboard_viewmodel.dart';

void main() {
  late MockSessionRepository repo;
  late DashboardViewModel vm;

  setUp(() {
    repo = MockSessionRepository();
    vm = DashboardViewModel(repo: repo);
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
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

    test('unpaidCount is 0 pending Firebase integration', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.unpaidCount, 0);
    });

    test('sessions contain expected sport types', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final sports = vm.sessions.map((s) => s.sport).toSet();
      expect(sports, containsAll(['Futsal', 'Badminton']));
    });

    test('sessions have valid dates in YYYY-MM-DD format', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
      for (final s in vm.sessions) {
        expect(datePattern.hasMatch(s.date), isTrue,
            reason: 'Session ${s.id} has invalid date: ${s.date}');
      }
    });

    test('totalPlayers matches manual sum', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final expected = vm.sessions.fold(0, (sum, s) => sum + s.maxPlayers);
      expect(vm.totalPlayers, expected);
    });
  });
}
