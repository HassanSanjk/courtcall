// payment_history_viewmodel_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/repositories/mock_player_repository.dart';
import 'package:courtcall/features/player/payment_history/payment_history_viewmodel.dart';

void main() {
  late MockPlayerRepository repo;
  late PaymentHistoryViewModel vm;

  setUp(() {
    repo = MockPlayerRepository();
    vm = PaymentHistoryViewModel(
      repository: repo,
      playerId: 'player_001',
    );
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  group('PaymentHistoryViewModel —', () {
    test('loads payments on init', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.filteredPayments, isNotEmpty);
    });

    test('default filter is all', () {
      expect(vm.activeFilter, PaymentFilter.all);
    });

    test('filter paid shows only paid payments', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      vm.setFilter(PaymentFilter.paid);
      for (final p in vm.filteredPayments) {
        expect(p.isPaid, isTrue);
      }
    });

    test('filter pending shows only unpaid payments', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      vm.setFilter(PaymentFilter.pending);
      for (final p in vm.filteredPayments) {
        expect(p.isUnpaid, isTrue);
      }
    });

    test('totalOutstanding sums only unpaid amounts', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      vm.setFilter(PaymentFilter.all);
      final expectedTotal = vm.filteredPayments
          .where((p) => p.isUnpaid)
          .fold(0.0, (sum, p) => sum + p.amount);
      expect(vm.totalOutstanding, expectedTotal);
    });

    test('hasOutstanding is true when unpaid payments exist', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.hasOutstanding, isTrue);
    });

    test('markPaid changes payment status to paid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final unpaid = vm.filteredPayments.firstWhere((p) => p.isUnpaid);
      final targetId = unpaid.paymentId;

      await vm.markPaid(targetId);
      await Future.delayed(const Duration(milliseconds: 50));

      // FIX: no orElse fallback — test fails explicitly if payment disappears.
      final updated = vm.filteredPayments
          .firstWhere((p) => p.paymentId == targetId);
      expect(updated.isPaid, isTrue);
    });

    test('isMarkingPaid is false after markPaid completes', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await vm.markPaid('pay_001');
      expect(vm.isMarkingPaid, false);
    });

    test('setFilter does not notify if same filter selected', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      int notifyCount = 0;
      vm.addListener(() => notifyCount++);
      vm.setFilter(PaymentFilter.all); // same as default
      expect(notifyCount, 0);
    });

    test('clearError removes error message', () {
      vm.clearError();
      expect(vm.errorMessage, isNull);
    });

    test('unpaid payments appear before paid in default sort', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final payments = vm.filteredPayments;
      bool seenPaid = false;
      for (final p in payments) {
        if (p.isPaid) seenPaid = true;
        if (seenPaid && p.isUnpaid) {
          fail('Unpaid payment appeared after a paid one — sort is wrong');
        }
      }
    });
  });
}
