import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';

class WanMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? valueColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Widget? customBody;

  const WanMetricTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.valueColor,
    this.trailing,
    this.onTap,
    this.customBody,
  });

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: GlossyColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 5),
          if (customBody != null)
            customBody!
          else
            Text(
              value,
              style: TextStyle(color: valueColor ?? GlossyColors.textPrimary, fontSize: 12.5, fontWeight: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: tile);
    }
    return tile;
  }
}
