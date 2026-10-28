import 'package:flutter/material.dart';
import '../../../../../core/theme/glossy_colors.dart';
import '../../../../widgets/glossy_badge.dart';

class ProtocolSectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String badge;
  final Color badgeColor;
  final String description;
  final List<Map<String, String>> specs;

  const ProtocolSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.description,
    required this.specs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: badgeColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(label: badge, dotColor: badgeColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (int i = 0; i < specs.length; i++) ...[
                  if (i > 0) const Divider(color: GlossyColors.glassDivider, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        specs[i].keys.first,
                        style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          specs[i].values.first,
                          style: const TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
