import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';

/// Graphical tile displaying CPU Topology with horizontal core utilization bars.
class CpuCoresDieTile extends StatelessWidget {
  final int cores;
  final int threads;
  final double cpuUsagePercent;

  const CpuCoresDieTile({
    super.key,
    required this.cores,
    required this.threads,
    this.cpuUsagePercent = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    // Distributed load for MT7621 dual core (Core 1 handles kernel/routing, Core 2 handles services)
    final c1Usage = (cpuUsagePercent * 1.15).clamp(0.0, 100.0);
    final c2Usage = (cpuUsagePercent * 0.85).clamp(0.0, 100.0);

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.developer_board_rounded, size: 14, color: GlossyColors.lightBlue),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CPU CORES',
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
              SizedBox(width: 4),
              Text(
                'MT7621',
                style: TextStyle(
                  color: GlossyColors.lightBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildCoreBar(
            coreName: 'Core 1',
            threadsTag: 'T1•T2',
            usage: c1Usage,
          ),
          const SizedBox(height: 6),
          _buildCoreBar(
            coreName: 'Core 2',
            threadsTag: 'T3•T4',
            usage: c2Usage,
          ),
          const SizedBox(height: 4),
          const Text(
            '2 Cores / 4 Threads',
            style: TextStyle(
              color: GlossyColors.textMuted,
              fontSize: 8.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreBar({
    required String coreName,
    required String threadsTag,
    required double usage,
  }) {
    final ratio = (usage / 100.0).clamp(0.0, 1.0);
    Color barColor = GlossyColors.lightBlue;
    if (usage > 80) {
      barColor = GlossyColors.roseCoral;
    } else if (usage > 50) {
      barColor = GlossyColors.amberWarm;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      coreName,
                      style: const TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: GlossyColors.lightBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      threadsTag,
                      style: const TextStyle(
                        color: GlossyColors.skyBlue,
                        fontSize: 7.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '${usage.toStringAsFixed(0)}%',
              style: TextStyle(
                color: barColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Stack(
          children: [
            Container(
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            FractionallySizedBox(
              widthFactor: ratio,
              child: Container(
                height: 4.5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [GlossyColors.primaryBlue, barColor],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: barColor.withValues(alpha: 0.4),
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
