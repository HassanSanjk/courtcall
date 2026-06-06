import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
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
  SessionFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';
    final playerName = authVm.currentUser?.name ?? 'Player';

    return DefaultTabController(
      length: 2,
      child: ChangeNotifierProvider(
        create: (_) => SessionFeedViewModel(
          repository: context.read<PlayerRepository>(),
          playerId: playerId,
          playerName: playerName,
        ),
        child: Scaffold(
          appBar: AppBar(
            title: Text('Sessions'),
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined),
                tooltip: 'Notifications',
                onPressed: () {
                  // Notification centre — future enhancement.
                },
              ),
              IconButton(
                icon: Icon(Icons.logout_outlined),
                tooltip: 'Sign out',
                onPressed: () => _confirmSignOut(context),
              ),
            ],
            bottom: TabBar(
              labelColor: colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              indicatorColor: colorScheme.primary,
              tabs: const [
                Tab(text: 'Upcoming'),
                Tab(text: 'Past'),
              ],
            ),
          ),
          body: _SessionFeedBody(),
        ),
      ),
    );
  }

  /// Shows a confirmation dialog before signing out to prevent accidental taps.
  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sign out?'),
        content: Text('You will be returned to the login screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Sign out'),
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
  _SessionFeedBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionFeedViewModel>();

    if (vm.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (vm.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_off_outlined,
                  size: 48, color: Theme.of(context).colorScheme.onSurfaceVariant),
              SizedBox(height: 16.0),
              Text(vm.errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: vm.clearError,
                child: Text('Retry'),
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
  _SessionList({
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
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final pad = isWide ? 24.0 : 16.0;

        if (isWide) {
          return GridView.builder(
            padding: EdgeInsets.all(pad),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              return SessionCard(
                title: session.sport,
                date: session.date,
                time: session.time,
                venue: session.venueName,
                playerCount: session.rsvpCount,
                maxPlayers: session.maxPlayers,
                status: session.status,
                sport: session.sport,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RsvpConfirmationScreen(session: session),
                  ),
                ),
              );
            },
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(pad),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SessionCard(
              title: session.sport,
              date: session.date,
              time: session.time,
              venue: session.venueName,
              playerCount: session.rsvpCount,
              maxPlayers: session.maxPlayers,
              status: session.status,
              sport: session.sport,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RsvpConfirmationScreen(session: session),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
