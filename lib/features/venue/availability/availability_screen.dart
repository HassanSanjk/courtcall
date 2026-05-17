// features/venue/availability/availability_screen.dart

import 'package:flutter/material.dart';
import 'availability_viewmodel.dart';

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  late final AvailabilityViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AvailabilityViewModel();
    _viewModel.addListener(() => setState(() {}));
    _viewModel.loadData();
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
              child: Column(
                children: [
                  _buildHeader(),
                  _buildWeekNavigator(),
                  _buildCourtTabs(),
                  const Divider(height: 1, color: Color(0xFFE5E7EB)),
                  Expanded(child: _buildSlotList()),
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Manage Courts',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          const SizedBox(width: 48), // balance back button
        ],
      ),
    );
  }

  // ─── Week Navigator ────────────────────────────────────────────────────────

  Widget _buildWeekNavigator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrowButton(
            icon: Icons.chevron_left,
            onTap: _viewModel.previousWeek,
          ),
          Text(
            _viewModel.weekRangeLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          _NavArrowButton(
            icon: Icons.chevron_right,
            onTap: _viewModel.nextWeek,
          ),
        ],
      ),
    );
  }

  // ─── Court Tabs ────────────────────────────────────────────────────────────

  Widget _buildCourtTabs() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _viewModel.courts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final court = _viewModel.courts[index];
          final isSelected = _viewModel.selectedCourtIndex == index;
          return GestureDetector(
            onTap: () => _viewModel.selectCourt(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                court,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF6B7280),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Slot List ─────────────────────────────────────────────────────────────

  Widget _buildSlotList() {
    final days = _viewModel.daysWithSlots;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        return _DaySection(
          day: day,
          onToggle: (slotId, value) =>
              _viewModel.toggleSlot(day.date, slotId, value),
        );
      },
    );
  }

  // ─── Save Button ───────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
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
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _viewModel.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

// ─── Day Section ───────────────────────────────────────────────────────────────

class _DaySection extends StatelessWidget {
  final DayAvailability day;
  final void Function(String slotId, bool value) onToggle;

  const _DaySection({required this.day, required this.onToggle});

  @override
  Widget build(BuildContext context) {
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
                  color: day.isToday
                      ? const Color(0xFF0D7A3E)
                      : const Color(0xFF9CA3AF),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                day.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: day.isToday
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFF6B7280),
                ),
              ),
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
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: day.slots.asMap().entries.map((entry) {
              final i = entry.key;
              final slot = entry.value;
              final isLast = i == day.slots.length - 1;
              return _SlotRow(
                slot: slot,
                isLast: isLast,
                onToggle: (val) => onToggle(slot.id, val),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Slot Row ──────────────────────────────────────────────────────────────────

class _SlotRow extends StatelessWidget {
  final TimeSlot slot;
  final bool isLast;
  final ValueChanged<bool> onToggle;

  const _SlotRow({
    required this.slot,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final canToggle = slot.status == SlotStatus.available ||
        slot.status == SlotStatus.open;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  slot.timeLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: canToggle
                        ? const Color(0xFF1A1A2E)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              if (slot.status == SlotStatus.booked)
                _StatusBadge(label: 'BOOKED', color: const Color(0xFF1A1A2E))
              else if (slot.status == SlotStatus.maintenance)
                _StatusBadge(
                    label: 'MAINTENANCE', color: const Color(0xFF6B7280)),
              const SizedBox(width: 12),
              Switch(
                value: slot.isEnabled,
                onChanged: canToggle ? onToggle : null,
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF0D7A3E),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFD1D5DB),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16,
              color: Color(0xFFF3F4F6)),
      ],
    );
  }
}

// ─── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── Nav Arrow Button ─────────────────────────────────────────────────────────

class _NavArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _NavArrowButton({required this.icon, required this.onTap});

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