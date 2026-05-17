// features/venue/cancellation_alert/cancellation_alert_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/cancellation_repository.dart';
import '../../../repositories/mocks/mock_cancellation_repository.dart';

class CancellationAlertViewModel extends ChangeNotifier {
  final CancellationRepository _repo;

  Map<String, dynamic> _alert = {};
  bool isLoading = true;
  bool isMarkingAvailable = false;

  CancellationAlertViewModel({CancellationRepository? repo})
      : _repo = repo ?? MockCancellationRepository() {
    _init();
  }

  Map<String, dynamic> get alert => _alert;
  List<dynamic> get history => _alert['history'] ?? [];

  String get noticeLabel {
    final hours = (_alert['noticeHours'] as int?) ?? 0;
    if (hours < 1) return 'LESS THAN 1 HOUR NOTICE';
    if (hours == 1) return '1 HOUR NOTICE';
    return '$hours HOURS NOTICE';
  }

  void _init() {
    _repo.watchCancellationAlert('venue_1').listen((data) {
      _alert = data;
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markSlotAvailable() async {
    isMarkingAvailable = true;
    notifyListeners();

    await _repo.markSlotAvailable('venue_1', _alert['slotId'] ?? '');

    isMarkingAvailable = false;
    notifyListeners();
  }

  void contactOrganizer() {
    // Replace with url_launcher: tel:${_alert['organizerPhone']}
    debugPrint('Contacting: ${_alert['organizerName']}');
  }
}