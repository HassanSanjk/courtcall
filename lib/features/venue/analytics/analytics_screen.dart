// features/venue/analytics/analytics_screen.dart

import 'package:flutter/material.dart';
import 'analytics_viewmodel.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late final AnalyticsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AnalyticsViewModel();
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeroChart(),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatStrip(),
                                const SizedBox(height: 24),
                                _buildTopOrganizers(),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Revenue Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  // ─── Hero Chart Section ────────────────────────────────────────────────────

  Widget _buildHeroChart() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period tabs
          _buildPeriodTabs(),
          const SizedBox(height: 20),

          // Revenue amount + trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _viewModel.totalRevenue,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              _TrendBadge(
                  label: _viewModel.revenueTrend,
                  isPositive: _viewModel.isTrendPositive),
            ],
          ),
          Text(
            _viewModel.periodLabel,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.55),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 24),

          // Bar chart
          _BarChart(
            bars: _viewModel.chartBars,
            dayLabels: _viewModel.dayLabels,
          ),
        ],
      ),
    );
  }

  // ─── Period Tabs ───────────────────────────────────────────────────────────

  Widget _buildPeriodTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: RevenuePeriod.values.map((period) {
          final isSelected = _viewModel.selectedPeriod == period;
          return GestureDetector(
            onTap: () => _viewModel.selectPeriod(period),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color:
                    isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                period.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF1A1A2E)
                      : Colors.white.withOpacity(0.7),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Stat Strip ───────────────────────────────────────────────────────────

  Widget _buildStatStrip() {
    final stats = _viewModel.stats;
    return Container(
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
      child: Row(
        children: [
          _StatStripTile(
            label: 'SESSIONS',
            value: '${stats.sessions}',
            color: const Color(0xFF1A1A2E),
            isFirst: true,
          ),
          _StatStripTile(
            label: 'CANCELLED',
            value: '${stats.cancelled}',
            color: const Color(0xFFD92B2B),
          ),
          _StatStripTile(
            label: 'NO-SHOW',
            value: stats.noShowRate,
            color: const Color(0xFFFBB040),
            isLast: true,
          ),
        ],
      ),
    );
  }

  // ─── Top Organizers ────────────────────────────────────────────────────────

  Widget _buildTopOrganizers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Organizers',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 12),
        ..._viewModel.topOrganizers.asMap().entries.map(
              (e) => _OrganizerTile(
                rank: e.key + 1,
                organizer: e.value,
              ),
            ),
      ],
    );
  }
}

// ─── Bar Chart ─────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<ChartBar> bars;
  final List<String> dayLabels;

  const _BarChart({required this.bars, required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    final maxValue =
        bars.fold<double>(1, (prev, b) => b.value > prev ? b.value : prev);

    return SizedBox(
      height: 120,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: bars.map((bar) {
                final heightFraction = bar.value / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 600),
                          curve: Curves.easeOut,
                          height: 75 * heightFraction,
                          decoration: BoxDecoration(
                            color: bar.isHighlighted
                                ? const Color(0xFF00E676)
                                : const Color(0xFF00E676).withOpacity(0.45),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dayLabels
                .map(
                  (d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Trend Badge ───────────────────────────────────────────────────────────────

class _TrendBadge extends StatelessWidget {
  final String label;
  final bool isPositive;

  const _TrendBadge({required this.label, required this.isPositive});

  @override
  Widget build(BuildContext context) {
    final color =
        isPositive ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Strip Tile ───────────────────────────────────────────────────────────

class _StatStripTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _StatStripTile({
    required this.label,
    required this.value,
    required this.color,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            right: isLast
                ? BorderSide.none
                : const BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Organizer Tile ────────────────────────────────────────────────────────────

class _OrganizerTile extends StatelessWidget {
  final int rank;
  final TopOrganizer organizer;

  const _OrganizerTile({required this.rank, required this.organizer});

  Color get _rankColor {
    if (rank == 1) return const Color(0xFFFBB040);
    if (rank == 2) return const Color(0xFF9CA3AF);
    return const Color(0xFFCD7F32);
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
          // Rank badge
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _rankColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _rankColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1A1A2E),
            child: Text(
              organizer.name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name + sessions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  organizer.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${organizer.sessions} sessions booked',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          // Revenue
          Text(
            organizer.revenue,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D7A3E),
            ),
          ),
        ],
      ),
    );
  }
}