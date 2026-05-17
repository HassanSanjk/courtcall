// features/venue/cancellation_alert/cancellation_alert_viewmodel.dart

import 'package:flutter/foundation.dart';

// ─── Models ────────────────────────────────────────────────────────────────────

class CancellationAlert {
  final String sessionName;
  final String organizerName;
  final String court;
  final String timeRange;
  final String dateLabel;
  final String lostRevenue;
  final String? depositCollected;
  final int noticeHours; // hours notice given before cancellation

  const CancellationAlert({
    required this.sessionName,
    required this.organizerName,
    required this.court,
    required this.timeRange,
    required this.dateLabel,
    required this.lostRevenue,
    this.depositCollected,
    required this.noticeHours,
  });
}

class CancellationHistoryItem {
  final String prefixText;
  final String highlightText;
  final String suffixText;
  final bool isWarning; // true = orange dot, false = green dot

  const CancellationHistoryItem({
    required this.prefixText,
    required this.highlightText,
    required this.suffixText,
    required this.isWarning,
  });
}

// ─── ViewModel ─────────────────────────────────────────────────────────────────

class CancellationAlertViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────────────────────────

  bool isLoading = true;
  bool isMarkingAvailable = false;
  bool slotMarkedAvailable = false;

  CancellationAlert? alert;
  List<CancellationHistoryItem> cancellationHistory = [];

  // ── Computed ───────────────────────────────────────────────────────────────

  String get noticeLabel {
    final hours = alert?.noticeHours ?? 0;
    if (hours < 1) return 'LESS THAN 1 HOUR NOTICE';
    if (hours == 1) return '1 HOUR NOTICE';
    return '$hours HOURS NOTICE';
  }

  // ── Public Methods ─────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _loadAlert();
    _loadCancellationHistory();

    isLoading = false;
    notifyListeners();
  }

  Future<void> markSlotAvailable() async {
    isMarkingAvailable = true;
    notifyListeners();

    // Simulate API call — replace with SlotRepository.markAvailable() later
    await Future.delayed(const Duration(seconds: 1));

    isMarkingAvailable = false;
    slotMarkedAvailable = true;
    notifyListeners();
  }

  void contactOrganizer() {
    // Replace with url_launcher: launchUrl(tel:${alert.organizerPhone})
    debugPrint('Contacting organizer: ${alert?.organizerName}');
  }

  // ── Private Loaders (mock data) ────────────────────────────────────────────

  void _loadAlert() {
    alert = const CancellationAlert(
      sessionName: 'Friday Futsal',
      organizerName: 'Azri',
      court: 'Court 1',
      timeRange: '8:00 PM – 10:00 PM',
      dateLabel: '9 May 2026, Friday',
      lostRevenue: 'RM 120',
      depositCollected: 'RM 50 deposit was collected.',
      noticeHours: 2,
    );
  }

  void _loadCancellationHistory() {
    cancellationHistory = const [
      CancellationHistoryItem(
        prefixText: 'Azri has cancelled ',
        highlightText: '3 times',
        suffixText: ' this month.',
        isWarning: true,
      ),
      CancellationHistoryItem(
        prefixText: 'Azri has completed ',
        highlightText: '12 sessions',
        suffixText: ' successfully.',
        isWarning: false,
      ),
    ];
  }
}