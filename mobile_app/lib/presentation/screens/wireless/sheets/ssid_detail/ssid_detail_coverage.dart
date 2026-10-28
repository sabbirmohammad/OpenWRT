import 'package:flutter/material.dart';
import '../../../../../core/theme/glossy_colors.dart';
import '../../../../../models/router_status_model.dart';
import '../../../../widgets/glossy_badge.dart';

class SsidDetailCoverage extends StatelessWidget {
  final SsidInfo ssid;

  const SsidDetailCoverage({super.key, required this.ssid});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.radar_rounded, color: GlossyColors.lightBlue, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Coverage Distance & Propagation',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GlossyBadge(
              label: ssid.is5GHz ? 'High Speed' : 'Long Range',
              dotColor: ssid.is5GHz ? GlossyColors.lightBlue : GlossyColors.emeraldMint,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GlossyColors.glassBorderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Estimated Indoor Range', ssid.estimatedIndoorRange),
              const Divider(color: GlossyColors.glassDivider, height: 16),
              _buildDetailRow('Outdoor Line-of-Sight', ssid.estimatedOutdoorRange),
              const Divider(color: GlossyColors.glassDivider, height: 16),
              _buildDetailRow('Wall & Obstacle Penetration', ssid.wallPenetration),
              const Divider(color: GlossyColors.glassDivider, height: 16),
              _buildDetailRow('Transmit Power (TX)', '${ssid.txpowerDbm} dBm (${ssid.is5GHz ? "200 mW" : "100 mW"})'),
              const Divider(color: GlossyColors.glassDivider, height: 16),
              _buildDetailRow('Bandwidth Profile', ssid.coverageType),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: GlossyColors.textMuted, size: 14),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ssid.is5GHz
                            ? '5.0 GHz signals provide ultra-low latency and peak speeds, but attenuate faster through solid walls.'
                            : '2.4 GHz radio frequency provides maximum physical reach and penetrates multiple brick/concrete walls easily.',
                        style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
