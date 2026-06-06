import 'package:flutter/material.dart';

class CancellationScreen extends StatelessWidget {
  const CancellationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cancel Session')),
      body: const Center(
        // TODO: implement — confirmation dialog and reason input before cancelSession()
        child: Text('TODO: implement'),
      ),
    );
  }
}
