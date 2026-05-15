import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'status_pill.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String venue;
  final int playerCount;
  final int maxPlayers;
  final String status;
  final VoidCallback? onTap;

  const SessionCard({
    super.key,
    required this.title,
    required this.date,
    required this.time,
    required this.venue,
    required this.playerCount,
    required this.maxPlayers,
    this.status = 'upcoming',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _DateBadge(date: date, time: time),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: Colors.black45),
                      const SizedBox(width: 3),
                      Text(
                        venue,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 13, color: Colors.black45),
                      const SizedBox(width: 3),
                      Text(
                        '$playerCount / $maxPlayers players',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54),
                      ),
                      const Spacer(),
                      StatusPill(
                        status: PillStatus.going,
                        label: status,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBadge extends StatelessWidget {
  final String date;
  final String time;

  const _DateBadge({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    final parts = date.split('-');
    final month = _monthAbbr(int.tryParse(parts.length > 1 ? parts[1] : '1') ?? 1);
    final day = parts.length > 2 ? parts[2] : '--';

    return Container(
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            month,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryNavy,
            ),
          ),
          Text(
            day,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryNavy,
              height: 1.1,
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return months[(m - 1).clamp(0, 11)];
  }
}
