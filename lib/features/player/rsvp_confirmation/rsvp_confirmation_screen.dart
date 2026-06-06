import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../../features/auth/auth_viewmodel.dart';
import 'rsvp_confirmation_viewmodel.dart';

/// RSVP Confirmation screen — matches wireframe Figure 16.
///
/// Layout:
///   - Full session summary card (Primary Navy)
///   - "Will you be there?" heading
///   - Three equal-width tap cards: Going (green) / Maybe (yellow) / Can't Make It (red)
///   - Live tally: "8 GOING · 2 MAYBE · 1 OUT"
///   - Optional note field
///   - Confirm RSVP button
///   - Consequence visibility banner (shown when declining would hurt session)
///   - Participant list (confirmed players)
///
/// If session is full: Going card is replaced by "Join Waitlist".
class RsvpConfirmationScreen extends StatelessWidget {
  const RsvpConfirmationScreen({super.key, required this.session});

  final Session session;

  @override
  Widget build(BuildContext context) {
    // FIX: Read player identity from AuthViewModel instead of hardcoding.
    // Falls back to 'player_001' / 'Player' when auth is not yet wired
    // (i.e., during UI-only development with mock repos).
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';
    final playerName = authVm.currentUser?.name ?? 'Player';

    return ChangeNotifierProvider(
      create: (_) => RsvpConfirmationViewModel(
        repository: context.read<PlayerRepository>(),
        session: session,
        playerId: playerId,
        playerName: playerName,
      ),
      child: const _RsvpConfirmationView(),
    );
  }
}

class _RsvpConfirmationView extends StatefulWidget {
  const _RsvpConfirmationView();

  @override
  State<_RsvpConfirmationView> createState() => _RsvpConfirmationViewState();
}

class _RsvpConfirmationViewState extends State<_RsvpConfirmationView> {
  final _noteController = TextEditingController();
  String? _pendingSelection; // tracks tapped card before final confirm

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RsvpConfirmationViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundAsh,
      appBar: AppBar(
        title: const Text('RSVP'),
        backgroundColor: AppColors.backgroundAsh,
        elevation: 0,
      ),
      body: vm.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryNavy))
          : _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, RsvpConfirmationViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Session summary card ────────────────────────────────────
          _SessionSummaryCard(session: vm.session),
          const SizedBox(height: AppSpacing.lg),

          // ── Success / error messages ────────────────────────────────
          if (vm.successMessage != null)
            _MessageBanner(
              message: vm.successMessage!,
              isError: false,
            ),
          if (vm.errorMessage != null)
            _MessageBanner(
              message: vm.errorMessage!,
              isError: true,
              onDismiss: vm.clearError,
            ),

          // ── Consequence visibility ──────────────────────────────────
          if (vm.wouldCauseUnderpay &&
              (_pendingSelection == 'declined' ||
                  vm.currentStatus == 'declined'))
            _ConsequenceBanner(spotsRemaining: vm.spotsRemaining),

          // ── "Will you be there?" ────────────────────────────────────
          Text('Will you be there?', style: AppTextStyles.headlineMedium),
          const SizedBox(height: AppSpacing.md),

          // ── Response cards ──────────────────────────────────────────
          if (vm.isFull && vm.currentStatus != 'confirmed')
            _WaitlistCard(
              isSelected: vm.currentStatus == 'waiting',
              isLoading: vm.isSubmitting,
              onTap: () {
                setState(() => _pendingSelection = 'waiting');
                vm.joinWaitlist();
              },
            )
          else
            Row(
              children: [
                Expanded(
                  child: _ResponseCard(
                    label: 'Going',
                    icon: Icons.check_circle_outline,
                    color: AppColors.accentGreen,
                    isSelected: (_pendingSelection ?? vm.currentStatus) ==
                        'confirmed',
                    isLoading: vm.isSubmitting &&
                        _pendingSelection == 'confirmed',
                    onTap: () =>
                        setState(() => _pendingSelection = 'confirmed'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ResponseCard(
                    label: 'Maybe',
                    icon: Icons.help_outline,
                    color: AppColors.alertAmber,
                    isSelected:
                        (_pendingSelection ?? vm.currentStatus) == 'pending',
                    isLoading:
                        vm.isSubmitting && _pendingSelection == 'pending',
                    onTap: () =>
                        setState(() => _pendingSelection = 'pending'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _ResponseCard(
                    label: "Can't\nMake It",
                    icon: Icons.cancel_outlined,
                    color: AppColors.declined,
                    isSelected:
                        (_pendingSelection ?? vm.currentStatus) == 'declined',
                    isLoading:
                        vm.isSubmitting && _pendingSelection == 'declined',
                    onTap: () =>
                        setState(() => _pendingSelection = 'declined'),
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),

          // ── Live tally ──────────────────────────────────────────────
          Center(
            child: Text(
              '${vm.goingCount} GOING · ${vm.maybeCount} MAYBE · ${vm.outCount} OUT',
              style: AppTextStyles.bodySmall.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Optional note ───────────────────────────────────────────
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'Add a note (Optional) — e.g. I might be 10 mins late...',
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Confirm RSVP button ─────────────────────────────────────
          ElevatedButton(
            onPressed: (vm.isSubmitting || _pendingSelection == null)
                ? null
                : () => _submitRsvp(context, vm),
            child: vm.isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.surfaceWhite,
                    ),
                  )
                : const Text('Confirm RSVP'),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Confirmed participants ──────────────────────────────────
          if (vm.confirmedRsvps.isNotEmpty) ...[
            Text(
              "Who's going (${vm.confirmedRsvps.length})",
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...vm.confirmedRsvps.map(
              (rsvp) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    PlayerAvatar(
                      name: rsvp.playerName,
                      size: AvatarSize.md,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(rsvp.playerName, style: AppTextStyles.bodyMedium),
                    const Spacer(),
                    const StatusPill(
                      label: 'Going',
                      type: StatusPillType.confirmed,
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _submitRsvp(
    BuildContext context,
    RsvpConfirmationViewModel vm,
  ) async {
    switch (_pendingSelection) {
      case 'confirmed':
        await vm.confirmAttendance();
      case 'pending':
        await vm.markMaybe();
      case 'declined':
        await vm.declineAttendance();
      case 'waiting':
        await vm.joinWaitlist();
    }
    if (vm.successMessage != null && mounted) {
      setState(() => _pendingSelection = null);
    }
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────────

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        children: [
          Text(
            '${session.venueName} · ${session.court}',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.surfaceWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            session.date,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surfaceWhite.withValues(alpha: 0.8),
            ),
          ),
          Text(
            session.time,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.surfaceWhite.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              'RM ${session.costPerPlayer.toStringAsFixed(2)}',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.surfaceWhite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelMedium.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitlistCard extends StatelessWidget {
  const _WaitlistCard({
    required this.isSelected,
    required this.isLoading,
    required this.onTap,
  });

  final bool isSelected;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.alertAmber.withValues(alpha: 0.1)
              : AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.alertAmber
                : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_outlined,
                color: AppColors.alertAmber, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Session Full — Join Waitlist',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.alertAmber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsequenceBanner extends StatelessWidget {
  const _ConsequenceBanner({required this.spotsRemaining});
  final int spotsRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.alertAmber.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.alertAmber),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.alertAmber, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Heads up — if you leave, the session may be underpaid. '
              'Only $spotsRemaining spot${spotsRemaining == 1 ? '' : 's'} remaining.',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.alertAmber,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.isError,
    this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.declined : AppColors.accentGreen;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style:
                  AppTextStyles.bodySmall.copyWith(color: color),
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
