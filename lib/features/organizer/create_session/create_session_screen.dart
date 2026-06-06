import 'package:flutter/material.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  // ===== Form state =====
  // These variables hold what the user has selected/typed.
  // When they change, the screen redraws via setState().

  String selectedSport = 'Futsal';
  int maxPlayers = 12;
  DateTime? selectedDate;          // ? means it can be null (nothing picked yet)

  // ===== Controllers for text inputs =====
  // A controller lets you read what the user typed into a TextField.
  final venueController = TextEditingController();
  final costController = TextEditingController();
  final notesController = TextEditingController();

  // ===== Clean up controllers when screen is destroyed =====
  // Without this you get a memory leak warning. Flutter calls dispose()
  // automatically when the screen is closed.
  @override
  void dispose() {
    venueController.dispose();
    costController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Session',
          style: TextStyle(
            color: Color(0xFF1B2A4A),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1B2A4A)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ↓↓↓ Form pieces will go here ↓↓↓

            const Text('Form goes here — start building!'),

          ],
        ),
      ),
    );
  }
}