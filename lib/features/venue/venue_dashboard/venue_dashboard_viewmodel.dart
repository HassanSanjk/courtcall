// features/venue/venue_dashboard/venue_dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/venue_dashboard_repository.dart';
import '../../../repositories/mocks/mock_venue_dashboard_repository.dart';

class VenueDashboardViewModel extends ChangeNotifier {
  final VenueDashboardRepository _repo;

  Map<String, dynamic> _data = {};
  bool isLoading = true;
  int selectedNavIndex = 0;

  VenueDashboardViewModel({VenueDashboardRepository? repo})
      : _repo = repo ?? MockVenueDashboardRepository() {
    _init();
  }

  String get venueName => _data['venueName'] ?? '';
  String get greeting => _buildGreeting(_data['ownerName'] ?? '');
  int get todayBookings => _data['todayBookings'] ?? 0;
  String get expectedRevenue => _data['expectedRevenue'] ?? '';
  List<dynamic> get courtNames => _data['courtNames'] ?? [];
  List<dynamic> get schedule => _data['schedule'] ?? [];
  List<dynamic> get upcomingBookings => _data['upcomingBookings'] ?? [];

  void _init() {
    _repo.watchDashboardData('venue_1').listen((data) {
      _data = data;
      isLoading = false;
      notifyListeners();
    });
  }

  void onNavTap(int index) {
    selectedNavIndex = index;
    notifyListeners();
  }

  String _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    return 'Good $period, $name';
  }
}