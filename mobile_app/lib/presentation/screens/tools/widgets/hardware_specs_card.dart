import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/cpu_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class HardwareSpecsCard extends StatelessWidget {
  final CpuInfo? cpu;

  const HardwareSpecsCard({super.key, this.cpu});

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.memory_rounded, color: GlossyColors.lightBlue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hardware Specifications',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(
                label: 'Archer C6 v3',
                showDot: false,
                textColor: GlossyColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSpecRow('Processor (SoC)', cpu?.model ?? 'MediaTek MT7621DAT'),
          _buildSpecRow('Architecture', cpu?.architecture ?? 'MIPS 1004Kc (Dual-Core / 4 Threads)'),
          _buildSpecRow('Clock Speed', '${cpu?.frequencyMhz ?? 880} MHz'),
          _buildSpecRow('CPU Temperature', '${(cpu?.temperatureC ?? 42).toStringAsFixed(0)}°C (Normal)'),
          _buildSpecRow('Switch Core', '5x Gigabit Ethernet (DSA)'),
          _buildSpecRow('Firmware / Kernel', 'OpenWrt 23.05.3 / Linux 5.15.150'),
          _buildSpecRow('System Uptime', cpu?.formattedUptime ?? '0m'),
          _buildSpecRow('Load Average', cpu?.loadAvg ?? '0.00'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
