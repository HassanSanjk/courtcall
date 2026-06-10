

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:courtcall/core/theme/app_colors.dart';
import 'package:courtcall/repositories/analytics_repository.dart';
import 'package:courtcall/repositories/firebase/firebase_analytics_repository.dart';
import 'analytics_viewmodel.dart';

class AnalyticsScreen extends StatelessWidget {
  final String venueId;

  const AnalyticsScreen({super.key, required this.venueId, this.repo});

  final AnalyticsRepository? repo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AnalyticsViewModel(
        repo: repo ?? FirebaseAnalyticsRepository(),
        venueId: venueId,
      ),
      child: _AnalyticsBody(venueId: venueId),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  final String venueId;

  const _AnalyticsBody({required this.venueId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AnalyticsViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 420;
                  final pad = isWide ? 24.0 : 16.0;
                  return Column(
                    children: [
                      _buildHeader(context, pad, vm),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeroChart(pad, vm),
                              Padding(
                                padding: EdgeInsets.all(pad),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildStatStrip(vm),
                                    const SizedBox(height: 24),
                                    _buildTopOrganizers(vm),
                                    const SizedBox(height: 16),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, double pad, AnalyticsViewModel vm) {
    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: const Text('Revenue Analytics',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildHeroChart(double pad, AnalyticsViewModel vm) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A2E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(pad + 4, 8, pad + 4, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPeriodTabs(vm),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(vm.totalRevenue,
                  style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              const SizedBox(width: 12),
              _TrendBadge(
                  label: vm.trend,
                  isPositive: vm.isTrendPositive),
            ],
          ),
          Text(vm.periodLabel,
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 0.5)),
          const SizedBox(height: 24),
          _BarChart(
            bars: vm.bars,
            dayLabels: vm.dayLabels,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodTabs(AnalyticsViewModel vm) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: vm.periods.map((period) {
          final isSelected = vm.selectedPeriod == period['key'];
          return GestureDetector(
            onTap: () => vm.selectPeriod(period['key']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${period['label']}',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? const Color(0xFF1A1A2E)
                          : Colors.white.withValues(alpha: 0.7))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatStrip(AnalyticsViewModel vm) {
    return Container(
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
      child: Row(
        children: [
          _StatTile(
              label: 'SESSIONS',
              value: '${vm.sessions}',
              color: AppColors.onSurface,
              isLast: false),
          _StatTile(
              label: 'CANCELLED',
              value: '${vm.cancelled}',
              color: AppColors.error,
              isLast: false),
          _StatTile(
              label: 'NO-SHOW',
              value: vm.noShowRate,
              color: AppColors.amber,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildTopOrganizers(AnalyticsViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top Organizers',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface)),
        const SizedBox(height: 12),
        ...vm.topOrganizers.asMap().entries.map((entry) {
          final organizer =
              (entry.value as Map).cast<String, dynamic>();
          return _OrganizerTile(rank: entry.key + 1, organizer: organizer);
        }),
      ],
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final List<dynamic> bars;
  final List<dynamic> dayLabels;

  const _BarChart({required this.bars, required this.dayLabels});

  @override
  Widget build(BuildContext context) {
    final maxValue = bars.fold<double>(
        1, (prev, b) => (b['value'] as double) > prev ? b['value'] : prev);

    return SizedBox(
      height: 120,
      child: Stack(
        children: [
          CustomPaint(
            size: const Size(double.infinity, 120),
            painter: _GridPainter(),
          ),
          Positioned(
            top: 0,
            right: 4,
            child: Text('RM ${maxValue.toStringAsFixed(0)}',
                style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.35))),
          ),
          Column(
            children: [
              const SizedBox(height: 14),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: bars.map((bar) {
                    final fraction = (bar['value'] as double) / maxValue;
                    final isHighlighted = bar['isHighlighted'] == true;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              height: 75 * fraction,
                              decoration: BoxDecoration(
                                color: isHighlighted
                                    ? const Color(0xFF00E676)
                                    : const Color(0xFF00E676).withValues(alpha: 0.45),
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
                    .map((d) => Expanded(
                          child: Text('$d',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white.withValues(alpha: 0.55))),
                        ))
                    .toList(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x15FFFFFF)
      ..strokeWidth = 0.5;

    final gridBottom = size.height - 24.0;
    const gridHeight = 75.0;

    for (final pct in [0.25, 0.50, 0.75]) {
      final y = gridBottom - (gridHeight * pct);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPositive ? Icons.trending_up : Icons.trending_down,
              color: color, size: 14),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isLast;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
    required this.isLast,
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
                : const BorderSide(color: AppColors.outline),
          ),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5)),
          ],
        ),
      ),
    );
  }
}

class _OrganizerTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> organizer;

  const _OrganizerTile({required this.rank, required this.organizer});

  Color get _rankColor {
    if (rank == 1) return AppColors.rankGold;
    if (rank == 2) return AppColors.rankSilver;
    return AppColors.rankBronze;
  }

  @override
  Widget build(BuildContext context) {
    final name = '${organizer['name']}';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('$rank',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _rankColor)),
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.darkNavy,
            child: Text(name[0].toUpperCase(),
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface)),
                Text('${organizer['sessions']} sessions booked',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text('${organizer['revenue']}',
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary)),
        ],
      ),
    );
  }
}