import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/models.dart';
import 'payment_ledger_viewmodel.dart';

const Color _navy        = Color(0xFF1B2A4A);
const Color _accentGreen = Color(0xFF00E676);
const Color _alertAmber  = Color(0xFFFFA726);
const Color _bgAsh       = Color(0xFFF4F6F9);

class PaymentLedgerScreen extends StatelessWidget {
  const PaymentLedgerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PaymentLedgerViewModel>();

    if (vm.loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bgAsh,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _navy),
        title: const Text(
          'Session Payments',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              vm.exportSummary();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Summary exported')),
              );
            },
            child: const Text(
              'Export Summary',
              style: TextStyle(color: _accentGreen, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SummaryCard(
                    collected: vm.totalCollected,
                    owed: vm.totalOwed,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Player Ledger',
                        style: TextStyle(
                          color: _navy,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '${vm.playerCount} Players',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: vm.payments.length,
                    itemBuilder: (context, index) =>
                        _playerRow(vm.payments[index], vm),
                  ),
                ],
              ),
            ),
          ),
          _BottomSummaryCard(
            collected: vm.totalCollected,
            outstanding: vm.outstanding,
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  Widget _playerRow(Payment p, PaymentLedgerViewModel vm) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _navy,
            child: Text(
              _initials(p.playerName),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.playerName,
                  style: const TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'RM ${p.amount.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                ),
              ],
            ),
          ),
          _StatusPill(
            paid: p.status == 'paid',
            onTap: () => p.status == 'paid'
                ? vm.markAsUnpaid(p.paymentId)
                : vm.markAsPaid(p.paymentId),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool paid;
  final VoidCallback onTap;

  const _StatusPill({required this.paid, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: paid
              ? Colors.green.withValues(alpha: 0.15)
              : Colors.red.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          paid ? 'PAID' : 'UNPAID',
          style: TextStyle(
            color: paid ? Colors.green[700] : Colors.red[700],
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double collected;
  final double owed;
  const _SummaryCard({required this.collected, required this.owed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'COLLECTED',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'RM ${collected.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: _navy,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text: ' / RM ${owed.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: owed > 0 ? collected / owed : 0,
              minHeight: 10,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(_accentGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSummaryCard extends StatelessWidget {
  final double collected;
  final double outstanding;
  const _BottomSummaryCard({
    required this.collected,
    required this.outstanding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LedgerRow(
            label: 'Court Cost',
            value: 'RM ${PaymentLedgerViewModel.courtCost.toStringAsFixed(2)}',
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            valueStyle: const TextStyle(color: _navy, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _LedgerRow(
            label: 'Total Collected',
            value: 'RM ${collected.toStringAsFixed(2)}',
            labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
            valueStyle: const TextStyle(
              color: _accentGreen,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Divider(height: 20),
          _LedgerRow(
            label: 'Outstanding',
            value: 'RM ${outstanding.toStringAsFixed(2)}',
            labelStyle: const TextStyle(
              color: _navy,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            valueStyle: const TextStyle(
              color: _alertAmber,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _LedgerRow({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}
