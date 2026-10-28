import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../../models/port_forward_rule.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class FirewallPortForwardsCard extends StatelessWidget {
  final FirewallInfo fw;
  final VoidCallback onOpenAddSheet;
  final Function(String id, bool enabled) onToggleRule;
  final Function(String id) onDeleteRule;

  const FirewallPortForwardsCard({
    super.key,
    required this.fw,
    required this.onOpenAddSheet,
    required this.onToggleRule,
    required this.onDeleteRule,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.alt_route_rounded, color: GlossyColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Port Forwarding (NAT)',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${fw.activePortForwardsCount} Active',
                      dotColor: GlossyColors.primaryBlue,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Add Rule',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.primaryBlue, size: 22),
                onPressed: onOpenAddSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Route specific external public ports to local servers, gaming consoles, or IP cameras.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (fw.portForwards.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No port forwarding rules configured.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...fw.portForwards.map((rule) => _buildPortForwardItem(rule)),
        ],
      ),
    );
  }

  Widget _buildPortForwardItem(PortForwardRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rule.proto.toUpperCase(),
              style: const TextStyle(color: GlossyColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'WAN :${rule.extPort} ➔ ${rule.intIp}:${rule.intPort}',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: rule.enabled,
            activeThumbColor: GlossyColors.primaryBlue,
            activeTrackColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
            onChanged: (val) => onToggleRule(rule.id, val),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: GlossyColors.roseCoral, size: 18),
            onPressed: () => onDeleteRule(rule.id),
          ),
        ],
      ),
    );
  }
}
