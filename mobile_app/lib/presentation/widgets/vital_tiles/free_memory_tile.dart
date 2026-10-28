import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';

/// Graphical tile displaying Free Memory / RAM capacity and headroom.
class FreeMemoryTile extends StatelessWidget {
  final int totalKb;
  final int freeKb;
  final int usedKb;

  const FreeMemoryTile({
    super.key,
    required this.totalKb,
    required this.freeKb,
    required this.usedKb,
  });

  @override
  Widget build(BuildContext context) {
    final totalMb = totalKb > 0 ? totalKb ~/ 1024 : 128;
    final freeMb = freeKb ~/ 1024;
    final usedMb = (usedKb ~/ 1024).clamp(0, totalMb);
    final freeRatio = totalMb > 0 ? (freeMb / totalMb).clamp(0.0, 1.0) : 0.5;
    final freePercent = (freeRatio * 100).toInt();
    final usedRatio = (1.0 - freeRatio).clamp(0.0, 1.0);

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
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.storage_rounded, size: 14, color: GlossyColors.emeraldMint),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'FREE RAM',
                        style: TextStyle(
                          color: GlossyColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: GlossyColors.emeraldMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$freePercent%',
                  style: const TextStyle(
                    color: GlossyColors.emeraldMint,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '$freeMb MB',
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'of ${totalMb}M',
                style: const TextStyle(
                  color: GlossyColors.textMuted,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Dual-tone Capacity Bar: Used (Blue) + Free (Emerald Mint)
          ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: SizedBox(
              height: 4.5,
              child: Row(
                children: [
                  Expanded(
                    flex: (usedRatio * 100).toInt().clamp(2, 98),
                    child: Container(color: GlossyColors.lightBlue),
                  ),
                  Container(width: 1, color: Colors.transparent),
                  Expanded(
                    flex: (freeRatio * 100).toInt().clamp(2, 98),
                    child: Container(color: GlossyColors.emeraldMint),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: GlossyColors.lightBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${usedMb}M',
                        style: const TextStyle(
                          color: GlossyColors.textMuted,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: GlossyColors.emeraldMint,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        '${freeMb}M',
                        style: const TextStyle(
                          color: GlossyColors.emeraldMint,
                          fontSize: 7.5,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
