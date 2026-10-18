import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

class GlossyBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color dotColor;
  final bool showDot;
  final Color? textColor;
  final VoidCallback? onTap;

  const GlossyBadge({
    super.key,
    required this.label,
    this.icon,
    this.dotColor = GlossyColors.emeraldMint,
    this.showDot = true,
    this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget badge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: GlossyColors.glassSurface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: dotColor.withValues(alpha: 0.35),
          width: 1.0,
        ),
      ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (showDot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
              ],
              if (icon != null) ...[
                Icon(icon, size: 12, color: textColor ?? GlossyColors.textPrimary),
                const SizedBox(width: 5),
              ],
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor ?? GlossyColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }

    return badge;
  }
}
