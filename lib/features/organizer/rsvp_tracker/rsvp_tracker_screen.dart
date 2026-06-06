import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../cancellation/cancellation_screen.dart';
import '../cancellation/cancellation_viewmodel.dart';
import '../payment_ledger/payment_ledger_screen.dart';
import '../payment_ledger/payment_ledger_viewmodel.dart';
import 'rsvp_tracker_viewmodel.dart';

const Color _navy        = Color(0xFF1B2A4A);
const Color _accentGreen = Color(0xFF00E676);
const Color _alertAmber  = Color(0xFFFFA726);
const Color _bgAsh       = Color(0xFFF4F6F9);

class RsvpTrackerScreen extends StatelessWidget {
  const RsvpTrackerScreen({super.key});

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _filterPill(
    BuildContext context,
    RsvpTrackerViewModel vm,
    String label,
    String filterValue,
  ) {
    final selected = vm.selectedFilter == filterValue;
    return GestureDetector(
      onTap: () => vm.setFilter(filterValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _navy : const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : _navy,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _playerRow(PlayerRsvp p) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 10),
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
              p.initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              p.name,
              style: const TextStyle(
                color: _navy,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          _PaymentPill(paid: p.paid, status: p.status),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RsvpTrackerViewModel>();

    return Scaffold(
      backgroundColor: _bgAsh,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _navy),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Friday Futsal · 9 May',
              style: TextStyle(
                color: _navy,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              'Nexus Futsal Court 3 · 8PM',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.payments_outlined, color: _navy),
            tooltip: 'View Payments',
            onPressed: () => _openPaymentLedger(context),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter pills
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _filterPill(context, vm, 'Going (${vm.goingCount})', 'going'),
                const SizedBox(width: 10),
                _filterPill(context, vm, 'Maybe (${vm.maybeCount})', 'maybe'),
                const SizedBox(width: 10),
                _filterPill(context, vm, 'Out (${vm.outCount})', 'out'),
              ],
            ),
          ),

          // Player list
          Expanded(
            child: ListView.builder(
              itemCount: vm.visiblePlayers.length,
              itemBuilder: (context, index) =>
                  _playerRow(vm.visiblePlayers[index]),
            ),
          ),

          // Share invite link
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  vm.shareInviteLink();
                  _showSnackBar(context, 'Invite link copied to clipboard');
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share Invite Link'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _navy,
                  side: const BorderSide(color: _navy),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),

          // Pinned bottom bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _openCancellation(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancel Session',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      vm.sendReminder();
                      _showSnackBar(context, 'Reminder sent to unpaid players');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _navy,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Reminder',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openCancellation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CancellationViewModel(),
          child: const CancellationScreen(),
        ),
      ),
    );
  }

  void _openPaymentLedger(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => PaymentLedgerViewModel(),
          child: const PaymentLedgerScreen(),
        ),
      ),
    );
  }
}

class _PaymentPill extends StatelessWidget {
  final bool paid;
  final String status;
  const _PaymentPill({required this.paid, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status != 'going' && !paid) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: paid
            ? _accentGreen.withValues(alpha: 0.15)
            : _alertAmber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        paid ? 'PAID RM15' : 'UNPAID',
        style: TextStyle(
          color: paid ? Colors.green[700] : Colors.orange[800],
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }
}
