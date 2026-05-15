import 'package:flutter/material.dart';

// TODO: Wire up go_router, MultiProvider (all repositories + viewmodels), and AppTheme here.
class CourtCallApp extends StatelessWidget {
  const CourtCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(body: Center(child: Text('CourtCall'))),
    );
  }
}
