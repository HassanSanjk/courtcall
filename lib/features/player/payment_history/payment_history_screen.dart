import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../auth/auth_viewmodel.dart';
import 'payment_history_viewmodel.dart';

/// Payment History screen — shows all payments for the current player.
///
/// Features:
///   - KPI cards: Total Outstanding / Total Paid
///   - Filter tabs: All / Pending / Paid
///   - Payment list with mark-as-paid action
class PaymentHistoryScreen extends StatelessWidget {
  PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('Payments'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
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
  _PaymentHistoryBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentHistoryViewModel>();

    if (vm.isLoading) {
      return Center(
          child:
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final pad = isWide ? 32.0 : 16.0;

        return Column(
          children: [
            // ── KPI cards ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(pad, 16.0, pad, 0),
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      label: 'Outstanding',
                      value:
                          'RM ${vm.totalOutstanding.toStringAsFixed(2)}',
                      icon: Icons.pending_outlined,
                      accentColor: vm.hasOutstanding
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                  SizedBox(width: isWide ? 24.0 : 16.0),
                  Expanded(
                    child: KpiCard(
                      label: 'Total Paid',
                      value: 'RM ${vm.totalPaid.toStringAsFixed(2)}',
                      icon: Icons.check_circle_outline,
                      accentColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),

        // ── Filter tabs ─────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 16.0),
          child: Row(
            children: PaymentFilter.values.map((filter) {
              final isActive = vm.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GestureDetector(
                  onTap: () => vm.setFilter(filter),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius:
                          BorderRadius.circular(100.0),
                      border: Border.all(
                        color: isActive
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      _filterLabel(filter),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: isActive
                            ? Theme.of(context).colorScheme.surface
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 16.0),

        // ── Error banner ────────────────────────────────────────────
        if (vm.errorMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0,
                16.0, 16.0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Theme.of(context).colorScheme.error),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline,
                      color: Theme.of(context).colorScheme.error, size: 16),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(vm.errorMessage!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
                  ),
                  GestureDetector(
                    onTap: vm.clearError,
                    child: Icon(Icons.close,
                        color: Theme.of(context).colorScheme.error, size: 16),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: pad),
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
      },
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
  _PaymentCard({
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
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: payment.isPaid
                  ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
                  : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(
              payment.isPaid
                  ? Icons.check_circle_outline
                  : Icons.pending_outlined,
              color: payment.isPaid
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).colorScheme.tertiary,
              size: 22,
            ),
          ),
          SizedBox(width: 16.0),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.sessionName ?? 'Session',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (payment.sessionDate != null)
                  Text(
                    payment.sessionDate!,
                    style: Theme.of(context).textTheme.bodySmall,
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: payment.isPaid
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).colorScheme.error,
                ),
              ),
              SizedBox(height: 4.0),
              if (payment.isUnpaid)
                GestureDetector(
                  onTap: isMarkingPaid ? null : onMarkPaid,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius:
                          BorderRadius.circular(100.0),
                    ),
                    child: isMarkingPaid
                        ? SizedBox(
                            height: 12,
                            width: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          )
                        : Text(
                            'Pay Now',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                )
              else
                StatusPill(
                  label: 'Paid',
                  status: PillStatus.paid,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
