import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../../features/auth/auth_viewmodel.dart';
import '../../features/auth/login/login_screen.dart';
import '../../features/player/session_feed/session_feed_screen.dart';
import '../../features/maps/map_screen.dart';
import '../../features/player/payment_history/payment_history_screen.dart';

class PlayerShellScreen extends StatefulWidget {
  const PlayerShellScreen({super.key});

  @override
  State<PlayerShellScreen> createState() => _PlayerShellScreenState();
}

class _PlayerShellScreenState extends State<PlayerShellScreen> {
  int _currentIndex = 0;

  final _screens = const [
    SessionFeedScreen(),
    MapScreen(),
    PaymentHistoryScreen(),
  ];

  Future<void> _signOut() async {
    final nav = Navigator.of(context);
    await context.read<AuthViewModel>().signOut();
    if (!mounted) return;
    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _onNavTap(int index) {
    if (index == 3) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onNavTap,
        indicatorColor: AppColors.darkNavy.withValues(alpha: 0.12),
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.payments_outlined),
            selectedIcon: Icon(Icons.payments_rounded),
            label: 'Payments',
          ),
          NavigationDestination(
            icon: Icon(Icons.logout_rounded),
            label: 'Sign Out',
          ),
        ],
      ),
    );
  }
}
