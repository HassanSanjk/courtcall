import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/sports.dart';
import '../../../core/theme/app_colors.dart';
import 'create_session_viewmodel.dart';

class CreateSessionScreen extends StatefulWidget {
  const CreateSessionScreen({super.key});

  @override
  State<CreateSessionScreen> createState() => _CreateSessionScreenState();
}

class _CreateSessionScreenState extends State<CreateSessionScreen> {
  static const _navy = Color(0xFF1B2A4A);

  final costController = TextEditingController();
  final notesController = TextEditingController();

  @override
  void dispose() {
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

  void _pickVenue(BuildContext context, CreateSessionViewModel vm) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.55,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Select Venue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Divider(height: 1),
              if (vm.venues.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No venues found.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: vm.venues.map((venue) => ListTile(
                      title: Text(venue.name,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(venue.address,
                          style: const TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        vm.setVenue(venue);
                        Navigator.pop(context);
                      },
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
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
        child: Row(
          children: [
            Expanded(
              child: Text(
                displayValue ?? hint,
                style: TextStyle(
                  color: displayValue != null ? _navy : const Color(0xFF9E9E9E),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: Color(0xFF9E9E9E)),
          ],
        ),
      ),
    );
  }

  Future<void> _submit(CreateSessionViewModel vm) async {
    final success = await vm.createSession(
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
    final venueText = vm.selectedVenue?.name;

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
            _label('Sport'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: vm.selectedSport,
              decoration: _fieldDecoration('Select sport'),
              isExpanded: true,
              items: allSports.map((s) => DropdownMenuItem(
                value: s,
                child: Text(s),
              )).toList(),
              onChanged: (v) {
                if (v != null) vm.setSport(v);
              },
            ),

            // 2. Venue
            const SizedBox(height: 16),
            _label('Venue'),
            const SizedBox(height: 6),
            vm.isLoadingVenues
                ? const SizedBox(
                    height: 48,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : _tappableField(
                    hint: 'Select a venue',
                    displayValue: venueText,
                    onTap: () => _pickVenue(context, vm),
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
