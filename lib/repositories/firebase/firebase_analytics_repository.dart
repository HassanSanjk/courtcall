import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../analytics_repository.dart';

class FirebaseAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _db;

  FirebaseAnalyticsRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<Map<String, dynamic>> watchAnalytics(String venueId, String period) {
    final controller = StreamController<Map<String, dynamic>>();
    final range = _dateRangeFor(period);

    StreamSubscription? sub;
    sub = _db
        .collection('sessions')
        .where('venueId', isEqualTo: venueId)
        .where('dateTimestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(range.start))
        .where('dateTimestamp', isLessThan: Timestamp.fromDate(range.end))
        .orderBy('dateTimestamp', descending: false)
        .snapshots()
        .listen(
          (snapshot) {
            final sessions = snapshot.docs.map((d) => d.data()).toList();
            final data = _computeFromSessions(sessions, period);
            if (!controller.isClosed) controller.add(data);
          },
          onError: (e) {
            if (!controller.isClosed) controller.add(_emptyResult(period));
          },
        );

    controller.onCancel = () => sub?.cancel();
    return controller.stream;
  }

  Map<String, dynamic> _computeFromSessions(
    List<Map<String, dynamic>> sessions,
    String period,
  ) {
    final totalRevenue = sessions.fold<double>(
      0, (total, s) => total + (s['costPerPlayer'] ?? 0) * (s['rsvpCount'] ?? 0));
    final total = _formatCurrency(totalRevenue);

    final completed = sessions.where((s) => s['status'] == 'completed').length;
    final cancelled = sessions.where((s) => s['status'] == 'cancelled').length;
    final totalCount = sessions.length;
    final noShowRate = totalCount > 0 ? '${((cancelled / totalCount) * 100).toStringAsFixed(1)}%' : '0%';

    final barData = _buildBarData(sessions, period);
    final topOrgs = _buildTopOrganizers(sessions);

    return {
      'totalRevenue': total,
      'trend': '+${barData['trend']}%',
      'isTrendPositive': true,
      'periodLabel': _periodLabel(period),
      'bars': barData['bars'],
      'dayLabels': barData['dayLabels'],
      'sessions': completed,
      'cancelled': cancelled,
      'noShowRate': noShowRate,
      'topOrganizers': topOrgs,
    };
  }

  Map<String, dynamic> _emptyResult(String period) {
    return {
      'totalRevenue': 'RM 0',
      'trend': '0%',
      'isTrendPositive': true,
      'periodLabel': _periodLabel(period),
      'bars': <Map<String, dynamic>>[],
      'dayLabels': <String>[],
      'sessions': 0,
      'cancelled': 0,
      'noShowRate': '0%',
      'topOrganizers': <Map<String, dynamic>>[],
    };
  }

  ({DateTime start, DateTime end}) _dateRangeFor(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'thisWeek':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return (
          start: DateTime(weekStart.year, weekStart.month, weekStart.day),
          end: weekStart.add(const Duration(days: 7)),
        );
      case 'thisMonth':
        return (
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 1),
        );
      case 'allTime':
      default:
        return (
          start: DateTime(2020, 1, 1),
          end: now.add(const Duration(days: 365)),
        );
    }
  }

  Map<String, dynamic> _buildBarData(List<Map<String, dynamic>> sessions, String period) {
    if (sessions.isEmpty) {
      return {
        'bars': <Map<String, dynamic>>[],
        'dayLabels': <String>[],
        'trend': 0,
      };
    }

    if (period == 'thisWeek') {
      final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final daily = List.filled(7, 0.0);
      for (final s in sessions) {
        final ts = s['dateTimestamp'] as Timestamp?;
        if (ts != null) {
          final day = ts.toDate().weekday - 1;
          if (day >= 0 && day < 7) {
            daily[day] += (s['costPerPlayer'] ?? 0) * (s['rsvpCount'] ?? 0);
          }
        }
      }
      final maxVal = daily.reduce((a, b) => a > b ? a : b);
      return {
        'bars': daily.map((v) => {
          'value': v,
          'isHighlighted': v == maxVal && maxVal > 0,
        }).toList(),
        'dayLabels': dayNames,
        'trend': maxVal > 0 ? ((daily.last / (daily.first > 0 ? daily.first : 1)) * 100).toStringAsFixed(0) : 0,
      };
    }

    if (period == 'thisMonth') {
      final weekly = List.filled(4, 0.0);
      for (final s in sessions) {
        final ts = s['dateTimestamp'] as Timestamp?;
        if (ts != null) {
          final week = (ts.toDate().day - 1) ~/ 7;
          if (week < 4) {
            weekly[week] += (s['costPerPlayer'] ?? 0) * (s['rsvpCount'] ?? 0);
          }
        }
      }
      final maxVal = weekly.reduce((a, b) => a > b ? a : b);
      return {
        'bars': weekly.map((v) => {
          'value': v,
          'isHighlighted': v == maxVal && maxVal > 0,
        }).toList(),
        'dayLabels': ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4'],
        'trend': maxVal > 0 ? ((weekly.last / (weekly.first > 0 ? weekly.first : 1)) * 100).toStringAsFixed(0) : 0,
      };
    }

    // allTime — by month
    final monthly = <String, double>{};
    for (final s in sessions) {
      final ts = s['dateTimestamp'] as Timestamp?;
      if (ts != null) {
        final key = _monthKey(ts.toDate());
        monthly.update(key, (v) => v + (s['costPerPlayer'] ?? 0) * (s['rsvpCount'] ?? 0), ifAbsent: () => 0);
      }
    }
    final labels = monthly.keys.take(8).toList();
    final values = labels.map((k) => monthly[k] ?? 0).toList();
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    return {
      'bars': values.map((v) => {
        'value': v,
        'isHighlighted': v == maxVal && maxVal > 0,
      }).toList(),
      'dayLabels': labels,
      'trend': maxVal > 0 ? ((values.last / (values.first > 0 ? values.first : 1)) * 100).toStringAsFixed(0) : 0,
    };
  }

  List<Map<String, dynamic>> _buildTopOrganizers(List<Map<String, dynamic>> sessions) {
    final sessionCounts = <String, int>{};
    final revenueMap = <String, double>{};
    for (final s in sessions) {
      final name = s['organizerName'] as String? ?? 'Unknown';
      sessionCounts[name] = (sessionCounts[name] ?? 0) + 1;
      revenueMap[name] = (revenueMap[name] ?? 0) + (s['costPerPlayer'] ?? 0) * (s['rsvpCount'] ?? 0);
    }
    final sorted = sessionCounts.entries.toList()
      ..sort((a, b) => (revenueMap[b.key] ?? 0).compareTo(revenueMap[a.key] ?? 0));
    return sorted.take(5).map((e) => {
      'name': e.key,
      'sessions': sessionCounts[e.key] ?? 0,
      'revenue': _formatCurrency(revenueMap[e.key] ?? 0),
    }).toList();
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'thisWeek': return "THIS WEEK'S REVENUE";
      case 'thisMonth': return "THIS MONTH'S REVENUE";
      case 'allTime': return 'ALL TIME REVENUE';
      default: return 'REVENUE';
    }
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000) {
      return 'RM ${(amount / 1000).toStringAsFixed(1)}k';
    }
    return 'RM ${amount.toStringAsFixed(0)}';
  }

  String _monthKey(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[d.month - 1];
  }
}
