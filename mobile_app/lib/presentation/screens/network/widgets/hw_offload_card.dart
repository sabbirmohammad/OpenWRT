import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class HwOffloadCard extends StatelessWidget {
  final NetworkInfo? network;
  final ValueChanged<bool> onToggle;

  const HwOffloadCard({
    super.key,
    required this.network,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = network?.hwOffload ?? true;

    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed, color: GlossyColors.lightBlue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'MediaTek HW NAT Offload',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: isEnabled ? 'Accelerated' : 'Kernel',
                dotColor: isEnabled ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bypasses CPU kernel software routing and offloads Gigabit packet flows directly onto the MediaTek MT7621 Packet Processing Engine (PPE). Minimizes CPU usage down to < 5% during full Gigabit line-rate transfers.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isEnabled
                  ? GlossyColors.emeraldMint.withValues(alpha: 0.08)
                  : GlossyColors.amberWarm.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isEnabled
                    ? GlossyColors.emeraldMint.withValues(alpha: 0.25)
                    : GlossyColors.amberWarm.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.memory,
                  size: 13,
                  color: isEnabled ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    isEnabled
                        ? 'MT7621 PPE Active • Zero Routing Overhead'
                        : 'Software Kernel Routing Only',
                    style: TextStyle(
                      color: isEnabled ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Flow Offloading State',
                  style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isEnabled,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
