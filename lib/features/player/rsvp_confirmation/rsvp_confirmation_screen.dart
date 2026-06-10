import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../../repositories/venue_repository.dart';
import '../../auth/auth_viewmodel.dart';
import 'rsvp_confirmation_viewmodel.dart';

class RsvpConfirmationScreen extends StatelessWidget {
  const RsvpConfirmationScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';
    final playerName = authVm.currentUser?.name ?? 'Player';

    return ChangeNotifierProvider(
      create: (_) => RsvpConfirmationViewModel(
        repository: context.read<PlayerRepository>(),
        venueRepository: context.read<VenueRepository>(),
        session: session,
        playerId: playerId,
        playerName: playerName,
      ),
      child: _RsvpConfirmationView(),
    );
  }
}

class _RsvpConfirmationView extends StatefulWidget {
  @override
  State<_RsvpConfirmationView> createState() => _RsvpConfirmationViewState();
}

class _RsvpConfirmationViewState extends State<_RsvpConfirmationView> {
  int _selectedOption = -1;
  final _noteController = TextEditingController();

  static const _rsvpOptions = [
    _RSVPOptionData(
      index: 0,
      icon: Icons.check_circle_rounded,
      label: 'Going',
      value: 'confirmed',
      activeColor: AppColors.greenBright,
      bgColor: AppColors.greenLight,
    ),
    _RSVPOptionData(
      index: 1,
      icon: Icons.help_outline_rounded,
      label: 'Maybe',
      value: 'pending',
      activeColor: AppColors.amber,
      bgColor: AppColors.amberLight,
    ),
    _RSVPOptionData(
      index: 2,
      icon: Icons.cancel_rounded,
      label: "Can't\nMake It",
      value: 'declined',
      activeColor: AppColors.error,
      bgColor: AppColors.redLight,
    ),
  ];

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RsvpConfirmationViewModel>();

