import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

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
            formattedUptime,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 14,
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

/// Graphical tile displaying Load Average with 3 distinct horizontal capacity bars.
class LoadAverageTile extends StatelessWidget {
  final String loadAvgString;

  const LoadAverageTile({
    super.key,
    required this.loadAvgString,
  });

  List<double> _parseLoads() {
    // "0.15, 0.22, 0.18" or "0.15"
    final parts = loadAvgString.split(',').map((s) => double.tryParse(s.trim()) ?? 0.0).toList();
    while (parts.length < 3) {
      parts.add(parts.isNotEmpty ? parts.last : 0.0);
    }
    return parts.take(3).toList();
  }

  Color _colorForLoad(double load) {
    if (load < 1.0) return GlossyColors.emeraldMint;
    if (load < 2.0) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  @override
  Widget build(BuildContext context) {
    final loads = _parseLoads();
    final primaryLoad = loads[0];
    final color = _colorForLoad(primaryLoad);

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
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.speed_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    const Flexible(
                      child: Text(
                        'LOAD AVG',
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
              Text(
                'MAX 2.0',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 3 Horizontal Capacity Bars for 1m, 5m, and 15m
          _buildLoadBar(label: '1m', load: loads[0]),
          const SizedBox(height: 5),
          _buildLoadBar(label: '5m', load: loads[1]),
          const SizedBox(height: 5),
          _buildLoadBar(label: '15m', load: loads[2]),
        ],
      ),
    );
  }

  Widget _buildLoadBar({required String label, required double load}) {
    final color = _colorForLoad(load);
    // Capacity ratio against max 2.0 (dual core baseline capacity)
    final ratio = (load / 2.0).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            label,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            load.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}

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
          // Horizontal Bar for Core 1 (T1, T2)
          _buildCoreBar(
            coreName: 'Core 1',
            threadsTag: 'T1•T2',
            usage: c1Usage,
          ),
          const SizedBox(height: 6),
          // Horizontal Bar for Core 2 (T3, T4)
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

/// Graphical tile displaying Processor Clock Frequency with a dynamic speedometer meter.
class ClockFrequencyTile extends StatelessWidget {
  final int frequencyMhz;
  final int maxFrequencyMhz;

  const ClockFrequencyTile({
    super.key,
    required this.frequencyMhz,
    this.maxFrequencyMhz = 880,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (frequencyMhz / maxFrequencyMhz).clamp(0.0, 1.0);

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
                    Icon(Icons.bolt_rounded, size: 14, color: GlossyColors.skyBlue),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CLOCK SPEED',
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
                'MAX 880',
                style: TextStyle(
                  color: GlossyColors.skyBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '$frequencyMhz MHz',
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Peak Turbo',
                style: TextStyle(
                  color: GlossyColors.skyBlue,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Turbo Gauge Bar
          Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [GlossyColors.primaryBlue, GlossyColors.skyBlue],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: GlossyColors.skyBlue.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 MHz',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: Text(
                  '${(ratio * 100).toInt()}% Capacity',
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$maxFrequencyMhz MHz',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
