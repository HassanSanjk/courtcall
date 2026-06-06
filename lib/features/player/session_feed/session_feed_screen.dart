import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../auth/auth_viewmodel.dart';
import 'session_feed_viewmodel.dart';
import '../rsvp_confirmation/rsvp_confirmation_screen.dart';

/// Session Feed — the Player's home screen.
///
/// Shows two tabs: Upcoming sessions and Past sessions.
/// Each session is rendered as a [SessionCard] with inline RSVP actions.
/// Tapping a card opens [RsvpConfirmationScreen] for the full RSVP flow.
///
/// TODO(integration): replace Navigator.push with go_router when Mohammed
/// wires the navigation router in week 6.
class SessionFeedScreen extends StatelessWidget {
  const SessionFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sessions'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: 'Notifications',
              onPressed: () {
                // Notification centre — future enhancement.
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Sign out',
              onPressed: () => _confirmSignOut(context),
            ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: colorScheme.primary,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: const _SessionFeedBody(),
      ),
    );
  }

  /// Shows a confirmation dialog before signing out to prevent accidental taps.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AuthViewModel>().signOut();
    }
  }
}

class _SessionFeedBody extends StatelessWidget {
  const _SessionFeedBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionFeedViewModel>();

    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_outlined,
                  size: 48, color: AppColors.textSecondary),
              const SizedBox(height: AppSpacing.md),
              Text(vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: vm.clearError,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      children: [
        _SessionList(
          sessions: vm.upcomingSessions,
          vm: vm,
          emptyMessage: 'No upcoming sessions.\nCheck back later!',
        ),
        _SessionList(
          sessions: vm.pastSessions,
          vm: vm,
          emptyMessage: 'No past sessions yet.',
          isPast: true,
        ),
      ],
    );
  }
}

class _SessionList extends StatelessWidget {
  const _SessionList({
    required this.sessions,
    required this.vm,
    required this.emptyMessage,
    this.isPast = false,
  });

  final List<Session> sessions;
  final SessionFeedViewModel vm;
  final String emptyMessage;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          venueName: session.venueName,
          court: session.court,
          date: session.date,
          time: session.time,
          sport: session.sport,
          costPerPlayer: session.costPerPlayer,
          rsvpCount: session.rsvpCount,
          maxPlayers: session.maxPlayers,
          status: session.status,
          rsvpStatus: vm.rsvpStatusFor(session.sessionId),
          confirmedPlayerNames: vm.confirmedPlayerNamesFor(session.sessionId),
          isLoading: vm.isSessionLoading(session.sessionId),
          onConfirm: () => vm.confirmAttendance(session.sessionId),
          onDecline: () => vm.declineAttendance(session.sessionId),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RsvpConfirmationScreen(session: session),
            ),
          ),
        );
      },
    );
  }
}
