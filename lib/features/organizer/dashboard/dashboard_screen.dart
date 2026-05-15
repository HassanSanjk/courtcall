import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: const Center(
        // TODO: implement — KPI cards row + upcoming sessions list
        child: Text('TODO: implement'),
      ),
    );
  }
}
