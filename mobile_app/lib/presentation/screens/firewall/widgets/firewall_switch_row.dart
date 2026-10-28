import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';

class FirewallSwitchRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool isLoading;
  final Color activeColor;
  final ValueChanged<bool> onChanged;

  const FirewallSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isLoading,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        isLoading
            ? SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: activeColor),
                  ),
                ),
              )
            : Switch.adaptive(
                value: value,
                activeThumbColor: activeColor,
                activeTrackColor: activeColor.withValues(alpha: 0.3),
                onChanged: onChanged,
              ),
      ],
    );
  }
}
