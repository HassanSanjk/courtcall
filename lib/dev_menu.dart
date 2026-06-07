// lib/dev_menu.dart

import 'package:flutter/material.dart';
import 'seed_firestore.dart';
import 'features/player/payment_history/payment_history_screen.dart';
import 'core/widgets/player_shell_screen.dart';
import 'features/venue/venue_dashboard/venue_dashboard_screen.dart';
import 'features/venue/availability/availability_screen.dart';
import 'features/venue/cancellation_alert/cancellation_alert_screen.dart';
import 'features/venue/analytics/analytics_screen.dart';
import 'features/organizer/dashboard/dashboard_screen.dart';

class DevMenu extends StatelessWidget {
  const DevMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final screens = [
      ('Player: Session Feed', '/player/session-feed'),
      ('Player: Payment History', '/player/payment-history'),
      ('Venue Dashboard', '/venue/dashboard'),
      ('Availability', '/venue/availability'),
      ('Cancellation Alert', '/venue/cancellation-alert'),
      ('Analytics', '/venue/analytics'),
      ('Organizer Dashboard', '/organizer/dashboard'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'Dev Screen Picker',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Seed button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => seedFirestore(context),
                icon: const Icon(Icons.cloud_upload_outlined,
                    color: Colors.white, size: 18),
                label: const Text(
                  'Seed Firestore',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D7A3E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap once. Check Firebase Console to confirm.',
              style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 16),

            // ── Screen list ──────────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                itemCount: screens.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final (label, path) = screens[index];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    title: Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right,
                        color: Color(0xFF9CA3AF)),
                    onTap: () {
                      final screen = switch (path) {
                        '/player/session-feed' => const PlayerShellScreen(),
                        '/player/payment-history' => const PaymentHistoryScreen(),
                        '/venue/dashboard' => const VenueDashboardScreen(),
                        '/venue/availability' => const AvailabilityScreen(venueId: ''),
                        '/venue/cancellation-alert' => const CancellationAlertScreen(venueId: ''),
                        '/venue/analytics' => const AnalyticsScreen(venueId: ''),
                        '/organizer/dashboard' => const DashboardScreen(),
                        _ => const Scaffold(body: Center(child: Text('Unknown path'))),
                      };
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => screen),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}