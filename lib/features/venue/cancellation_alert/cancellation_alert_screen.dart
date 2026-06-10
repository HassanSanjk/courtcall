

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:courtcall/core/theme/app_colors.dart';
import 'package:courtcall/repositories/cancellation_repository.dart';
import 'package:courtcall/repositories/firebase/firebase_cancellation_repository.dart';
import 'cancellation_alert_viewmodel.dart';

class CancellationAlertScreen extends StatelessWidget {
  final String venueId;

  const CancellationAlertScreen({super.key, required this.venueId, this.repo});

  final CancellationRepository? repo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CancellationAlertViewModel(
        repo: repo ?? FirebaseCancellationRepository(),
        venueId: venueId,
      ),
      child: _CancellationAlertBody(venueId: venueId),
    );
  }
}

class _CancellationAlertBody extends StatelessWidget {
  final String venueId;

  const _CancellationAlertBody({required this.venueId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CancellationAlertViewModel>();
    final alert = vm.alert;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 420;
                final pad = isWide ? 24.0 : 16.0;
                return Column(
                  children: [
                    _buildHeroHeader(context, vm),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(pad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBookingDetailsCard(alert),
                            const SizedBox(height: 16),
                            _buildLostRevenueCard(alert),
                            const SizedBox(height: 16),
                            _buildOrganizerRow(alert),
                            const SizedBox(height: 16),
                            _buildCancellationHistory(vm),
                            const SizedBox(height: 24),
                            _buildActionButtons(alert, vm),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildHeroHeader(BuildContext context, CancellationAlertViewModel vm) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFD92B2B),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('Cancellation Alert',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              child: Column(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.warning_amber_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text('Late Cancellation',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 4),
                  Text(vm.noticeLabel,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.75),
                          letterSpacing: 1.2)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetailsCard(Map<String, dynamic> alert) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BOOKING DETAILS',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 0.8)),
          const SizedBox(height: 12),
          Text('${alert['sessionName']}',
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface)),
          const SizedBox(height: 10),
          _DetailRow(label: 'Organizer', value: '${alert['organizerName']}'),
          _DetailRow(label: 'Court', value: '${alert['court']}'),
          _DetailRow(label: 'Time', value: '${alert['timeRange']}'),
          _DetailRow(label: 'Date', value: '${alert['dateLabel']}'),
        ],
      ),
    );
  }

  Widget _buildLostRevenueCard(Map<String, dynamic> alert) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LOST REVENUE',
              style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  letterSpacing: 0.8)),
          const SizedBox(height: 6),
          Text('${alert['lostRevenue']}',
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface)),
          if (alert['depositCollected'] != null) ...[
            const SizedBox(height: 4),
            Text('${alert['depositCollected']}',
                style: const TextStyle(
                    fontSize: 12, color: AppColors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }

  Widget _buildOrganizerRow(Map<String, dynamic> alert) {
    final name = '${alert['organizerName'] ?? ''}';
    if (name.isEmpty) return const SizedBox.shrink();
    return _Card(
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF1A1A2E),
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface)),
              const Text('Organizer',
                  style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationHistory(CancellationAlertViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Cancellation History',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface)),
        const SizedBox(height: 10),
        ...vm.history.map((item) {
          final h = (item as Map).cast<String, dynamic>();
          return Padding(
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
                      color: h['isWarning'] == true
                          ? AppColors.amber
                          : AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.onSurfaceVariant),
                      children: [
                        TextSpan(text: '${h['prefixText']}'),
                        TextSpan(
                          text: '${h['highlightText']}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface),
                        ),
                        TextSpan(text: '${h['suffixText']}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> alert, CancellationAlertViewModel vm) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: vm.isMarkingAvailable
                ? null
                : vm.markSlotAvailable,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: vm.isMarkingAvailable
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: AppColors.onPrimary, strokeWidth: 2),
                  )
                : const Text('Mark Slot Available',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimary)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton.icon(
            onPressed: vm.contactOrganizer,
            icon: const Icon(Icons.phone_outlined,
                size: 18, color: AppColors.onSurface),
            label: Text(
              'Contact Organizer (${alert['organizerName']})',
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.onSurface, width: 1.5),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1))
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
            child: Text('$label:',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.onSurfaceVariant)),
          ),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
        ],
      ),
    );
  }
}