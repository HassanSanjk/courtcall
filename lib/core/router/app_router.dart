import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/login/login_screen.dart';
import '../../features/auth/role_selection/role_selection_screen.dart';
import '../../features/venue/venue_dashboard/venue_dashboard_screen.dart';
import '../../features/venue/availability/availability_screen.dart';
import '../../features/venue/setup/venue_setup_screen.dart';
import '../../features/venue/cancellation_alert/cancellation_alert_screen.dart';
import '../../features/venue/analytics/analytics_screen.dart';
import '../../features/player/session_feed/session_feed_screen.dart';
import '../../features/player/rsvp_confirmation/rsvp_confirmation_screen.dart';
import '../../features/player/payment_history/payment_history_screen.dart';
import '../../features/organizer/dashboard/dashboard_screen.dart';
import '../../features/organizer/create_session/create_session_screen.dart';
import '../../features/organizer/rsvp_tracker/rsvp_tracker_screen.dart';
import '../../features/organizer/payment_ledger/payment_ledger_screen.dart';
import '../../features/organizer/cancellation/cancellation_screen.dart';
import '../../features/maps/map_screen.dart';
import '../../models/models.dart';
import '../../dev_menu.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/login',
    ),
    GoRoute(
      path: '/dev-menu',
      builder: (context, state) => const DevMenu(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginScreen(),
    ),
    GoRoute(
      path: '/role-selection',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        final password = state.uri.queryParameters['password'] ?? '';
        return RoleSelectionScreen(email: email, password: password);
      },
    ),
    GoRoute(
      path: '/venue/setup',
      builder: (context, state) => const VenueSetupScreen(),
    ),
    GoRoute(
      path: '/venue/dashboard',
      builder: (context, state) {
        final venueId = state.uri.queryParameters['venueId'];
        return VenueDashboardScreen(venueId: venueId);
      },
    ),
    GoRoute(
      path: '/venue/availability',
      builder: (context, state) {
        final venueId = state.uri.queryParameters['venueId'] ?? '';
        return AvailabilityScreen(venueId: venueId);
      },
    ),
    GoRoute(
      path: '/venue/cancellation-alert',
      builder: (context, state) {
        final venueId = state.uri.queryParameters['venueId'] ?? '';
        return CancellationAlertScreen(venueId: venueId);
      },
    ),
    GoRoute(
      path: '/venue/analytics',
      builder: (context, state) {
        final venueId = state.uri.queryParameters['venueId'] ?? '';
        return AnalyticsScreen(venueId: venueId);
      },
    ),
    GoRoute(
      path: '/player/session-feed',
      builder: (context, state) => SessionFeedScreen(),
    ),
    GoRoute(
      path: '/player/rsvp-confirmation',
      builder: (context, state) {
        final session = state.extra as Session?;
        if (session == null) {
          return const Scaffold(
            body: Center(child: Text('No session provided')),
          );
        }
        return RsvpConfirmationScreen(session: session);
      },
    ),
    GoRoute(
      path: '/player/payment-history',
      builder: (context, state) => PaymentHistoryScreen(),
    ),
    GoRoute(
      path: '/organizer/dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/organizer/create-session',
      builder: (context, state) => const CreateSessionScreen(),
    ),
    GoRoute(
      path: '/organizer/rsvp-tracker',
      builder: (context, state) => const RsvpTrackerScreen(),
    ),
    GoRoute(
      path: '/organizer/payment-ledger',
      builder: (context, state) => const PaymentLedgerScreen(),
    ),
    GoRoute(
      path: '/organizer/cancellation',
      builder: (context, state) => const CancellationScreen(),
    ),
    GoRoute(
      path: '/maps',
      builder: (context, state) => const MapScreen(),
    ),
  ],
);
