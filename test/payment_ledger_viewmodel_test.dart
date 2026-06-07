import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/repositories/mocks/mock_payment_repository.dart';
import 'package:courtcall/features/organizer/payment_ledger/payment_ledger_viewmodel.dart';

void main() {
  late MockPaymentRepository repo;
  late PaymentLedgerViewModel vm;

  setUp(() {
    repo = MockPaymentRepository();
    vm = PaymentLedgerViewModel(repo: repo, sessionId: 'session_1');
  });

  tearDown(() {
    vm.dispose();
    repo.dispose();
  });

  group('PaymentLedgerViewModel —', () {
    test('loads payments on init', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.payments, isNotEmpty);
    });

    test('loading is false after payments arrive', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.loading, isFalse);
    });

    test('playerCount equals number of payments', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.playerCount, 8);
    });

    test('totalCollected sums only paid payments', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      // Mock: pay_1, pay_3, pay_5, pay_6, pay_7 are paid — 5 × RM 15
      expect(vm.totalCollected, 75.0);
    });

    test('totalOwed sums all payments', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      // 8 players × RM 15
      expect(vm.totalOwed, 120.0);
    });

    test('outstanding equals totalOwed minus totalCollected', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      // 3 unpaid × RM 15 = 45
      expect(vm.outstanding, 45.0);
    });

    test('outstanding matches computed difference', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.outstanding, vm.totalOwed - vm.totalCollected);
    });

    test('markAsPaid changes payment status to paid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await vm.markAsPaid('pay_2'); // pay_2 starts unpaid
      await Future.delayed(const Duration(milliseconds: 50));

      final updated = vm.payments.firstWhere((p) => p.id == 'pay_2');
      expect(updated.paid, isTrue);
    });

    test('markAsUnpaid changes payment status to unpaid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      await vm.markAsUnpaid('pay_1'); // pay_1 starts paid
      await Future.delayed(const Duration(milliseconds: 50));

      final updated = vm.payments.firstWhere((p) => p.id == 'pay_1');
      expect(updated.paid, isFalse);
    });

    test('totalCollected increases after markAsPaid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final before = vm.totalCollected;
      await vm.markAsPaid('pay_4'); // pay_4 starts unpaid
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.totalCollected, before + 15.0);
    });

    test('outstanding decreases after markAsPaid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final before = vm.outstanding;
      await vm.markAsPaid('pay_8'); // pay_8 starts unpaid
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.outstanding, before - 15.0);
    });

    test('totalCollected decreases after markAsUnpaid', () async {
      await Future.delayed(const Duration(milliseconds: 50));
      final before = vm.totalCollected;
      await vm.markAsUnpaid('pay_3'); // pay_3 starts paid
      await Future.delayed(const Duration(milliseconds: 50));
      expect(vm.totalCollected, before - 15.0);
    });
  });
}
