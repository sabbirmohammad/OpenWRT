import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';

/// Standard reusable glossy modal bottom sheet wrapper following DRY principles.
class GlossyModalSheet extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double topRadius;
  final bool hasGrabHandle;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  const GlossyModalSheet({
    super.key,
    required this.child,
    this.backgroundColor = GlossyColors.backgroundSecondary,
    this.padding,
    this.topRadius = 24.0,
    this.hasGrabHandle = true,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final effectivePadding = padding ??
        EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 24);

    return Container(
      padding: effectivePadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
        border: const Border(
          top: BorderSide(color: GlossyColors.glassBorderLight, width: 1.0),
        ),
      ),
      child: Column(
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          if (hasGrabHandle) ...[
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: GlossyColors.glassBorderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}
