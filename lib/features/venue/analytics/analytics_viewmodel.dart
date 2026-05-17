// features/venue/analytics/analytics_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/analytics_repository.dart';
import '../../../repositories/mocks/mock_analytics_repository.dart';

class AnalyticsViewModel extends ChangeNotifier {
  final AnalyticsRepository _repo;

  Map<String, dynamic> _data = {};
  bool isLoading = true;
  String selectedPeriod = 'thisWeek';

  final List<Map<String, dynamic>> periods = [
    {'key': 'thisWeek', 'label': 'This Week'},
    {'key': 'thisMonth', 'label': 'This Month'},
    {'key': 'allTime', 'label': 'All Time'},
  ];

  AnalyticsViewModel({AnalyticsRepository? repo})
      : _repo = repo ?? MockAnalyticsRepository() {
    _init();
  }

  Map<String, dynamic> get data => _data;

  String get totalRevenue => _data['totalRevenue'] ?? '';
  String get trend => _data['trend'] ?? '';
  bool get isTrendPositive => _data['isTrendPositive'] == true;
  String get periodLabel => _data['periodLabel'] ?? '';
  List<dynamic> get bars => _data['bars'] ?? [];
  List<dynamic> get dayLabels => _data['dayLabels'] ?? [];
  int get sessions => _data['sessions'] ?? 0;
  int get cancelled => _data['cancelled'] ?? 0;
  String get noShowRate => _data['noShowRate'] ?? '0%';
  List<dynamic> get topOrganizers => _data['topOrganizers'] ?? [];

  void _init() {
    _repo.watchAnalytics('venue_1', selectedPeriod).listen((data) {
      _data = data;
      isLoading = false;
      notifyListeners();
    });
  }

  void selectPeriod(String periodKey) {
    selectedPeriod = periodKey;
    isLoading = true;
    notifyListeners();
    _init();
  }
}