import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cancellation_viewmodel.dart';

class CancellationScreen extends StatelessWidget {
  const CancellationScreen({super.key});

  static const Color _navy = Color(0xFF1B2A4A);
  static const Color _accentGreen = Color(0xFF00E676);
  static const Color _backgroundAsh = Color(0xFFF4F6F9);

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CancellationViewModel>();

    return Scaffold(
      backgroundColor: _backgroundAsh,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _navy),
        title: const Text(
          'Cancel Session',
          style: TextStyle(
            color: _navy,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WarningBanner(),
            const SizedBox(height: 20),
            _SessionSummaryCard(),
            const SizedBox(height: 20),
            _ReasonDropdown(
              selectedReason: vm.selectedReason,
              reasons: CancellationViewModel.reasons,
              onChanged: (value) {
                if (value != null) vm.setReason(value);
              },
            ),
            const SizedBox(height: 16),
            _NotifyCard(
              notifyPlayers: vm.notifyPlayers,
              previewMessage: vm.previewMessage,
              accentGreen: _accentGreen,
              onToggle: vm.setNotify,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isCancelling
                    ? null
                    : () => _onConfirm(context, vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE53935),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: vm.isCancelling
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Confirm Cancellation',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Go Back',
                  style: TextStyle(
                    color: _navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _onConfirm(
      BuildContext context, CancellationViewModel vm) async {
    await vm.confirmCancellation('session_1');
    if (!context.mounted) return;
    if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session cancelled successfully')),
      );
      Navigator.pop(context);
    }
  }
}

class _WarningBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFA726),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFF7A4F00),
            size: 22,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'You are about to cancel this session. This action cannot be undone.',
              style: TextStyle(
                color: Color(0xFF7A4F00),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Friday Futsal',
            style: TextStyle(
              color: Color(0xFF1B2A4A),
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Nexus Futsal Court 3',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
          SizedBox(height: 2),
          Text(
            '9 May · 8:00 PM',
            style: TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _ReasonDropdown extends StatelessWidget {
  final String selectedReason;
  final List<String> reasons;
  final ValueChanged<String?> onChanged;

  const _ReasonDropdown({
    required this.selectedReason,
    required this.reasons,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reason for Cancellation',
          style: TextStyle(
            color: Color(0xFF1B2A4A),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedReason,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down,
                  color: Color(0xFF1B2A4A)),
              style: const TextStyle(
                color: Color(0xFF1B2A4A),
                fontSize: 14,
              ),
              onChanged: onChanged,
              items: reasons
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotifyCard extends StatelessWidget {
  final bool notifyPlayers;
  final String previewMessage;
  final Color accentGreen;
  final ValueChanged<bool> onToggle;

  const _NotifyCard({
    required this.notifyPlayers,
    required this.previewMessage,
    required this.accentGreen,
    required this.onToggle,
  });

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
                'Notify confirmed players',
                style: TextStyle(
                  color: Color(0xFF1B2A4A),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              Switch(
                value: notifyPlayers,
                activeThumbColor: accentGreen,
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: notifyPlayers
                ? _PreviewText(message: previewMessage)
                : const Text(
                    'Players will not be notified.',
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _PreviewText extends StatelessWidget {
  final String message;
  const _PreviewText({required this.message});

  @override
  Widget build(BuildContext context) {
    const String boldPart = 'CourtCall:';
    final String rest = message.substring(boldPart.length);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: Color(0xFF1B2A4A),
          fontSize: 13,
          height: 1.5,
        ),
        children: [
          const TextSpan(
            text: boldPart,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: rest),
        ],
      ),
    );
  }
}
