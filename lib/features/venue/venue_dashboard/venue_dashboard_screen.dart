import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import 'venue_dashboard_viewmodel.dart';
import '../../../repositories/venue_dashboard_repository.dart';
import '../../../repositories/venue_repository.dart';
import '../../auth/auth_viewmodel.dart';
import '../../auth/login/login_screen.dart';
import '../setup/venue_setup_screen.dart';
import '../availability/availability_screen.dart';
import '../cancellation_alert/cancellation_alert_screen.dart';
import '../analytics/analytics_screen.dart';

class VenueDashboardScreen extends StatefulWidget {
  final String? venueId;

  const VenueDashboardScreen({super.key, this.venueId, this.repo});

  final VenueDashboardRepository? repo;

  @override
  State<VenueDashboardScreen> createState() => _VenueDashboardScreenState();
}

class _VenueDashboardScreenState extends State<VenueDashboardScreen> {
  bool _loadingVenue = true;
  String _venueId = '';

  @override
  void initState() {
    super.initState();
    _resolveVenue();
  }

  Future<void> _resolveVenue() async {
    final venueId = widget.venueId;
    if (venueId != null) {
      _venueId = venueId;
      if (mounted) setState(() => _loadingVenue = false);
      return;
    }

    final user = context.read<AuthViewModel>().currentUser;
    if (user == null || !mounted) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
      return;
    }

    try {
      final repo = context.read<VenueRepository>();
      final venue = await repo.getVenueByOwnerId(user.uid);
      if (!mounted) return;

      if (venue == null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const VenueSetupScreen()),
        );
        return;
      }

      _venueId = venue['venueId'] as String;
      setState(() => _loadingVenue = false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load venue: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingVenue) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => VenueDashboardViewModel(
        repo: widget.repo,
        venueId: _venueId,
      ),
      child: _DashboardBody(venueId: _venueId),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final String venueId;

  const _DashboardBody({required this.venueId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VenueDashboardViewModel>();
    final state = vm.state;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(context, state, venueId),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 420;
                        final pad = isWide ? 24.0 : 16.0;
                        return RefreshIndicator(
                          onRefresh: () => vm.refresh(),
                          child: SingleChildScrollView(
                            padding: EdgeInsets.symmetric(horizontal: pad),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
              SizedBox(height: isWide ? 20 : 16),
                              _buildVenuePhoto(state),
                              SizedBox(height: isWide ? 16 : 12),
                              _buildStatCards(state),
                                SizedBox(height: isWide ? 28 : 24),
                                _buildCourtGrid(context, state, venueId),
                                SizedBox(height: isWide ? 28 : 24),
                                _buildUpcomingBookings(state),
                                SizedBox(height: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNav(context, state, venueId),
    );
  }
}

Widget _buildHeader(BuildContext context, VenueDashboardState state, String venueId) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.venueName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              state.greeting,
              style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurface),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CancellationAlertScreen(venueId: venueId),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_outlined, color: AppColors.onSurface),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AnalyticsScreen(venueId: venueId)),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: AppColors.onSurface),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VenueSetupScreen(venueId: venueId)),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildVenuePhoto(VenueDashboardState state) {
    final imageUrl = state.venueImageUrl;
    if (imageUrl == null) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        imageUrl,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/venue_placeholder.png',
          height: 160,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildStatCards(VenueDashboardState state) {
  return Row(
    children: [
      Expanded(child: _StatCard(
        label: "TODAY'S BOOKINGS",
        value: '${state.todayBookings}',
        icon: Icons.calendar_today_outlined,
        bgColor: AppColors.primary,
      )),
      const SizedBox(width: 12),
      Expanded(child: _StatCard(
        label: 'EXPECTED REV',
        value: state.expectedRevenue,
        icon: Icons.trending_up,
        bgColor: AppColors.secondary,
      )),
    ],
  );
}

Widget _buildCourtGrid(BuildContext context, VenueDashboardState state, String venueId) {
  final schedule = state.schedule;
  final courtNames = state.courtNames;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Court Availability · Today',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface)),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AvailabilityScreen(venueId: venueId, courts: courtNames.cast<String>()),
              ),
            ),
            child: const Text('MANAGE',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary)),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2))
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 52),
                  ...courtNames.map((name) => SizedBox(
                        width: 90,
                        child: Center(
                          child: Text('$name',
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onSurfaceVariant)),
                        ),
                      )),
                ],
              ),
              const SizedBox(height: 8),
              ...schedule.map((row) {
                final slots = row['slots'] as List<dynamic>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52,
                        child: Text('${row['timeLabel']}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.onSurfaceVariant)),
                      ),
                      ...slots.map((slot) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _SlotCell(slot: slot.cast<String, dynamic>()),
                          )),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _buildUpcomingBookings(VenueDashboardState state) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Upcoming Bookings',
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface)),
      const SizedBox(height: 12),
      if (state.upcomingBookings.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: const Text(
            'No upcoming bookings yet',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14, color: AppColors.onSurfaceVariant),
          ),
        )
      else
        ...state.upcomingBookings.map((booking) =>
            _BookingTile(booking: (booking as Map).cast<String, dynamic>())),
    ],
  );
}

