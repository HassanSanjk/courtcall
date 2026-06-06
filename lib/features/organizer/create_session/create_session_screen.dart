import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'create_session_viewmodel.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  static const _navy = Color(0xFF1B2A4A);
  static const _lightGrey = Color(0xFFEFF1F4);

  final venueController = TextEditingController();
  final costController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
    venueController.dispose();
    costController.dispose();
    notesController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: _navy,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _sportTab(String sport, CreateSessionViewModel vm) {
    final isSelected = vm.selectedSport == sport;
    return Expanded(
      child: GestureDetector(
        onTap: () => vm.setSport(sport),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _navy : _lightGrey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            sport,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : _navy,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(CreateSessionViewModel vm) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) vm.setDate(picked);
  }

  Future<void> _pickStartTime(CreateSessionViewModel vm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.startTime ?? TimeOfDay.now(),
    );
    if (picked != null) vm.setStartTime(picked);
  }

  Future<void> _pickEndTime(CreateSessionViewModel vm) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: vm.endTime ?? TimeOfDay.now(),
    );
    if (picked != null) vm.setEndTime(picked);
  }

  Widget _tappableField({
    required String hint,
    required String? displayValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          displayValue ?? hint,
          style: TextStyle(
            color: displayValue != null ? _navy : const Color(0xFF9E9E9E),
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Future<void> _submit(CreateSessionViewModel vm) async {
    final success = await vm.createSession(
      venue: venueController.text,
      cost: costController.text,
      notes: notesController.text,
    );
    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(vm.errorMessage!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreateSessionViewModel>();

    final dateText = vm.selectedDate != null
        ? DateFormat('EEEE, d MMMM yyyy').format(vm.selectedDate!)
        : null;
    final startText = vm.startTime?.format(context);
    final endText = vm.endTime?.format(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'New Session',
          style: TextStyle(color: _navy, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: _navy),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Sport Selector
            Row(
              children: [
                _sportTab('Futsal', vm),
                const SizedBox(width: 10),
                _sportTab('Badminton', vm),
              ],
            ),

            // 2. Venue
            const SizedBox(height: 16),
            _label('Venue'),
            const SizedBox(height: 6),
            TextField(
              controller: venueController,
              decoration: _fieldDecoration('Nexus Futsal, Cheras'),
            ),

            // 3. Date
            const SizedBox(height: 16),
            _label('Date'),
            const SizedBox(height: 6),
            _tappableField(
              hint: 'Tap to pick a date',
              displayValue: dateText,
              onTap: () => _pickDate(vm),
            ),

            // 4. Start Time / End Time
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('Start Time'),
                      const SizedBox(height: 6),
                      _tappableField(
                        hint: 'Tap to pick',
                        displayValue: startText,
                        onTap: () => _pickStartTime(vm),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _label('End Time'),
                      const SizedBox(height: 6),
                      _tappableField(
                        hint: 'Tap to pick',
                        displayValue: endText,
                        onTap: () => _pickEndTime(vm),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 5. Max Players Stepper
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Max Players',
                    style: TextStyle(
                      color: _navy,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: _navy),
                        onPressed: vm.maxPlayers > 2
                            ? () => vm.setMaxPlayers(vm.maxPlayers - 1)
                            : null,
                      ),
                      Text(
                        '${vm.maxPlayers}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _navy,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline,
                            color: _navy),
                        onPressed: () => vm.setMaxPlayers(vm.maxPlayers + 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 6. Cost Per Player
            const SizedBox(height: 16),
            _label('Cost Per Player'),
            const SizedBox(height: 6),
            TextField(
              controller: costController,
              keyboardType: TextInputType.number,
              decoration: _fieldDecoration('RM 15.00'),
            ),

            // 7. Session Notes
            const SizedBox(height: 16),
            _label('Session Notes'),
            const SizedBox(height: 6),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: _fieldDecoration('Any rules or notes...'),
            ),

            // 8. Submit Button
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: vm.isSaving ? null : () => _submit(vm),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _navy,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: vm.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Create & Invite Squad',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