    if (vm.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Pre-select current status on first load
    if (_selectedOption == -1 && vm.currentStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedOption = _indexForStatus(vm.currentStatus);
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CourtInfoCard(session: vm.session, venueImageUrl: vm.venueImageUrl),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Messages
                  if (vm.successMessage != null)
                    _MessageBanner(
                      message: vm.successMessage!,
                      isError: false,
                      onDismiss: () => vm.clearError(),
                    ),
                  if (vm.errorMessage != null)
                    _MessageBanner(
                      message: vm.errorMessage!,
                      isError: true,
                      onDismiss: vm.clearError,
                    ),

                  // Consequence banner
                  if (vm.wouldCauseUnderpay && _selectedOption == 2)
                    _ConsequenceBanner(spotsRemaining: vm.spotsRemaining),

                  const Center(
                    child: Text(
                      'Will you be there?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Waitlist card or RSVP options
                  if (vm.isFull && vm.currentStatus != 'confirmed')
                    _WaitlistCard(
                      isSelected: _selectedOption == 3,
                      isLoading: vm.isSubmitting,
                      onTap: () {
                        setState(() => _selectedOption = 3);
                        vm.joinWaitlist();
                      },
                    )
                  else
                    Row(
                      children: _rsvpOptions
                          .map((opt) => Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: opt.index == 0 ? 0 : 6,
                                    right: opt.index == 2 ? 0 : 6,
                                  ),
                                  child: _RSVPOptionButton(
                                    option: opt,
                                    isSelected: _selectedOption == opt.index,
                                    onTap: () =>
                                        setState(() => _selectedOption = opt.index),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),

                  const SizedBox(height: 16),

                  // Tally
                  Center(
                    child: Text(
                      '${vm.goingCount} GOING · ${vm.maybeCount} MAYBE · ${vm.outCount} OUT',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Note field
                  const Text(
                    'Add a note (Optional)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _noteController,
                    maxLines: 4,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'E.g. I might be 10 mins late...',
                      hintStyle: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Confirm button
                  _ConfirmButton(
                    isLoading: vm.isSubmitting,
                    hasSelection: _selectedOption >= 0,
                    onPressed: () => _submitRsvp(context, vm),
                  ),

                  const SizedBox(height: 32),

                  // Participant list
                  if (vm.confirmedRsvps.isNotEmpty) ...[
                    Text(
                      "Who's going (${vm.confirmedRsvps.length})",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...vm.confirmedRsvps.map(
                      (rsvp) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.avatarNavy,
                              child: Text(
                                rsvp.playerName.isNotEmpty
                                    ? rsvp.playerName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              rsvp.playerName,
                              style: const TextStyle(
                                fontSize: 15,
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            StatusBadge.paid(),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        splashRadius: 20,
      ),
      title: const Text('RSVP'),
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppColors.outline),
      ),
    );
  }

  int _indexForStatus(String? status) {
    switch (status) {
      case 'confirmed':
        return 0;
      case 'pending':
        return 1;
      case 'declined':
        return 2;
      case 'waiting':
        return 3;
      default:
        return -1;
    }
  }

  Future<void> _submitRsvp(
    BuildContext context,
    RsvpConfirmationViewModel vm,
  ) async {
    switch (_selectedOption) {
      case 0:
        await vm.confirmAttendance();
      case 1:
        await vm.markMaybe();
      case 2:
        await vm.declineAttendance();
    }
  }
}

// ─── RSVP Option Data ─────────────────────────────────────────────────────────

class _RSVPOptionData {
  final int index;
  final IconData icon;
  final String label;
  final String value;
  final Color activeColor;
  final Color bgColor;

  const _RSVPOptionData({
    required this.index,
    required this.icon,
    required this.label,
    required this.value,
    required this.activeColor,
    required this.bgColor,
  });
}

// ─── Court Info Card ─────────────────────────────────────────────────────────

class _CourtInfoCard extends StatelessWidget {
  final Session session;
  final String? venueImageUrl;

  const _CourtInfoCard({required this.session, this.venueImageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
      decoration: BoxDecoration(
        color: AppColors.darkNavy,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          if (venueImageUrl != null && venueImageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: venueImageUrl!,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                placeholder: (_, _) => Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white54)),
                ),
                errorWidget: (_, _, _) => Image.asset(
                  'assets/images/venue_placeholder.png',
                  height: 180,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          if (venueImageUrl != null && venueImageUrl!.isNotEmpty)
            const SizedBox(height: 16),
          Text(
            '${session.venueName} · ${session.court}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            session.date,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            session.time,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.greenBright,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Text(
              'RM ${session.costPerPlayer.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── RSVP Option Button ──────────────────────────────────────────────────────

class _RSVPOptionButton extends StatelessWidget {
  final _RSVPOptionData option;
  final bool isSelected;
  final VoidCallback onTap;

  const _RSVPOptionButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? option.bgColor : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? option.activeColor : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: option.activeColor.withValues(alpha: 0.18),
                blurRadius: 12,
                offset: const Offset(0, 4),
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(option.icon, color: option.activeColor, size: 36),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? option.activeColor : AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Waitlist Card ───────────────────────────────────────────────────────────

class _WaitlistCard extends StatelessWidget {
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  const _WaitlistCard({
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.amberLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.amber : AppColors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_outlined,
                color: AppColors.amber, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Session Full - Join Waitlist',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirm Button ──────────────────────────────────────────────────────────

class _ConfirmButton extends StatelessWidget {
  final bool isLoading;
  final bool hasSelection;
  final VoidCallback onPressed;

  const _ConfirmButton({
    required this.isLoading,
    required this.hasSelection,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: (isLoading || !hasSelection) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Confirm RSVP',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
      ),
    );
  }
}

// ─── Consequence Banner ──────────────────────────────────────────────────────

class _ConsequenceBanner extends StatelessWidget {
  final int spotsRemaining;

  const _ConsequenceBanner({required this.spotsRemaining});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.amberLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.amber),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.amber, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Heads up - if you leave, the session may be underpaid. '
              'Only $spotsRemaining spot${spotsRemaining == 1 ? '' : 's'} remaining.',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.amber,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Message Banner ──────────────────────────────────────────────────────────

class _MessageBanner extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  const _MessageBanner({
    required this.message,
    required this.isError,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.greenBright;
    final bgColor = isError ? AppColors.redLight : AppColors.greenLight;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close, color: color, size: 16),
            ),
        ],
      ),
    );
  }
}
