import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  RsvpConfirmationScreen({super.key, required this.session});

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
      child: _RsvpConfirmationView(),
    );
  }
}

class _RsvpConfirmationView extends StatefulWidget {
  _RsvpConfirmationView();

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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('RSVP'),
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        elevation: 0,
      ),
      body: vm.isLoading
          ? Center(
              child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary))
          : _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, RsvpConfirmationViewModel vm) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Session summary card ────────────────────────────────────
          _SessionSummaryCard(session: vm.session),
          SizedBox(height: 24.0),

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
          Text('Will you be there?', style: Theme.of(context).textTheme.headlineMedium),
          SizedBox(height: 16.0),

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
                    color: Theme.of(context).colorScheme.secondary,
                    isSelected: (_pendingSelection ?? vm.currentStatus) ==
                        'confirmed',
                    isLoading: vm.isSubmitting &&
                        _pendingSelection == 'confirmed',
                    onTap: () =>
                        setState(() => _pendingSelection = 'confirmed'),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: _ResponseCard(
                    label: 'Maybe',
                    icon: Icons.help_outline,
                    color: Theme.of(context).colorScheme.tertiary,
                    isSelected:
                        (_pendingSelection ?? vm.currentStatus) == 'pending',
                    isLoading:
                        vm.isSubmitting && _pendingSelection == 'pending',
                    onTap: () =>
                        setState(() => _pendingSelection = 'pending'),
                  ),
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: _ResponseCard(
                    label: "Can't\nMake It",
                    icon: Icons.cancel_outlined,
                    color: Theme.of(context).colorScheme.error,
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
          SizedBox(height: 16.0),

          // ── Live tally ──────────────────────────────────────────────
          Center(
            child: Text(
              '${vm.goingCount} GOING · ${vm.maybeCount} MAYBE · ${vm.outCount} OUT',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                letterSpacing: 0.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 16.0),

          // ── Optional note ───────────────────────────────────────────
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add a note (Optional) — e.g. I might be 10 mins late...',
            ),
          ),
          SizedBox(height: 24.0),

          // ── Confirm RSVP button ─────────────────────────────────────
          ElevatedButton(
            onPressed: (vm.isSubmitting || _pendingSelection == null)
                ? null
                : () => _submitRsvp(context, vm),
            child: vm.isSubmitting
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  )
                : Text('Confirm RSVP'),
          ),
          SizedBox(height: 24.0),

          // ── Confirmed participants ──────────────────────────────────
          if (vm.confirmedRsvps.isNotEmpty) ...[
            Text(
              "Who's going (${vm.confirmedRsvps.length})",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.0),
            ...vm.confirmedRsvps.map(
              (rsvp) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      child: Text(rsvp.playerName.isNotEmpty ? rsvp.playerName[0] : '?'),
                    ),
                    SizedBox(width: 8.0),
                    Text(rsvp.playerName, style: Theme.of(context).textTheme.bodyMedium),
                    Spacer(),
                    StatusPill(
                      label: 'Going',
                      status: PillStatus.going,
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 32.0),
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
  _SessionSummaryCard({required this.session});
  final Session session;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        children: [
          Text(
            '${session.venueName} · ${session.court}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.0),
          Text(
            session.date,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ),
          ),
          Text(
            session.time,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100.0),
            ),
            child: Text(
              'RM ${session.costPerPlayer.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.surface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponseCard extends StatelessWidget {
  _ResponseCard({
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
        duration: Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 8.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected ? color : Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 4.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaitlistCard extends StatelessWidget {
  _WaitlistCard({
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
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.tertiary
                : Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.queue_outlined,
                color: Theme.of(context).colorScheme.tertiary, size: 20),
            SizedBox(width: 8.0),
            Text(
              'Session Full — Join Waitlist',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsequenceBanner extends StatelessWidget {
  _ConsequenceBanner({required this.spotsRemaining});
  final int spotsRemaining;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Theme.of(context).colorScheme.tertiary),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.tertiary, size: 18),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              'Heads up — if you leave, the session may be underpaid. '
              'Only $spotsRemaining spot${spotsRemaining == 1 ? '' : 's'} remaining.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  _MessageBanner({
    required this.message,
    required this.isError,
    this.onDismiss,
  });

  final String message;
  final bool isError;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final color = isError ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.secondary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: color,
            size: 18,
          ),
          SizedBox(width: 8.0),
          Expanded(
            child: Text(
              message,
              style:
                  Theme.of(context).textTheme.bodySmall?.copyWith(color: color),
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
