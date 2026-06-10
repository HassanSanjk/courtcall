import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../repositories/cancellation_repository.dart';

class CancellationAlertViewModel extends ChangeNotifier {
  final CancellationRepository _repo;
  final String _venueId;

  Map<String, dynamic> _alert = {};
  bool isLoading = true;
  bool isMarkingAvailable = false;
  StreamSubscription? _sub;

  CancellationAlertViewModel({required CancellationRepository repo, required String venueId})
      : _repo = repo,
        _venueId = venueId {
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
    _sub?.cancel();
    _sub = _repo.watchCancellationAlert(_venueId).listen((data) {
      _alert = data;
      isLoading = false;
      notifyListeners();
    }, onError: (e) {
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> markSlotAvailable() async {
    isMarkingAvailable = true;
    notifyListeners();

    try {
      await _repo.markSlotAvailable(_venueId, _alert['slotId'] ?? '');
    } catch (_) {}

    isMarkingAvailable = false;
    notifyListeners();
  }

  Future<void> contactOrganizer() async {
    final phone = _alert['organizerPhone'] as String?;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}