Future<void> _signOut(BuildContext context) async {
  await context.read<AuthViewModel>().signOut();
  if (!context.mounted) return;
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

Widget _buildBottomNav(BuildContext context, VenueDashboardState state, String venueId) {
  return NavigationBar(
    selectedIndex: state.selectedNavIndex,
    onDestinationSelected: (index) {
      final vm = context.read<VenueDashboardViewModel>();
      vm.onNavTap(index);
      switch (index) {
        case 0: break;
        case 1:
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AvailabilityScreen(venueId: venueId, courts: state.courtNames.cast<String>()),
            ),
          ).then((_) => vm.onNavTap(0));
          break;
        case 2:
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AnalyticsScreen(venueId: venueId)),
          ).then((_) => vm.onNavTap(0));
          break;
        case 3:
          _signOut(context);
          break;
      }
    },
    destinations: const [
      NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month_rounded),
        label: 'Court Slots',
      ),
      NavigationDestination(
        icon: Icon(Icons.bar_chart_outlined),
        selectedIcon: Icon(Icons.bar_chart_rounded),
        label: 'Analytics',
      ),
      NavigationDestination(
        icon: Icon(Icons.logout_rounded),
        label: 'Sign Out',
      ),
    ],
  );
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color bgColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.7),
                      letterSpacing: 0.5)),
              Icon(icon, color: Colors.white54, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ],
      ),
    );
  }
}

class _SlotCell extends StatelessWidget {
  final Map<String, dynamic> slot;

  const _SlotCell({required this.slot});

  Color get _bgColor {
    switch (slot['status']) {
      case 'booked': return AppColors.primary.withValues(alpha: 0.85);
      case 'available': return AppColors.success.withValues(alpha: 0.2);
      case 'blocked': return AppColors.tertiary.withValues(alpha: 0.3);
      case 'maintenance': return AppColors.outline;
      default: return AppColors.background;
    }
  }

  Color get _textColor {
    switch (slot['status']) {
      case 'booked': return AppColors.onPrimary;
      case 'available': return AppColors.greenBright;
      case 'blocked': return const Color(0xFFD97706);
      case 'maintenance': return AppColors.onSurfaceVariant;
      default: return AppColors.onSurfaceVariant;
    }
  }

  String get _label {
    switch (slot['status']) {
      case 'booked': return slot['playerName'] ?? 'BOOKED';
      case 'available': return slot['playerName'] ?? 'OPEN';
      case 'blocked': return 'BLOCKED';
      case 'maintenance': return 'Maintenance';
      default: return 'FREE';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 44,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(10),
        border: slot['status'] == 'blocked'
            ? Border.all(color: AppColors.tertiary)
            : null,
      ),
      child: Center(
        child: Text(_label,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _textColor)),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final Map<String, dynamic> booking;

  const _BookingTile({required this.booking});

  @override
  Widget build(BuildContext context) {
    final isTentative = booking['isTentative'] == true;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/venue_placeholder.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${booking['sessionName']}',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface)),
                Text(
                  '${booking['playerName']} · ${booking['court']}'
                  '${isTentative ? ' (Tentative)' : ''}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking['date']} · ${booking['time']}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
