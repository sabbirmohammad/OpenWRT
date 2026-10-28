import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';

/// Graphical tile displaying System Uptime with stability indicators.
class UptimeStabilityTile extends StatelessWidget {
  final String formattedUptime;
  final int uptimeSeconds;

  const UptimeStabilityTile({
    super.key,
    required this.formattedUptime,
    required this.uptimeSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final displayUptime = formattedUptime;
    // Stability calculation: >1 day is 5 segments, >6 hours is 4, >1 hour is 3, >10 mins is 2, else 1
    int activeSegments = 1;
    if (uptimeSeconds >= 86400) {
      activeSegments = 5;
    } else if (uptimeSeconds >= 21600) {
      activeSegments = 4;
    } else if (uptimeSeconds >= 3600) {
      activeSegments = 3;
    } else if (uptimeSeconds >= 600) {
      activeSegments = 2;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.timer_outlined, size: 14, color: GlossyColors.emeraldMint),
                  SizedBox(width: 4),
                  Text(
                    'UPTIME',
                    style: TextStyle(
                      color: GlossyColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: GlossyColors.emeraldMint,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: GlossyColors.emeraldMint,
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            displayUptime,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // 5-Segmented stability bar
          Row(
            children: List.generate(5, (index) {
              final isLit = index < activeSegments;
              return Expanded(
                child: Container(
                  height: 4,
                  margin: EdgeInsets.only(right: index < 4 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: isLit
                        ? GlossyColors.emeraldMint
                        : GlossyColors.emeraldMint.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isLit
                        ? [
                            BoxShadow(
                              color: GlossyColors.emeraldMint.withValues(alpha: 0.4),
                              blurRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 4),
          const Text(
            '100% Stability',
            style: TextStyle(
              color: GlossyColors.emeraldMint,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
