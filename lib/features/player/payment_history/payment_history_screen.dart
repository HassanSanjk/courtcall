import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import 'payment_history_viewmodel.dart';

/// Payment History screen — shows all payments for the current player.
///
/// Features:
///   - KPI cards: Total Outstanding / Total Paid
///   - Filter tabs: All / Pending / Paid
///   - Payment list with mark-as-paid action
class PaymentHistoryScreen extends StatelessWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAsh,
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: AppColors.backgroundAsh,
        elevation: 0,
      ),
      body: const _PaymentHistoryBody(),
    );
  }
}

class _PaymentHistoryBody extends StatelessWidget {
  const _PaymentHistoryBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentHistoryViewModel>();

    if (vm.isLoading) {
      return const Center(
          child:
              CircularProgressIndicator(color: AppColors.primaryNavy));
    }

    return Column(
      children: [
        // ── KPI cards ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
          child: Row(
            children: [
              Expanded(
                child: KpiCard(
                  label: 'Outstanding',
                  value:
                      'RM ${vm.totalOutstanding.toStringAsFixed(2)}',
                  icon: Icons.pending_outlined,
                  valueColor: vm.hasOutstanding
                      ? AppColors.declined
                      : AppColors.accentGreen,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: KpiCard(
                  label: 'Total Paid',
                  value: 'RM ${vm.totalPaid.toStringAsFixed(2)}',
                  icon: Icons.check_circle_outline,
                  valueColor: AppColors.accentGreen,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Filter tabs ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md),
          child: Row(
            children: PaymentFilter.values.map((filter) {
              final isActive = vm.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () => vm.setFilter(filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primaryNavy
                          : AppColors.surfaceWhite,
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: isActive
                            ? AppColors.primaryNavy
                            : AppColors.divider,
                      ),
                    ),
                    child: Text(
                      _filterLabel(filter),
                      style: AppTextStyles.labelMedium.copyWith(
                        color: isActive
                            ? AppColors.surfaceWhite
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // ── Error banner ────────────────────────────────────────────
        if (vm.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0,
                AppSpacing.md, AppSpacing.md),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.declined.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.declined),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.declined, size: 16),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(vm.errorMessage!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.declined)),
                  ),
                  GestureDetector(
                    onTap: vm.clearError,
                    child: const Icon(Icons.close,
                        color: AppColors.declined, size: 16),
                  ),
                ],
              ),
            ),
          ),

        // ── Payment list ────────────────────────────────────────────
        Expanded(
          child: vm.filteredPayments.isEmpty
              ? Center(
                  child: Text(
                    'No payments here.',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md),
                  itemCount: vm.filteredPayments.length,
                  itemBuilder: (context, index) {
                    final payment = vm.filteredPayments[index];
                    return _PaymentCard(
                      payment: payment,
                      isMarkingPaid: vm.isMarkingPaid,
                      onMarkPaid: () =>
                          vm.markPaid(payment.paymentId),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _filterLabel(PaymentFilter filter) => switch (filter) {
        PaymentFilter.all     => 'All',
        PaymentFilter.paid    => 'Paid',
        PaymentFilter.pending => 'Pending',
      };
}

// ── Payment card ──────────────────────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.isMarkingPaid,
    required this.onMarkPaid,
  });

  final Payment payment;
  final bool isMarkingPaid;
  final VoidCallback onMarkPaid;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: payment.isPaid
                  ? AppColors.accentGreen.withValues(alpha: 0.1)
                  : AppColors.alertAmber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              payment.isPaid
                  ? Icons.check_circle_outline
                  : Icons.pending_outlined,
              color: payment.isPaid
                  ? AppColors.accentGreen
                  : AppColors.alertAmber,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.sessionName ?? 'Session',
                  style: AppTextStyles.titleMedium,
                ),
                if (payment.sessionDate != null)
                  Text(
                    payment.sessionDate!,
                    style: AppTextStyles.bodySmall,
                  ),
              ],
            ),
          ),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RM ${payment.amount.toStringAsFixed(2)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: payment.isPaid
                      ? AppColors.textPrimary
                      : AppColors.declined,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              if (payment.isUnpaid)
                GestureDetector(
                  onTap: isMarkingPaid ? null : onMarkPaid,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                    ),
                    child: isMarkingPaid
                        ? const SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.surfaceWhite,
                            ),
                          )
                        : Text(
                            'Pay Now',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.surfaceWhite,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                )
              else
                StatusPill(
                  label: 'Paid',
                  type: StatusPillType.confirmed,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
