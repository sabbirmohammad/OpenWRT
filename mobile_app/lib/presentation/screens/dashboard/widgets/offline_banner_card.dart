import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';

class OfflineBannerCard extends StatelessWidget {
  final RouterController controller;
  final ValueChanged<int>? onNavigateToTab;

  const OfflineBannerCard({
    super.key,
    required this.controller,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      surfaceColor: GlossyColors.roseCoral.withValues(alpha: 0.08),
      borderColor: GlossyColors.roseCoral.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlossyColors.roseCoral.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.wifi_off, color: GlossyColors.roseCoral, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cannot Connect to Router',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Verify your Android device is connected to the router\'s Wi-Fi.',
                      style: TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (controller.errorMessage != null) ...[
            const SizedBox(height: 10),
            Text(
              controller.errorMessage!,
              style: const TextStyle(
                color: GlossyColors.roseCoral,
                fontSize: 11,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Retry Connection',
                  icon: Icons.refresh,
                  style: GlossyButtonStyle.primary,
                  isLoading: controller.isRefreshing,
                  onPressed: () => controller.refresh(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Edit Settings',
                  icon: Icons.tune,
                  style: GlossyButtonStyle.secondary,
                  onPressed: () {
                    if (onNavigateToTab != null) {
                      onNavigateToTab!(4);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
