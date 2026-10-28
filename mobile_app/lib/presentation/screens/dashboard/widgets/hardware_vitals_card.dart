import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/circular_gauge.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import '../../../widgets/hardware_vital_tile.dart';

class HardwareVitalsCard extends StatelessWidget {
  final RouterStatusModel status;

  const HardwareVitalsCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Hardware Vitals',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: GlossyBadge(
                  label: status.cpu.model.split('@').first.trim(),
                  showDot: false,
                  textColor: GlossyColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularGauge(
                value: status.cpu.usagePercent,
                label: 'CPU',
                subtitle: '${status.cpu.temperatureC.toStringAsFixed(0)}°C',
              ),
              CircularGauge(
                value: status.memory.usagePercent,
                label: 'RAM',
                subtitle: status.memory.formattedUsedMb,
              ),
              CircularGauge(
                value: status.storage.usagePercent,
                label: 'Flash',
                subtitle: status.storage.formattedUsedMb,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: GlossyColors.glassDivider),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: UptimeStabilityTile(
                  formattedUptime: status.cpu.formattedUptime,
                  uptimeSeconds: status.cpu.uptimeSeconds,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: LoadAverageTile(
                  loadAvgString: status.cpu.loadAvg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: CpuCoresDieTile(
                  cores: status.cpu.cores,
                  threads: status.cpu.threads,
                  cpuUsagePercent: status.cpu.usagePercent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ClockFrequencyTile(
                  frequencyMhz: status.cpu.frequencyMhz,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
