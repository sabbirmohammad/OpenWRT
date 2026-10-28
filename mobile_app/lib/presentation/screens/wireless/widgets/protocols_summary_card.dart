import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_card.dart';
import 'feature_pill.dart';

class ProtocolsSummaryCard extends StatelessWidget {
  final VoidCallback onTap;

  const ProtocolsSummaryCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GlossyCard(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.cell_tower_rounded, color: GlossyColors.lightBlue, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Supported Wi-Fi Protocols & Roaming',
                    style: TextStyle(
                      color: GlossyColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: GlossyColors.textMuted, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FeaturePill(
                      title: '802.11ac Wave 2',
                      subtitle: 'MU-MIMO 2x2 (867 Mbps)',
                      width: itemWidth,
                      icon: Icons.speed_rounded,
                    ),
                    FeaturePill(
                      title: '802.11r FT',
                      subtitle: 'Fast Roaming (<50ms)',
                      width: itemWidth,
                      icon: Icons.sync_rounded,
                    ),
                    FeaturePill(
                      title: '802.11k/v',
                      subtitle: 'Smart Band Steering',
                      width: itemWidth,
                      icon: Icons.explore_rounded,
                    ),
                    FeaturePill(
                      title: '802.11w PMF',
                      subtitle: 'Deauth Frame Shield',
                      width: itemWidth,
                      icon: Icons.security_rounded,
                    ),
                    FeaturePill(
                      title: 'WPA2/WPA3',
                      subtitle: 'Dragonfly SAE Security',
                      width: itemWidth,
                      icon: Icons.lock_outline_rounded,
                    ),
                    FeaturePill(
                      title: 'WMM QoS',
                      subtitle: 'Voice & Video Priority',
                      width: itemWidth,
                      icon: Icons.multitrack_audio_rounded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                children: const [
                  Icon(Icons.touch_app_rounded, color: GlossyColors.lightBlue, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap card to view chipset specs & roaming standards',
                      style: TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Specs →',
                    style: TextStyle(
                      color: GlossyColors.lightBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
