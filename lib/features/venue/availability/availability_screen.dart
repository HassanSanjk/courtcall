// features/venue/availability/availability_screen.dart

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:courtcall/core/theme/app_colors.dart';
import 'package:courtcall/repositories/availability_repository.dart';
import 'package:courtcall/repositories/firebase/firebase_availability_repository.dart';
import 'availability_viewmodel.dart';

class AvailabilityScreen extends StatelessWidget {
  final String venueId;

  const AvailabilityScreen({super.key, required this.venueId, this.repo});

  final AvailabilityRepository? repo;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AvailabilityViewModel(
        repo: repo ?? FirebaseAvailabilityRepository(),
        venueId: venueId,
      ),
      child: _AvailabilityBody(venueId: venueId),
    );
  }
}

class _AvailabilityBody extends StatelessWidget {
  final String venueId;

  const _AvailabilityBody({required this.venueId});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AvailabilityViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: LayoutBuilder(
                builder: (_, constraints) {
                  final isWide = constraints.maxWidth > 420;
                  final pad = isWide ? 20.0 : 16.0;
                  return Column(
                    children: [
                      _buildHeader(context, pad, vm),
                      _buildWeekNavigator(pad, vm),
                      _buildCourtTabs(pad, vm),
                      const Divider(height: 1, color: AppColors.outline),
                      Expanded(child: _buildSlotList(pad, vm)),
                      _buildSaveButton(vm),
                    ],
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeader(BuildContext context, double pad, AvailabilityViewModel vm) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4, 12, pad, 4),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text('Manage Courts',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildWeekNavigator(double pad, AvailabilityViewModel vm) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pad, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavArrow(icon: Icons.chevron_left, onTap: vm.previousWeek),
          Text(vm.weekRangeLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface)),
          _NavArrow(icon: Icons.chevron_right, onTap: vm.nextWeek),
        ],
      ),
    );
  }

  Widget _buildCourtTabs(double pad, AvailabilityViewModel vm) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: pad),
        itemCount: vm.courts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = vm.selectedCourtIndex == index;
          return GestureDetector(
            onTap: () => vm.selectCourt(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
              child: Text(
                vm.courts[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotList(double pad, AvailabilityViewModel vm) {
    final days = vm.groupedDays;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(pad, 12, pad, 8),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final slots = (day['slots'] as List).cast<Map<String, dynamic>>();
        return _DaySection(
          day: day,
          slots: slots,
          onToggle: (slotId, value) => vm.toggleSlot(slotId, value),
        );
      },
    );
  }

  Widget _buildSaveButton(AvailabilityViewModel vm) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: vm.hasChanges ? vm.saveChanges : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            disabledBackgroundColor: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: vm.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: AppColors.onPrimary,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onPrimary,
                  ),
                ),
        ),
      ),
    );
  }
}

// Widgets

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
                  color: isToday ? AppColors.secondary : AppColors.onSurfaceVariant,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${day['dateLabel']}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isToday ? AppColors.onSurface : AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
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
                child: Text(
                  '${slot['timeLabel']}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _canToggle ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
              if (slot['status'] == 'booked')
                _Badge(label: 'BOOKED', color: AppColors.onSurface),
              if (slot['status'] == 'maintenance')
                _Badge(label: 'MAINTENANCE', color: AppColors.onSurfaceVariant),
              const SizedBox(width: 12),
              Switch(
                value: slot['isEnabled'] == true,
                onChanged: _canToggle ? onToggle : null,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.secondary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: AppColors.outline,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(
            height: 1,
            indent: 16,
            endIndent: 16,
            color: AppColors.outline,
          ),
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outline),
        ),
        child: Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
      ),
    );
  }
}
