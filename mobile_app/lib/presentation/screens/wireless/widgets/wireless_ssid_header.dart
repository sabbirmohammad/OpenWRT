import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';

class WirelessSsidHeader extends StatelessWidget {
  final int totalSsids;
  final int activeSsids;
  final int inactiveSsids;
  final VoidCallback onAddSsid;

  const WirelessSsidHeader({
    super.key,
    required this.totalSsids,
    required this.activeSsids,
    required this.inactiveSsids,
    required this.onAddSsid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              child: const Icon(Icons.wifi_tethering_rounded, color: GlossyColors.lightBlue, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'SSID Networks',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '$totalSsids SSIDs',
                      dotColor: GlossyColors.primaryBlue,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '$activeSsids Active • $inactiveSsids Inactive',
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        GlossyButton(
          label: 'Add SSID',
          icon: Icons.add,
          height: 34,
          onPressed: onAddSsid,
        ),
      ],
    );
  }
}
