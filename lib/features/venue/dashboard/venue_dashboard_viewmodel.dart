// features/venue/venue_dashboard/venue_dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';

// ─── Enums ─────────────────────────────────────────────────────────────────────

enum SlotStatus { booked, blocked, free, maintenance }

// ─── Models ────────────────────────────────────────────────────────────────────

class CourtSlot {
  final SlotStatus status;
  final String? playerName; // shown when status == booked

  const CourtSlot({required this.status, this.playerName});
}

class CourtScheduleRow {
  final String timeLabel;
  final List<CourtSlot> slots; // one per court

  const CourtScheduleRow({required this.timeLabel, required this.slots});
}

class UpcomingBooking {
  final String time;
  final String sessionName;
  final String playerName;
  final String court;
  final bool isTentative;

  const UpcomingBooking({
    required this.time,
    required this.sessionName,
    required this.playerName,
    required this.court,
    this.isTentative = false,
  });
}

// ─── ViewModel ─────────────────────────────────────────────────────────────────

class VenueDashboardViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = true;
  int selectedNavIndex = 0;

  // Header
  String venueName = '';
  String greeting = '';

  // Stat cards
  int todayBookings = 0;
  String expectedRevenue = '';

  // Court grid
  List<String> courtNames = [];
  List<CourtScheduleRow> courtSchedule = [];

  // Upcoming bookings
  List<UpcomingBooking> upcomingBookings = [];

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    // Simulate async fetch
    await Future.delayed(const Duration(milliseconds: 600));

    _loadHeader();
    _loadStatCards();
    _loadCourtSchedule();
    _loadUpcomingBookings();

    isLoading = false;
    notifyListeners();
  }

  void onNavTap(int index) {
    selectedNavIndex = index;
    notifyListeners();
  }

  // ── Private Loaders (mock data) ────────────────────────────────────────────

  void _loadHeader() {
    venueName = 'Nexus Futsal';
    greeting = _buildGreeting('En. Hafiz');
  }

  void _loadStatCards() {
    todayBookings = 12;
    expectedRevenue = 'RM 1.2k';
  }

  void _loadCourtSchedule() {
    courtNames = ['Court 1', 'Court 2', 'Court 3'];

    courtSchedule = [
      CourtScheduleRow(
        timeLabel: '6 PM',
        slots: [
          const CourtSlot(status: SlotStatus.booked, playerName: 'Hafiz (P)'),
          const CourtSlot(status: SlotStatus.free),
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
        ],
      ),
      CourtScheduleRow(
        timeLabel: '7 PM',
        slots: [
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
        ],
      ),
      CourtScheduleRow(
        timeLabel: '8 PM',
        slots: [
          const CourtSlot(status: SlotStatus.booked, playerName: 'Azri (P)'),
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
          const CourtSlot(status: SlotStatus.blocked),
        ],
      ),
      CourtScheduleRow(
        timeLabel: '9 PM',
        slots: [
          const CourtSlot(status: SlotStatus.booked, playerName: 'BOOKED'),
          const CourtSlot(status: SlotStatus.free),
          const CourtSlot(status: SlotStatus.blocked),
        ],
      ),
      CourtScheduleRow(
        timeLabel: '10 PM',
        slots: [
          const CourtSlot(status: SlotStatus.free),
          const CourtSlot(status: SlotStatus.free),
          const CourtSlot(status: SlotStatus.maintenance),
        ],
      ),
    ];
  }

  void _loadUpcomingBookings() {
    upcomingBookings = const [
      UpcomingBooking(
        time: '8PM',
        sessionName: 'Friday Futsal',
        playerName: 'Azri',
        court: 'Court 1',
      ),
      UpcomingBooking(
        time: '9PM',
        sessionName: 'Futsal Malam',
        playerName: 'Syafiq',
        court: 'Court 2',
      ),
      UpcomingBooking(
        time: '10PM',
        sessionName: 'Casual Kick',
        playerName: 'Danial',
        court: 'Court 1',
        isTentative: true,
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    final String period;
    if (hour < 12) {
      period = 'morning';
    } else if (hour < 17) {
      period = 'afternoon';
    } else {
      period = 'evening';
    }
    return 'Good $period, $name';
  }
}