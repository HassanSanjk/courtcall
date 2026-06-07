import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../models/models.dart';
import '../../../repositories/player_repository.dart';
import '../../auth/auth_viewmodel.dart';
import '../rsvp_confirmation/rsvp_confirmation_screen.dart';
import 'session_feed_viewmodel.dart';


class SessionFeedScreen extends StatelessWidget {
  const SessionFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.read<AuthViewModel>();
    final playerId = authVm.currentUser?.uid ?? 'player_001';
    final playerName = authVm.currentUser?.name ?? 'Player';

    return ChangeNotifierProvider(
      create: (_) => SessionFeedViewModel(
        repository: context.read<PlayerRepository>(),
        playerId: playerId,
        playerName: playerName,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _FeedBody(),
        ),
      ),
    );
  }
}

// ─── Body ─────────────────────────────────────────────────────────────────────

class _FeedBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SessionFeedViewModel>();

    return Column(
      children: [
        _FeedHeader(name: vm.playerId == 'player_001' ? 'Player' : vm.playerId),
        Expanded(
          child: vm.isLoading
              ? const Center(child: CircularProgressIndicator())
              : vm.errorMessage != null
                  ? _ErrorState(message: vm.errorMessage!, onRetry: vm.clearError)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const SectionHeader(title: 'Upcoming Sessions'),
                          const SizedBox(height: 12),
                          if (vm.upcomingSessions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: Text(
                                  'No upcoming sessions',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...vm.upcomingSessions.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SessionCard(
                                  session: s,
                                  rsvpStatus: vm.rsvpStatusFor(s.sessionId),
                                  confirmedNames: vm.confirmedPlayerNamesFor(s.sessionId),
                                  isLoading: vm.isSessionLoading(s.sessionId),
                                  onGoing: () => vm.confirmAttendance(s.sessionId),
                                  onCantMakeIt: () => vm.declineAttendance(s.sessionId),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => RsvpConfirmationScreen(session: s),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),
                          _PastSessionsHeader(),
                          const SizedBox(height: 12),
                          if (vm.pastSessions.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(bottom: 24),
                              child: Center(
                                child: Text(
                                  'No past sessions',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...vm.pastSessions.map(
                              (s) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _SessionCard(
                                  session: s,
                                  rsvpStatus: vm.rsvpStatusFor(s.sessionId),
                                  confirmedNames: vm.confirmedPlayerNamesFor(s.sessionId),
                                  isLoading: vm.isSessionLoading(s.sessionId),
                                  onGoing: null,
                                  onCantMakeIt: null,
                                  onTap: null,
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined,
                size: 48, color: AppColors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ─── Feed Header ──────────────────────────────────────────────────────────────

class _FeedHeader extends StatelessWidget {
  final String name;

  const _FeedHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '?';
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Upcoming Sessions',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.darkNavy,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Session Card ─────────────────────────────────────────────────────────────

String _sportEmoji(String? sport) {
  switch (sport?.toLowerCase()) {
    case 'futsal':
      return '⚽';
    case 'badminton':
      return '🏸';
    case 'basketball':
      return '🏀';
    case 'volleyball':
      return '🏐';
    default:
      return '⚽';
  }
}

StatusBadge _badgeFor(String? rsvpStatus) {
  switch (rsvpStatus) {
    case 'confirmed':
      return StatusBadge.paid();
    case 'pending':
    case 'maybe':
      return StatusBadge.pending();
    case 'declined':
      return StatusBadge.declined();
    case 'waiting':
      return StatusBadge.waitlist();
    default:
      return StatusBadge.pending();
  }
}

List<AvatarData> _avatarsFromNames(List<String> names) {
  const colors = [
    AppColors.avatarNavy,
    AppColors.avatarBlue,
    AppColors.avatarTeal,
    AppColors.avatarPurple,
    AppColors.avatarOrange,
  ];
  return names.take(3).toList().asMap().entries.map((e) {
    final name = e.value;
    final initials = name.isNotEmpty ? name.substring(0, 2).toUpperCase() : '?';
    return AvatarData(initials, colors[e.key % colors.length]);
  }).toList();
}

class _SessionCard extends StatelessWidget {
  final Session session;
  final String? rsvpStatus;
  final List<String> confirmedNames;
  final bool isLoading;
  final VoidCallback? onGoing;
  final VoidCallback? onCantMakeIt;
  final VoidCallback? onTap;

  const _SessionCard({
    required this.session,
    this.rsvpStatus,
    this.confirmedNames = const [],
    this.isLoading = false,
    this.onGoing,
    this.onCantMakeIt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatars = _avatarsFromNames(confirmedNames);
    final overflow = (session.rsvpCount - avatars.length).clamp(0, 999);
    final isPast = session.status != 'upcoming';

    return GestureDetector(
      onTap: onTap,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_sportEmoji(session.sport),
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${session.venueName} · ${session.court}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _badgeFor(rsvpStatus),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              session.venueName,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${session.date} · ${session.time}',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${session.rsvpCount} of ${session.maxPlayers} going',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                AvatarStack(avatars: avatars, overflow: overflow),
              ],
            ),
            if (!isPast && onGoing != null && onCantMakeIt != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _GoingButton(onPressed: onGoing!, isLoading: isLoading)),
                  const SizedBox(width: 10),
                  Expanded(child: _CantMakeItButton(onPressed: onCantMakeIt!, isLoading: isLoading)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoingButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _GoingButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkNavy,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
          : const Text(
              "I'm Going",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
    );
  }
}

class _CantMakeItButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isLoading;

  const _CantMakeItButton({required this.onPressed, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        padding: const EdgeInsets.symmetric(vertical: 13),
        side: const BorderSide(color: AppColors.error, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  color: AppColors.error, strokeWidth: 2),
            )
          : const Text(
              "Can't Make It",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
    );
  }
}

// ─── Past Sessions Header ─────────────────────────────────────────────────────

class _PastSessionsHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Past Sessions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary, size: 24),
        ],
      ),
    );
  }
}


