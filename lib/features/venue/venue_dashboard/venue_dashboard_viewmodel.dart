// features/venue/venue_dashboard/venue_dashboard_viewmodel.dart

import 'package:flutter/foundation.dart';
import '../../../repositories/firebase/firebase_venue_dashboard_repository.dart';
import '../../../repositories/venue_dashboard_repository.dart';

class VenueDashboardState {
  final Map<String, dynamic> data;
  final bool isLoading;
  final int selectedNavIndex;

  const VenueDashboardState({
    this.data = const {},
    this.isLoading = true,
    this.selectedNavIndex = 0,
  });

  VenueDashboardState copyWith({
    Map<String, dynamic>? data,
    bool? isLoading,
    int? selectedNavIndex,
  }) {
    return VenueDashboardState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      selectedNavIndex: selectedNavIndex ?? this.selectedNavIndex,
    );
  }

  String get venueName => data['venueName'] ?? '';
  String get greeting => _buildGreeting(data['ownerName'] ?? '');
  int get todayBookings => data['todayBookings'] ?? 0;
  String get expectedRevenue => data['expectedRevenue'] ?? '';
  List<dynamic> get courtNames => data['courtNames'] ?? [];
  List<dynamic> get schedule => data['schedule'] ?? [];
  List<dynamic> get upcomingBookings => data['upcomingBookings'] ?? [];

  String _buildGreeting(String name) {
    final hour = DateTime.now().hour;
    final period = hour < 12 ? 'morning' : hour < 17 ? 'afternoon' : 'evening';
    return 'Good $period, $name';
  }
}

class VenueDashboardViewModel extends ChangeNotifier {
  final VenueDashboardRepository _repo;
  final String _venueId;
  VenueDashboardState _state = const VenueDashboardState();

  VenueDashboardState get state => _state;

  VenueDashboardViewModel({VenueDashboardRepository? repo, required String venueId})
      : _repo = repo ?? FirebaseVenueDashboardRepository(),
        _venueId = venueId {
    _init();
  }

  void _init() {
    _repo.watchDashboardData(_venueId).listen((data) {
      _state = _state.copyWith(data: data, isLoading: false);
      notifyListeners();
    });
  }

  void onNavTap(int index) {
    _state = _state.copyWith(selectedNavIndex: index);
    notifyListeners();
  }
}
