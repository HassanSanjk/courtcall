import 'package:flutter_test/flutter_test.dart';
import 'package:courtcall/features/venue/venue_dashboard/venue_dashboard_viewmodel.dart';
import 'package:courtcall/features/venue/availability/availability_viewmodel.dart';
import 'package:courtcall/features/venue/cancellation_alert/cancellation_alert_viewmodel.dart';
import 'package:courtcall/features/venue/analytics/analytics_viewmodel.dart';
import 'package:courtcall/repositories/mocks/mock_venue_dashboard_repository.dart';
import 'package:courtcall/repositories/mocks/mock_availability_repository.dart';
import 'package:courtcall/repositories/mocks/mock_cancellation_repository.dart';
import 'package:courtcall/repositories/mocks/mock_analytics_repository.dart';

const _testVenueId = 'venue_1';

void main() {
  group('VenueDashboardViewModel', () {
    test('loads dashboard data from mock repo', () async {
      final vm = VenueDashboardViewModel(venueId: _testVenueId, repo: MockVenueDashboardRepository());
      addTearDown(() => vm.dispose());

      await Future(() {});
      expect(vm.state.venueName, 'Nexus Futsal');
      expect(vm.state.todayBookings, 12);
      expect(vm.state.expectedRevenue, 'RM 1.2k');
      expect(vm.state.courtNames.length, 3);
    });

    test('state contains greeting with owner name', () async {
      final vm = VenueDashboardViewModel(venueId: _testVenueId, repo: MockVenueDashboardRepository());
      addTearDown(() => vm.dispose());

      await Future(() {});
      expect(vm.state.greeting, contains('En. Hafiz'));
    });

    test('schedule and upcomingBookings are parsed', () async {
      final vm = VenueDashboardViewModel(venueId: _testVenueId, repo: MockVenueDashboardRepository());
      addTearDown(() => vm.dispose());

      await Future(() {});
      expect(vm.state.schedule.length, greaterThan(0));
      expect(vm.state.upcomingBookings.length, 3);
    });
  });

  group('AvailabilityViewModel', () {
    test('loads slots from mock repo and groups by day', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      expect(vm.isLoading, false);
      expect(vm.slots.length, greaterThan(0));
      expect(vm.groupedDays.length, greaterThan(0));
    });

    test('toggleSlot marks slot as available', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      vm.toggleSlot('slot_5', true);
      expect(vm.hasChanges, true);
      final toggled = vm.slots.firstWhere((s) => s['id'] == 'slot_5');
      expect(toggled['isEnabled'], true);
      expect(toggled['status'], 'available');
    });

    test('toggleSlot does nothing for booked slots', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      vm.toggleSlot('slot_4', true);
      final unchanged = vm.slots.firstWhere((s) => s['id'] == 'slot_4');
      expect(unchanged['isEnabled'], false);
    });

    test('selectCourt resets hasChanges', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      vm.toggleSlot('slot_5', true);
      expect(vm.hasChanges, true);
      vm.selectCourt(1);
      expect(vm.hasChanges, false);
      expect(vm.selectedCourtIndex, 1);
    });

    test('previousWeek and nextWeek update weekStart', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      final original = vm.weekRangeLabel;
      vm.previousWeek();
      expect(vm.weekRangeLabel, isNot(original));
      vm.nextWeek();
      expect(vm.weekRangeLabel, original);
    });

    test('saveChanges sets isSaving then clears', () async {
      final vm = AvailabilityViewModel(venueId: _testVenueId, repo: MockAvailabilityRepository());
      await Future.delayed(Duration.zero);

      vm.toggleSlot('slot_5', true);
      final saveFuture = vm.saveChanges();
      expect(vm.isSaving, true);
      await saveFuture;
      expect(vm.isSaving, false);
      expect(vm.hasChanges, false);
    });
  });

  group('CancellationAlertViewModel', () {
    test('loads cancellation alert from mock repo', () async {
      final vm = CancellationAlertViewModel(venueId: _testVenueId, repo: MockCancellationRepository());
      await Future.delayed(Duration.zero);

      expect(vm.isLoading, false);
      expect(vm.alert['sessionName'], 'Friday Futsal');
      expect(vm.alert['organizerName'], 'Azri');
    });

    test('noticeLabel returns correct format', () async {
      final vm = CancellationAlertViewModel(venueId: _testVenueId, repo: MockCancellationRepository());
      await Future.delayed(Duration.zero);

      expect(vm.noticeLabel, contains('2 HOURS'));
    });

    test('history lists cancellation events', () async {
      final vm = CancellationAlertViewModel(venueId: _testVenueId, repo: MockCancellationRepository());
      await Future.delayed(Duration.zero);

      expect(vm.history.length, 2);
      expect(vm.history[0]['highlightText'], '3 times');
    });

    test('markSlotAvailable flips isMarkingAvailable', () async {
      final vm = CancellationAlertViewModel(venueId: _testVenueId, repo: MockCancellationRepository());
      await Future.delayed(Duration.zero);

      final future = vm.markSlotAvailable();
      expect(vm.isMarkingAvailable, true);
      await future;
      expect(vm.isMarkingAvailable, false);
    });
  });

  group('AnalyticsViewModel', () {
    test('loads analytics data from mock repo', () async {
      final vm = AnalyticsViewModel(venueId: _testVenueId, repo: MockAnalyticsRepository());
      await Future.delayed(Duration.zero);

      expect(vm.isLoading, false);
      expect(vm.totalRevenue, isNotEmpty);
      expect(vm.selectedPeriod, 'thisWeek');
    });

    test('period switching changes data', () async {
      final vm = AnalyticsViewModel(venueId: _testVenueId, repo: MockAnalyticsRepository());
      await Future.delayed(Duration.zero);

      expect(vm.sessions, 45);
      expect(vm.periodLabel, "THIS WEEK'S REVENUE");

      vm.selectPeriod('thisMonth');
      await Future.delayed(Duration.zero);

      expect(vm.selectedPeriod, 'thisMonth');
      expect(vm.periodLabel, "THIS MONTH'S REVENUE");
    });

    test('bars and dayLabels populated', () async {
      final vm = AnalyticsViewModel(venueId: _testVenueId, repo: MockAnalyticsRepository());
      await Future.delayed(Duration.zero);

      expect(vm.bars.length, 7);
      expect(vm.dayLabels.length, 7);
    });

    test('topOrganizers parsed correctly', () async {
      final vm = AnalyticsViewModel(venueId: _testVenueId, repo: MockAnalyticsRepository());
      await Future.delayed(Duration.zero);

      expect(vm.topOrganizers.length, greaterThan(0));
      expect(vm.topOrganizers[0]['name'], 'Azri');
    });
  });
}
