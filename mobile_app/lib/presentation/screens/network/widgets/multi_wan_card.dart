import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class MultiWanCard extends StatelessWidget {
  final NetworkInfo? network;
  final ValueChanged<bool> onToggle;

  const MultiWanCard({
    super.key,
    required this.network,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = network?.multiWanEnabled ?? false;

    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: GlossyColors.amberWarm, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Multi-WAN Failover & Backup',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: isEnabled ? 'mwan3 Active' : 'Standby',
                dotColor: isEnabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Automated 3-second link health failover using mwan3. Automatically routes traffic to secondary ISP on LAN Port 4 if primary Fiber WAN link drops.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10, color: GlossyColors.emeraldMint),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'WAN 1: Fiber (Online)',
                          style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fiber_manual_record,
                        size: 10,
                        color: isEnabled ? GlossyColors.amberWarm : GlossyColors.textMuted,
                      ),
                      const SizedBox(width: 6),
                      const Expanded(
                        child: Text(
                          'WAN 2: LAN 4 (Backup)',
                          style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'mwan3 Multi-WAN Engine',
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
