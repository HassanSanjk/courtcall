// features/venue/venue_dashboard/venue_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'venue_dashboard_viewmodel.dart';

class VenueDashboardScreen extends StatefulWidget {
  const VenueDashboardScreen({super.key});

  @override
  State<VenueDashboardScreen> createState() => _VenueDashboardScreenState();
}

class _VenueDashboardScreenState extends State<VenueDashboardScreen> {
  late final VenueDashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = VenueDashboardViewModel();
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
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _buildStatCards(),
                          const SizedBox(height: 24),
                          _buildCourtAvailabilityGrid(),
                          const SizedBox(height: 24),
                          _buildUpcomingBookings(),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomNavBar(),
                ],
              ),
            ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      color: const Color(0xFFF5F6FA),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _viewModel.venueName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _viewModel.greeting,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined,
                        color: Color(0xFF1A1A2E)),
                    onPressed: () {},
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined,
                    color: Color(0xFF1A1A2E)),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stat Cards ───────────────────────────────────────────────────────────

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: "TODAY'S BOOKINGS",
            value: '${_viewModel.todayBookings}',
            icon: Icons.calendar_today_outlined,
            backgroundColor: const Color(0xFF1A1A2E),
            textColor: Colors.white,
            iconColor: Colors.white54,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'EXPECTED REV',
            value: _viewModel.expectedRevenue,
            icon: Icons.trending_up,
            backgroundColor: const Color(0xFF0D7A3E),
            textColor: Colors.white,
            iconColor: Colors.white54,
          ),
        ),
      ],
    );
  }

  // ─── Court Availability Grid ───────────────────────────────────────────────

  Widget _buildCourtAvailabilityGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Court Availability · Today',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'MANAGE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D7A3E),
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Court headers
                Row(
                  children: [
                    const SizedBox(width: 52),
                    ..._viewModel.courtNames.map(
                      (name) => SizedBox(
                        width: 90,
                        child: Center(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time rows
                ..._viewModel.courtSchedule.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            row.timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        ...row.slots.map(
                          (slot) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CourtSlotCell(slot: slot),
                          ),
                        ),
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

  // ─── Upcoming Bookings ─────────────────────────────────────────────────────

  Widget _buildUpcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Bookings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        ..._viewModel.upcomingBookings.map(
          (booking) => _BookingTile(booking: booking),
        ),
      ],
    );
  }

  // ─── Bottom Nav Bar ────────────────────────────────────────────────────────

  Widget _buildBottomNavBar() {
    final items = [
      (Icons.home_outlined, 'Home', 0),
      (Icons.bar_chart_outlined, 'Sessions', 1),
      (Icons.explore_outlined, 'Explore', 2),
      (Icons.person_outline, 'Profile', 3),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              final isSelected = _viewModel.selectedNavIndex == item.$3;
              return GestureDetector(
                onTap: () => _viewModel.onNavTap(item.$3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$1,
                      color: isSelected
                          ? const Color(0xFF0D7A3E)
                          : const Color(0xFF9CA3AF),
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: isSelected
                            ? const Color(0xFF0D7A3E)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: textColor.withOpacity(0.7),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(icon, color: iconColor, size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _CourtSlotCell extends StatelessWidget {
  final CourtSlot slot;

  const _CourtSlotCell({required this.slot});

  Color get _bgColor {
    switch (slot.status) {
      case SlotStatus.booked:
        return const Color(0xFF0D7A3E);
      case SlotStatus.blocked:
        return const Color(0xFFFBB040).withOpacity(0.3);
      case SlotStatus.free:
        return const Color(0xFFF0F0F0);
      case SlotStatus.maintenance:
        return const Color(0xFFE5E7EB);
    }
  }

  Color get _textColor {
    switch (slot.status) {
      case SlotStatus.booked:
        return Colors.white;
      case SlotStatus.blocked:
        return const Color(0xFFD97706);
      case SlotStatus.free:
        return const Color(0xFF9CA3AF);
      case SlotStatus.maintenance:
        return const Color(0xFF6B7280);
    }
  }

  String get _label {
    switch (slot.status) {
      case SlotStatus.booked:
        return slot.playerName ?? 'BOOKED';
      case SlotStatus.blocked:
        return 'BLOCKED';
      case SlotStatus.free:
        return 'FREE';
      case SlotStatus.maintenance:
        return 'Maintenance';
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
        border: slot.status == SlotStatus.blocked
            ? Border.all(color: const Color(0xFFFBB040), width: 1)
            : null,
      ),
      child: Center(
        child: Text(
          _label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
      ),
    );
  }
}

class _BookingTile extends StatelessWidget {
  final UpcomingBooking booking;

  const _BookingTile({required this.booking});

  Color get _timeColor {
    if (booking.isTentative) return Colors.orange;
    return const Color(0xFF1A1A2E);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              booking.time,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: _timeColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.sessionName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${booking.playerName} · ${booking.court}'
                      '${booking.isTentative ? ' (Tentative)' : ''}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF), size: 20),
        ],
      ),
    );
  }
}