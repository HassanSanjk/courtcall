// app.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/organizer/dashboard/dashboard_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourtCall',
      theme: AppTheme.light,
      home: const DashboardScreen(),
    );
  }
}