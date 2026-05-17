// features/venue/cancellation_alert/cancellation_alert_screen.dart

import 'package:flutter/material.dart';
import 'cancellation_alert_viewmodel.dart';

class CancellationAlertScreen extends StatefulWidget {
  const CancellationAlertScreen({super.key});

  @override
  State<CancellationAlertScreen> createState() =>
      _CancellationAlertScreenState();
}

class _CancellationAlertScreenState extends State<CancellationAlertScreen> {
  late final CancellationAlertViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = CancellationAlertViewModel();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildHeroHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        _buildBookingDetailsCard(),
                        const SizedBox(height: 16),
                        _buildLostRevenueCard(),
                        const SizedBox(height: 16),
                        _buildOrganizerRow(),
                        const SizedBox(height: 16),
                        _buildCancellationHistory(),
                        const SizedBox(height: 24),
                        _buildActionButtons(),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  // ─── Hero Header ───────────────────────────────────────────────────────────

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD92B2B),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Back button row
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Cancellation Alert',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Hero content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Late Cancellation',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _viewModel.noticeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.75),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Booking Details Card ──────────────────────────────────────────────────

  Widget _buildBookingDetailsCard() {
    final alert = _viewModel.alert!;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BOOKING DETAILS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            alert.sessionName,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'Organizer', value: alert.organizerName),
          _DetailRow(label: 'Court', value: alert.court),
          _DetailRow(label: 'Time', value: alert.timeRange),
          _DetailRow(label: 'Date', value: alert.dateLabel),
        ],
      ),
    );
  }

  // ─── Lost Revenue Card ─────────────────────────────────────────────────────

  Widget _buildLostRevenueCard() {
    final alert = _viewModel.alert!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBB040).withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'LOST REVENUE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD97706),
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            alert.lostRevenue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
          if (alert.depositCollected != null) ...[
            const SizedBox(height: 4),
            Text(
              alert.depositCollected!,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Organizer Row ─────────────────────────────────────────────────────────

  Widget _buildOrganizerRow() {
    final alert = _viewModel.alert!;
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1A1A2E),
            child: Text(
              alert.organizerName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                alert.organizerName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Text(
                'Organizer',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Cancellation History ──────────────────────────────────────────────────

  Widget _buildCancellationHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cancellation History',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 10),
        ..._viewModel.cancellationHistory.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: item.isWarning
                          ? const Color(0xFFFBB040)
                          : const Color(0xFF0D7A3E),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280),
                      ),
                      children: [
                        TextSpan(text: item.prefixText),
                        TextSpan(
                          text: item.highlightText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        TextSpan(text: item.suffixText),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Action Buttons ────────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _viewModel.isMarkingAvailable
                ? null
                : _viewModel.markSlotAvailable,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A2E),
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: _viewModel.isMarkingAvailable
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text(
                    'Mark Slot Available',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: _viewModel.contactOrganizer,
            icon: const Icon(Icons.phone_outlined,
                size: 18, color: Color(0xFF1A1A2E)),
            label: Text(
              'Contact Organizer (${_viewModel.alert?.organizerName ?? ''})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A1A2E), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }
}