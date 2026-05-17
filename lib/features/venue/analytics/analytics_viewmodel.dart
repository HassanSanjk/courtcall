// features/venue/analytics/analytics_viewmodel.dart

import 'package:flutter/foundation.dart';

// ─── Enums ─────────────────────────────────────────────────────────────────────

enum RevenuePeriod {
  thisWeek('This Week'),
  thisMonth('This Month'),
  allTime('All Time');

  final String label;
  const RevenuePeriod(this.label);
}

// ─── Models ────────────────────────────────────────────────────────────────────

class ChartBar {
  final double value;
  final bool isHighlighted; // brightest bar (e.g. today or peak day)

  const ChartBar({required this.value, this.isHighlighted = false});
}

class PeriodStats {
  final int sessions;
  final int cancelled;
  final String noShowRate;

  const PeriodStats({
    required this.sessions,
    required this.cancelled,
    required this.noShowRate,
  });
}

class TopOrganizer {
  final String name;
  final int sessions;
  final String revenue;

  const TopOrganizer({
    required this.name,
    required this.sessions,
    required this.revenue,
  });
}

// ─── ViewModel ─────────────────────────────────────────────────────────────────

class AnalyticsViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = true;
  RevenuePeriod selectedPeriod = RevenuePeriod.thisWeek;

  // Keyed by period for instant tab switching
  final Map<RevenuePeriod, _PeriodData> _data = {};

  // ── Computed ───────────────────────────────────────────────────────────────

  _PeriodData get _current =>
      _data[selectedPeriod] ?? _PeriodData.empty();

  String get totalRevenue => _current.totalRevenue;
  String get revenueTrend => _current.trend;
  bool get isTrendPositive => _current.isTrendPositive;
  String get periodLabel => _current.periodLabel;
  List<ChartBar> get chartBars => _current.bars;
  List<String> get dayLabels => _current.dayLabels;
  PeriodStats get stats => _current.stats;
  List<TopOrganizer> get topOrganizers => _current.topOrganizers;

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    _seedAllPeriods();

    isLoading = false;
    notifyListeners();
  }

  void selectPeriod(RevenuePeriod period) {
    selectedPeriod = period;
    notifyListeners();
  }

  // ── Private Seeders (mock data) ────────────────────────────────────────────

  void _seedAllPeriods() {
    _data[RevenuePeriod.thisWeek] = _PeriodData(
      totalRevenue: 'RM 4,500',
      trend: '+12%',
      isTrendPositive: true,
      periodLabel: "THIS WEEK'S REVENUE",
      bars: const [
        ChartBar(value: 300),
        ChartBar(value: 500),
        ChartBar(value: 450),
        ChartBar(value: 600),
        ChartBar(value: 800, isHighlighted: true),
        ChartBar(value: 1100, isHighlighted: true),
        ChartBar(value: 750),
      ],
      dayLabels: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      stats: const PeriodStats(
        sessions: 45,
        cancelled: 3,
        noShowRate: '5%',
      ),
      topOrganizers: const [
        TopOrganizer(name: 'Azri', sessions: 12, revenue: 'RM 1,800'),
        TopOrganizer(name: 'Syafiq', sessions: 8, revenue: 'RM 1,200'),
        TopOrganizer(name: 'Danial', sessions: 6, revenue: 'RM 900'),
      ],
    );

    _data[RevenuePeriod.thisMonth] = _PeriodData(
      totalRevenue: 'RM 14,250',
      trend: '+8%',
      isTrendPositive: true,
      periodLabel: "THIS MONTH'S REVENUE",
      bars: const [
        ChartBar(value: 2000),
        ChartBar(value: 3500, isHighlighted: true),
        ChartBar(value: 4500, isHighlighted: true),
        ChartBar(value: 4250),
      ],
      dayLabels: const ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
      stats: const PeriodStats(
        sessions: 168,
        cancelled: 11,
        noShowRate: '8.5%',
      ),
      topOrganizers: const [
        TopOrganizer(name: 'Azri', sessions: 42, revenue: 'RM 6,300'),
        TopOrganizer(name: 'Hafiz', sessions: 30, revenue: 'RM 4,500'),
        TopOrganizer(name: 'Syafiq', sessions: 22, revenue: 'RM 3,300'),
      ],
    );

    _data[RevenuePeriod.allTime] = _PeriodData(
      totalRevenue: 'RM 98,400',
      trend: '+24%',
      isTrendPositive: true,
      periodLabel: 'ALL TIME REVENUE',
      bars: const [
        ChartBar(value: 5000),
        ChartBar(value: 7200),
        ChartBar(value: 9800),
        ChartBar(value: 11000),
        ChartBar(value: 14500),
        ChartBar(value: 18000, isHighlighted: true),
        ChartBar(value: 19200, isHighlighted: true),
        ChartBar(value: 13700),
      ],
      dayLabels: const ['Oct', 'Nov', 'Dec', 'Jan', 'Feb', 'Mar', 'Apr', 'May'],
      stats: const PeriodStats(
        sessions: 1240,
        cancelled: 87,
        noShowRate: '6.2%',
      ),
      topOrganizers: const [
        TopOrganizer(name: 'Azri', sessions: 310, revenue: 'RM 46,500'),
        TopOrganizer(name: 'Hafiz', sessions: 240, revenue: 'RM 36,000'),
        TopOrganizer(name: 'Syafiq', sessions: 198, revenue: 'RM 29,700'),
      ],
    );
  }
}

// ─── Internal Data Container ──────────────────────────────────────────────────

class _PeriodData {
  final String totalRevenue;
  final String trend;
  final bool isTrendPositive;
  final String periodLabel;
  final List<ChartBar> bars;
  final List<String> dayLabels;
  final PeriodStats stats;
  final List<TopOrganizer> topOrganizers;

  const _PeriodData({
    required this.totalRevenue,
    required this.trend,
    required this.isTrendPositive,
    required this.periodLabel,
    required this.bars,
    required this.dayLabels,
    required this.stats,
    required this.topOrganizers,
  });

  factory _PeriodData.empty() => _PeriodData(
        totalRevenue: 'RM 0',
        trend: '0%',
        isTrendPositive: true,
        periodLabel: '',
        bars: [],
        dayLabels: [],
        stats: const PeriodStats(sessions: 0, cancelled: 0, noShowRate: '0%'),
        topOrganizers: [],
      );
}