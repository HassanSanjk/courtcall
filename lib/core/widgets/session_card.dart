import 'package:flutter/material.dart';

import 'status_pill.dart';

class SessionCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String venue;
  final int playerCount;
  final int maxPlayers;
  final String status;
  final String? sport;
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
    this.sport,
    this.onTap,
  });

  static IconData _sportIcon(String? sport) {
    switch (sport?.toLowerCase()) {
      case 'futsal': return Icons.sports_soccer;
      case 'badminton': return Icons.sports_tennis;
      case 'basketball': return Icons.sports_basketball;
      case 'volleyball': return Icons.sports_volleyball;
      default: return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
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
            Container(
              width: 52,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF1A1A2E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(_sportIcon(sport), size: 20, color: const Color(0xFF1A1A2E)),
                  const SizedBox(height: 4),
                  Text(
                    date.split(',').last.trim().split(' ').first,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
            ),
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
                      color: Color(0xFF1A1A2E),
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
