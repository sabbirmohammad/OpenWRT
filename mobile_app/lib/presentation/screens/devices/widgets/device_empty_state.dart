import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';

class DeviceEmptyState extends StatelessWidget {
  const DeviceEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.devices_other_rounded,
            size: 56,
            color: GlossyColors.textMuted.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 12),
          const Text(
            'No devices found',
            style: TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try clearing search query or change filter category.',
            style: TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
