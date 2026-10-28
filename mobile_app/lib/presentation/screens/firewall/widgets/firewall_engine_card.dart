import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import 'firewall_metric_row.dart';

class FirewallEngineCard extends StatelessWidget {
  final FirewallInfo fw;
  final bool isFlushingConntrack;
  final VoidCallback onFlushConntrack;

  const FirewallEngineCard({
    super.key,
    required this.fw,
    required this.isFlushingConntrack,
    required this.onFlushConntrack,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: GlossyColors.amberWarm, size: 24),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Firewall 4 (nftables)',
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
              const GlossyBadge(
                label: 'Enforcing',
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Modern Linux nftables subsystem running on OpenWrt kernel. Manages stateful packet inspection, NAT translations, and per-zone routing rules.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          FirewallMetricRow(label: 'Subsystem Engine', value: fw.engine),
          FirewallMetricRow(label: 'State Table', value: fw.table),
          const FirewallMetricRow(label: 'NAT Masquerade', value: 'Active (eth0.2 / pppoe-wan)'),
          FirewallMetricRow(label: 'Default WAN Policy', value: fw.wanLockdown ? 'DROP Inbound (Drop Unsolicited)' : 'ACCEPT (Open)'),
          const FirewallMetricRow(label: 'Default LAN Policy', value: 'ACCEPT Outbound (Full Internet)'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
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
                        Icon(Icons.hub_outlined, color: GlossyColors.lightBlue, size: 15),
                        SizedBox(width: 5),
                        Text(
                          'Conntrack State Table',
                          style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${fw.conntrackCount} / ${fw.conntrackMax} (${fw.conntrackPercent.toStringAsFixed(1)}%)',
                        style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fw.conntrackPercent / 100.0,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fw.conntrackPercent > 80 ? GlossyColors.roseCoral : GlossyColors.lightBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Active Defenses: ${fw.activeDefensesCount}/${fw.totalDefensesCount}',
                        style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: isFlushingConntrack ? null : onFlushConntrack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            if (isFlushingConntrack)
                              const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: GlossyColors.amberWarm))
                            else
                              const Icon(Icons.cleaning_services_rounded, color: GlossyColors.amberWarm, size: 13),
                            const SizedBox(width: 4),
                            const Text('Flush Table', style: TextStyle(color: GlossyColors.amberWarm, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
