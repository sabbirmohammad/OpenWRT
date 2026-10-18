import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

class GlossyCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final Color? surfaceColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const GlossyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.margin,
    this.borderRadius = 20.0,
    this.blur = 16.0,
    this.surfaceColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveSurface = surfaceColor ?? GlossyColors.glassSurface;

    Widget cardBody = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? GlossyColors.glassBorderLight,
          width: 1.0,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x18FFFFFF), // Top-left specular sheen
            Color(0x06FFFFFF), // Soft bottom-right fade
          ],
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      cardBody = Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          splashColor: GlossyColors.primaryBlue.withValues(alpha: 0.15),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: cardBody,
        ),
      );
    }

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: cardBody,
    );
  }
}
