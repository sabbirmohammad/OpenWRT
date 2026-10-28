import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../../models/traffic_rule.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class FirewallTrafficRulesCard extends StatelessWidget {
  final FirewallInfo fw;
  final VoidCallback onOpenAddSheet;
  final Function(String id, bool enabled) onToggleRule;
  final Function(String id) onDeleteRule;

  const FirewallTrafficRulesCard({
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
                    const Icon(Icons.filter_list_rounded, color: GlossyColors.emeraldMint, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Traffic Filter Rules',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${fw.activeTrafficRulesCount} Active',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Add Filter',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.emeraldMint, size: 22),
                onPressed: onOpenAddSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Granular packet inspection policies for accepting, dropping, or rejecting inter-zone traffic.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (fw.trafficRules.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No custom traffic rules configured.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...fw.trafficRules.map((rule) => _buildTrafficRuleItem(rule)),
        ],
      ),
    );
  }

  Widget _buildTrafficRuleItem(TrafficRule rule) {
    Color targetColor;
    switch (rule.target) {
      case 'ACCEPT':
        targetColor = GlossyColors.emeraldMint;
        break;
      case 'DROP':
        targetColor = GlossyColors.roseCoral;
        break;
      case 'REJECT':
      default:
        targetColor = GlossyColors.amberWarm;
        break;
    }

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
              color: targetColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rule.target,
              style: TextStyle(color: targetColor, fontSize: 10, fontWeight: FontWeight.bold),
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
                  '${rule.src.toUpperCase()} ➔ ${rule.dest.toUpperCase()} • ${rule.proto.toUpperCase()}',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: rule.enabled,
            activeThumbColor: targetColor,
            activeTrackColor: targetColor.withValues(alpha: 0.3),
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
