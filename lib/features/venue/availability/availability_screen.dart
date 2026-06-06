// features/venue/availability/availability_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:courtcall/repositories/availability_repository.dart';
import 'package:courtcall/repositories/firebase/firebase_availability_repository.dart';
import 'availability_viewmodel.dart';

class AvailabilityScreen extends StatefulWidget {
  final String venueId;

  const AvailabilityScreen({super.key, required this.venueId, this.repo});

  final AvailabilityRepository? repo;

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late final AvailabilityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AvailabilityViewModel(
      repo: widget.repo ?? FirebaseAvailabilityRepository(),
      venueId: widget.venueId,
    );
    _viewModel.addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: _viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 420;
                  final pad = isWide ? 20.0 : 16.0;
                  return Column(
                    children: [
                      _buildHeader(pad),
                      _buildWeekNavigator(pad),
                      _buildCourtTabs(pad),
                      const Divider(height: 1, color: Color(0xFFE5E7EB)),
                      Expanded(child: _buildSlotList(pad)),
                      _buildSaveButton(),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader(double pad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 12, pad, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: () => context.go('/venue/dashboard?venueId=${widget.venueId}'),
          ),
          const Expanded(
            child: Text('Manage Courts',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator(double pad) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: _viewModel.previousWeek),
          Text(_viewModel.weekRangeLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E))),
          _NavArrow(icon: Icons.chevron_right, onTap: _viewModel.nextWeek),
        ],
      ),
    );
  }

  Widget _buildCourtTabs(double pad) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: _viewModel.courts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _viewModel.selectedCourtIndex == index;
          return GestureDetector(
            onTap: () => _viewModel.selectCourt(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1A1A2E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                _viewModel.courts[index],
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B7280)),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotList(double pad) {
    final days = _viewModel.groupedDays;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final slots =
            (day['slots'] as List).cast<Map<String, dynamic>>();
        return _DaySection(
          day: day,
          slots: slots,
          onToggle: (slotId, value) =>
              _viewModel.toggleSlot(slotId, value),
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: _viewModel.hasChanges ? _viewModel.saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A2E),
            disabledBackgroundColor: const Color(0xFFD1D5DB),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _viewModel.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : const Text('Save Changes',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
        ),
      ),
    );
  }
}

// ─── Widgets ───────────────────────────────────────────────────────────────────

class _DaySection extends StatelessWidget {
  final Map<String, dynamic> day;
  final List<Map<String, dynamic>> slots;
  final void Function(String slotId, bool value) onToggle;

  const _DaySection({
    required this.day,
    required this.slots,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = day['isToday'] == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isToday
                      ? const Color(0xFF0D7A3E)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text('${day['dateLabel']}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isToday
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF6B7280))),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 1))
            ],
          ),
          child: Column(
            children: slots.asMap().entries.map((entry) {
              final i = entry.key;
              final slot = entry.value;
              final isLast = i == slots.length - 1;
              return _SlotRow(
                slot: slot,
                isLast: isLast,
                onToggle: (val) => onToggle(slot['id'], val),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SlotRow extends StatelessWidget {
  final Map<String, dynamic> slot;
  final bool isLast;
  final ValueChanged<bool> onToggle;

  const _SlotRow({
    required this.slot,
    required this.isLast,
    required this.onToggle,
  });

  bool get _canToggle =>
      slot['status'] == 'available' || slot['status'] == 'open';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text('${slot['timeLabel']}',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _canToggle
                            ? const Color(0xFF1A1A2E)
                            : const Color(0xFF9CA3AF))),
              ),
              if (slot['status'] == 'booked')
                _Badge(label: 'BOOKED', color: const Color(0xFF1A1A2E)),
              if (slot['status'] == 'maintenance')
                _Badge(label: 'MAINTENANCE', color: const Color(0xFF6B7280)),
              const SizedBox(width: 12),
              Switch(
                value: slot['isEnabled'] == true,
                onChanged: _canToggle ? onToggle : null,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF0D7A3E),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: Color(0xFFF3F4F6)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5)),
    );
  }
}

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrow({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
      ),
    );
  }
}