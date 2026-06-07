import 'package:flutter/material.dart';

import '../features/auth/login/login_screen.dart';
import '../features/organizer/dashboard/dashboard_screen.dart';
import '../features/venue/venue_dashboard/venue_dashboard_screen.dart';
import '../core/widgets/player_shell_screen.dart';

void pushReplacementToLogin(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const LoginScreen()),
    (_) => false,
  );
}

void pushReplacementToHome(BuildContext context, String role) {
  final home = switch (role) {
    'organizer' => const DashboardScreen(),
    'venue_owner' => const VenueDashboardScreen(),
    _ => const PlayerShellScreen(),
  };
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => home),
    (_) => false,
  );
}
