import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/session_card.dart';
import '../../../models/session.dart';
import '../create_session/create_session_screen.dart';
import '../create_session/create_session_viewmodel.dart';
import '../rsvp_tracker/rsvp_tracker_screen.dart';
import '../rsvp_tracker/rsvp_tracker_viewmodel.dart';
import 'dashboard_viewmodel.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();

    return Scaffold(
      backgroundColor: AppColors.backgroundAsh,
      body: SafeArea(
        child: vm.loading
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  const _Header(),
                  _KpiRow(vm: vm),
                  const _SectionTitle(title: 'Upcoming Sessions'),
                  _SessionList(vm: vm),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateSession(context),
        backgroundColor: AppColors.primaryNavy,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Session',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _openCreateSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => CreateSessionViewModel(),
          child: const CreateSessionScreen(),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning,',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Organizer',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                ],
              ),
            ),
            const CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primaryNavy,
              child: Text(
                'OR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiRow extends StatelessWidget {
  final DashboardViewModel vm;
  const _KpiRow({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Row(
          children: [
            Expanded(
              child: KpiCard(
                label: 'Upcoming',
                value: '${vm.totalSessions}',
                icon: Icons.sports_basketball_outlined,
                accentColor: AppColors.primaryNavy,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: 'Total Slots',
                value: '${vm.totalPlayers}',
                icon: Icons.people_outline,
                accentColor: AppColors.accentGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: KpiCard(
                label: 'Pending Pay',
                value: vm.unpaidCount > 0 ? '${vm.unpaidCount}' : '—',
                icon: Icons.payments_outlined,
                accentColor: AppColors.alertAmber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
        ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final DashboardViewModel vm;
  const _SessionList({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.sessions.isEmpty) {
      return const SliverFillRemaining(
        child: Center(
          child: Text(
            'No upcoming sessions.',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final Session s = vm.sessions[i];
            return SessionCard(
              title: '${s.sport} · ${s.courtName}',
              date: s.date,
              time: s.startTime,
              venue: s.venueName,
              playerCount: s.confirmedCount,
              maxPlayers: s.maxPlayers,
              status: s.status,
              onTap: () => _openRsvpTracker(context, s),
            );
          },
          childCount: vm.sessions.length,
        ),
      ),
    );
  }

  void _openRsvpTracker(BuildContext context, Session s) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => RsvpTrackerViewModel()),
          ],
          child: const RsvpTrackerScreen(),
        ),
      ),
    );
  }
}
