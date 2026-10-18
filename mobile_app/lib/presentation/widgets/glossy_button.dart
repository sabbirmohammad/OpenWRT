import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

enum GlossyButtonStyle { primary, secondary, danger }

class GlossyButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final GlossyButtonStyle style;
  final double height;
  final double? width;

  const GlossyButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.style = GlossyButtonStyle.primary,
    this.height = 46.0,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    Color startColor;
    Color endColor;
    Color borderColor;

    switch (style) {
      case GlossyButtonStyle.primary:
        startColor = const Color(0xFF3B82F6);
        endColor = const Color(0xFF1D4ED8);
        borderColor = const Color(0x6660A5FA);
        break;
      case GlossyButtonStyle.secondary:
        startColor = const Color(0x26FFFFFF);
        endColor = const Color(0x10FFFFFF);
        borderColor = const Color(0x33FFFFFF);
        break;
      case GlossyButtonStyle.danger:
        startColor = const Color(0xFFEF4444);
        endColor = const Color(0xFFB91C1C);
        borderColor = const Color(0x66F87171);
        break;
    }

    final isDisabled = onPressed == null || isLoading;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: (style == GlossyButtonStyle.primary
                          ? GlossyColors.primaryBlue
                          : Colors.black)
                      .withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              splashColor: Colors.white.withValues(alpha: 0.15),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDisabled ? Colors.white10 : borderColor,
                    width: 1.0,
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDisabled
                        ? [Colors.white10, Colors.white12]
                        : [startColor, endColor],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (icon != null) ...[
                                Icon(
                                  icon,
                                  size: 18,
                                  color: GlossyColors.textPrimary,
                                ),
                                const SizedBox(width: 8),
                              ],
                              Flexible(
                                child: Text(
                                  label,
                                  style: const TextStyle(
                                    color: GlossyColors.textPrimary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
          ),
        ),
      );
  }
}
