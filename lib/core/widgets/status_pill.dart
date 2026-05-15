import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PillStatus { paid, unpaid, pending, going, maybe, out }

class StatusPill extends StatelessWidget {
  final PillStatus status;
  final String label;

  const StatusPill({super.key, required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = _colorsFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.$1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.$2,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  (Color, Color) _colorsFor(PillStatus s) {
    switch (s) {
      case PillStatus.paid:
      case PillStatus.going:
        return (AppColors.accentGreen.withValues(alpha:0.2), AppColors.accentGreen);
      case PillStatus.unpaid:
      case PillStatus.pending:
      case PillStatus.maybe:
        return (AppColors.alertAmber.withValues(alpha:0.2), AppColors.alertAmber);
      case PillStatus.out:
        return (Colors.red.withValues(alpha:0.2), Colors.red);
    }
  }
}