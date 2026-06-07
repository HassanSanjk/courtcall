import 'package:flutter/material.dart';

class AvatarData {
  final String initials;
  final Color color;

  const AvatarData(this.initials, this.color);
}

class AvatarStack extends StatelessWidget {
  final List<AvatarData> avatars;
  final int overflow;
  final double size;

  const AvatarStack({
    super.key,
    required this.avatars,
    this.overflow = 0,
    this.size = 28,
  });

  @override
  Widget build(BuildContext context) {
    final maxVisible = avatars.length;
    final items = avatars.take(maxVisible).toList();

    final n = items.length + (overflow > 0 ? 1 : 0);
    final totalWidth = n == 0 ? size : (n - 1) * size * 0.7 + size;

    return SizedBox(
      width: totalWidth,
      height: size,
      child: Stack(
        children: [
          for (int i = items.length - 1; i >= 0; i--)
            Positioned(
              left: i * (size * 0.7),
              top: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: items[i].color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    items[i].initials,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.38,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          if (overflow > 0)
            Positioned(
              left: items.length * (size * 0.7),
              top: 0,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$overflow',
                    style: TextStyle(
                      color: const Color(0xFF6B7280),
                      fontSize: size * 0.35,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
