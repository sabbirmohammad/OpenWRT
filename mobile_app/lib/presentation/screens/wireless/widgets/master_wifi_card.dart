import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_card.dart';

class MasterWifiCard extends StatelessWidget {
  final bool isWifiActive;
  final VoidCallback onToggle;

  const MasterWifiCard({
    super.key,
    required this.isWifiActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral)
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral)
                    .withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              isWifiActive ? Icons.wifi : Icons.wifi_off,
              color: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Master Wi-Fi Power',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isWifiActive ? 'Radios Broadcasting Normally' : 'All Wi-Fi Radios Disabled',
                  style: TextStyle(
                    color: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isWifiActive,
            activeThumbColor: GlossyColors.emeraldMint,
            activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
