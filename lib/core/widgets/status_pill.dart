import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum PillStatus { paid, unpaid, pending, going, maybe, out }

/// StatusBadge provides named factory constructors matching the design.
/// Usage: StatusBadge.paid() or StatusBadge.pending()
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const StatusBadge._({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  factory StatusBadge.paid() => StatusBadge._(
        label: 'Paid',
        bgColor: AppColors.greenLight,
        textColor: AppColors.greenBright,
      );

  factory StatusBadge.pending() => StatusBadge._(
        label: 'Pending',
        bgColor: AppColors.amberLight,
        textColor: AppColors.amber,
      );

  factory StatusBadge.declined() => StatusBadge._(
        label: 'Declined',
        bgColor: AppColors.redLight,
        textColor: AppColors.error,
      );

  factory StatusBadge.waitlist() => StatusBadge._(
        label: 'Waitlist',
        bgColor: AppColors.amberLight,
        textColor: AppColors.amber,
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

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
        return (AppColors.error.withValues(alpha:0.2), AppColors.error);
    }
  }
}