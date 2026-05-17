// features/venue/availability/availability_viewmodel.dart

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// ─── Enums ─────────────────────────────────────────────────────────────────────

enum SlotStatus {
  open,        // toggleable, currently OFF
  available,   // toggleable, currently ON
  booked,      // locked — has a booking
  maintenance, // locked — marked for maintenance
}

// ─── Models ────────────────────────────────────────────────────────────────────

class TimeSlot {
  final String id;
  final String timeLabel;
  final SlotStatus status;
  final bool isEnabled;

  const TimeSlot({
    required this.id,
    required this.timeLabel,
    required this.status,
    required this.isEnabled,
  });

  TimeSlot copyWith({bool? isEnabled, SlotStatus? status}) {
    return TimeSlot(
      id: id,
      timeLabel: timeLabel,
      status: status ?? this.status,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

class DayAvailability {
  final DateTime date;
  final String label;
  final bool isToday;
  final List<TimeSlot> slots;

  const DayAvailability({
    required this.date,
    required this.label,
    required this.isToday,
    required this.slots,
  });

  DayAvailability copyWith({List<TimeSlot>? slots}) {
    return DayAvailability(
      date: date,
      label: label,
      isToday: isToday,
      slots: slots ?? this.slots,
    );
  }
}

// ─── ViewModel ─────────────────────────────────────────────────────────────────

class AvailabilityViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = true;
  bool isSaving = false;
  bool hasChanges = false;

  DateTime _weekStart = DateTime.now();
  int selectedCourtIndex = 0;

  final List<String> courts = ['Court 1', 'Court 2', 'Court 3', 'VIP Court'];

  // Map<courtIndex, Map<dateKey, List<TimeSlot>>>
  final Map<int, Map<String, List<TimeSlot>>> _scheduleData = {};

  // ── Computed ───────────────────────────────────────────────────────────────

  String get weekRangeLabel {
    final end = _weekStart.add(const Duration(days: 6));
    final startFmt = DateFormat('d MMM').format(_weekStart);
    final endFmt = DateFormat('d MMM yyyy').format(end);
    return '$startFmt – $endFmt';
  }

  List<DayAvailability> get daysWithSlots {
    final courtData = _scheduleData[selectedCourtIndex] ?? {};
    return List.generate(7, (i) {
      final date = _weekStart.add(Duration(days: i));
      final key = _dateKey(date);
      final isToday = _isSameDay(date, DateTime.now());
      final label = DateFormat('EEEE, d MMM').format(date);
      final slots = courtData[key] ?? _defaultSlots(key);
      return DayAvailability(
        date: date,
        label: label,
        isToday: isToday,
        slots: slots,
      );
    });
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // Anchor week to most recent Monday
    final now = DateTime.now();
    _weekStart = now.subtract(Duration(days: now.weekday - 1));

    _seedMockData();

    isLoading = false;
    notifyListeners();
  }

  void selectCourt(int index) {
    selectedCourtIndex = index;
    hasChanges = false;
    notifyListeners();
  }

  void previousWeek() {
    _weekStart = _weekStart.subtract(const Duration(days: 7));
    hasChanges = false;
    notifyListeners();
  }

  void nextWeek() {
    _weekStart = _weekStart.add(const Duration(days: 7));
    hasChanges = false;
    notifyListeners();
  }

  void toggleSlot(DateTime date, String slotId, bool value) {
    final key = _dateKey(date);
    final courtData = _scheduleData[selectedCourtIndex] ??= {};
    final slots = courtData[key] ?? _defaultSlots(key);

    final updated = slots.map((s) {
      if (s.id == slotId &&
          (s.status == SlotStatus.available || s.status == SlotStatus.open)) {
        return s.copyWith(
          isEnabled: value,
          status: value ? SlotStatus.available : SlotStatus.open,
        );
      }
      return s;
    }).toList();

    courtData[key] = updated;
    _scheduleData[selectedCourtIndex] = courtData;
    hasChanges = true;
    notifyListeners();
  }

  Future<void> saveChanges() async {
    isSaving = true;
    notifyListeners();

    // Simulate API call — replace with repository call later
    await Future.delayed(const Duration(seconds: 1));

    isSaving = false;
    hasChanges = false;
    notifyListeners();
  }

  // ── Private Helpers ────────────────────────────────────────────────────────

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Default open slots for any date not explicitly seeded
  List<TimeSlot> _defaultSlots(String dateKey) {
    return [
      TimeSlot(id: '${dateKey}_18', timeLabel: '6:00 PM', status: SlotStatus.available, isEnabled: true),
      TimeSlot(id: '${dateKey}_19', timeLabel: '7:00 PM', status: SlotStatus.available, isEnabled: true),
      TimeSlot(id: '${dateKey}_20', timeLabel: '8:00 PM', status: SlotStatus.available, isEnabled: true),
      TimeSlot(id: '${dateKey}_21', timeLabel: '9:00 PM', status: SlotStatus.available, isEnabled: true),
      TimeSlot(id: '${dateKey}_22', timeLabel: '10:00 PM', status: SlotStatus.open, isEnabled: false),
      TimeSlot(id: '${dateKey}_23', timeLabel: '11:00 PM', status: SlotStatus.open, isEnabled: false),
    ];
  }

  /// Seed mock data with realistic statuses for Court 1, current week
  void _seedMockData() {
    final todayKey = _dateKey(DateTime.now());
    final tomorrowKey = _dateKey(DateTime.now().add(const Duration(days: 1)));

    _scheduleData[0] = {
      todayKey: [
        TimeSlot(id: '${todayKey}_18', timeLabel: '6:00 PM',  status: SlotStatus.available,   isEnabled: true),
        TimeSlot(id: '${todayKey}_19', timeLabel: '7:00 PM',  status: SlotStatus.available,   isEnabled: true),
        TimeSlot(id: '${todayKey}_20', timeLabel: '8:00 PM',  status: SlotStatus.maintenance, isEnabled: false),
        TimeSlot(id: '${todayKey}_21', timeLabel: '9:00 PM',  status: SlotStatus.booked,      isEnabled: false),
        TimeSlot(id: '${todayKey}_22', timeLabel: '10:00 PM', status: SlotStatus.available,   isEnabled: true),
        TimeSlot(id: '${todayKey}_23', timeLabel: '11:00 PM', status: SlotStatus.available,   isEnabled: true),
      ],
      tomorrowKey: [
        TimeSlot(id: '${tomorrowKey}_18', timeLabel: '6:00 PM',  status: SlotStatus.booked,    isEnabled: false),
        TimeSlot(id: '${tomorrowKey}_19', timeLabel: '7:00 PM',  status: SlotStatus.booked,    isEnabled: false),
        TimeSlot(id: '${tomorrowKey}_20', timeLabel: '8:00 PM',  status: SlotStatus.available, isEnabled: true),
        TimeSlot(id: '${tomorrowKey}_21', timeLabel: '9:00 PM',  status: SlotStatus.available, isEnabled: true),
        TimeSlot(id: '${tomorrowKey}_22', timeLabel: '10:00 PM', status: SlotStatus.open,      isEnabled: false),
        TimeSlot(id: '${tomorrowKey}_23', timeLabel: '11:00 PM', status: SlotStatus.open,      isEnabled: false),
      ],
    };
  }
}