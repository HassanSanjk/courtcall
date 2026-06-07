import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../auth/auth_viewmodel.dart';
import 'payment_history_viewmodel.dart';

class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).maybePop(),
          splashRadius: 20,
        ),
        title: const Text('My Payments'),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.outline),
        ),
      ),
      body: ChangeNotifierProvider(
        create: (_) => PaymentHistoryViewModel(
          repository: context.read<PlayerRepository>(),
          playerId: playerId,
        ),
        child: _PaymentHistoryBody(),
      ),
    );
  }
}

class _PaymentHistoryBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentHistoryViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Outstanding card
          _OutstandingCard(
            amount: 'RM ${vm.totalOutstanding.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 16),

          // Error banner
          if (vm.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.redLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        vm.errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: vm.clearError,
                      child: const Icon(Icons.close,
                          color: AppColors.error, size: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Filter tabs
          _FilterTabs(
            selectedIndex: PaymentFilter.values.indexOf(vm.activeFilter),
            onChanged: (i) => vm.setFilter(PaymentFilter.values[i]),
          ),
          const SizedBox(height: 16),

          // Payment list
          if (vm.filteredPayments.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 40),
                child: Text(
                  'No payments here.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            )
          else
            ...vm.filteredPayments.map(
              (p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PaymentItem(
                  payment: p,
                  isMarkingPaid: vm.isMarkingPaid,
                  onMarkPaid: () => vm.markPaid(p.paymentId),
                ),
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─── Outstanding Card ────────────────────────────────────────────────────────

class _OutstandingCard extends StatelessWidget {
  final String amount;

  const _OutstandingCard({required this.amount});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      borderColor: AppColors.orangeBorder,
      borderWidth: 1.5,
      boxShadow: [
        BoxShadow(
          color: AppColors.orange.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'OUTSTANDING',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orange,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.orange,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Pay All — future enhancement
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Pay Now',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Tabs ─────────────────────────────────────────────────────────────

class _FilterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _FilterTabs({
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _FilterChip(
          label: 'All',
          index: 0,
          selected: selectedIndex == 0,
          onTap: onChanged,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Paid',
          index: 1,
          selected: selectedIndex == 1,
          onTap: onChanged,
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'Pending',
          index: 2,
          selected: selectedIndex == 2,
          onTap: onChanged,
          hasDot: true,
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final int index;
  final bool selected;
  final ValueChanged<int> onTap;
  final bool hasDot;

  const _FilterChip({
    required this.label,
    required this.index,
    required this.selected,
    required this.onTap,
    this.hasDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.darkNavy : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.darkNavy : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (hasDot) ...[
              const SizedBox(width: 6),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Payment Item ────────────────────────────────────────────────────────────

class _PaymentItem extends StatelessWidget {
  final Payment payment;
  final bool isMarkingPaid;
  final VoidCallback onMarkPaid;

  const _PaymentItem({
    required this.payment,
    required this.isMarkingPaid,
    required this.onMarkPaid,
  });

  bool get _isPending => payment.isUnpaid;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: _isPending ? AppColors.orangeBorder : AppColors.outline,
      borderWidth: _isPending ? 1.5 : 1,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isPending ? AppColors.orangeLight : AppColors.greenLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isPending
                  ? Icons.access_time_rounded
                  : Icons.check_circle_outline_rounded,
              color: _isPending ? AppColors.orange : AppColors.green,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.sessionName ?? 'Session',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (payment.sessionDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      payment.sessionDate!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${payment.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _isPending ? AppColors.error : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 5),
              _isPending
                  ? GestureDetector(
                      onTap: isMarkingPaid ? null : onMarkPaid,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.darkNavy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: isMarkingPaid
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Pay Now',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    )
                  : StatusBadge.paid(),
            ],
          ),
        ],
      ),
    );
  }
}
