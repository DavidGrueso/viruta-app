import 'package:flutter/material.dart';

class VirutaStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool tall;

  const VirutaStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.tall = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tall ? 130 : 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff1e293b),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.tealAccent, size: 28),
          const SizedBox(height: 8),
          // Value: scale down if too large to fit
          Expanded(
            child: FittedBox(
              alignment: Alignment.centerLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Title: single line with ellipsis
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          )
        ],
      ),
    );
  }
}
