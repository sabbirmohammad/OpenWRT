import 'package:flutter/material.dart';
import '../../../../../core/theme/glossy_colors.dart';
import '../../../../../models/router_status_model.dart';
import '../../../../widgets/glossy_badge.dart';

class SsidDetailTraffic extends StatelessWidget {
  final SsidInfo ssid;
  final bool isTopTraffic;
  final int rank;
  final double trafficShare;

  const SsidDetailTraffic({
    super.key,
    required this.ssid,
    required this.isTopTraffic,
    required this.rank,
    required this.trafficShare,
  });

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
                  Icon(Icons.data_usage_rounded, color: GlossyColors.lightBlue, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Data Traffic & Bandwidth',
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
              label: isTopTraffic ? 'Highest Usage' : 'Rank #$rank',
              dotColor: isTopTraffic ? GlossyColors.amberWarm : GlossyColors.primaryBlue,
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
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.arrow_downward_rounded,
                      iconColor: GlossyColors.lightBlue,
                      label: 'Total Downloaded',
                      value: ssid.formattedDownload,
                      subtitle: '${trafficShare.toStringAsFixed(1)}% of Wi-Fi volume',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricTile(
                      icon: Icons.arrow_upward_rounded,
                      iconColor: GlossyColors.skyBlue,
                      label: 'Total Uploaded',
                      value: ssid.formattedUpload,
                      subtitle: 'Aggregated client Tx',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: GlossyColors.glassDivider, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Combined Throughput', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
                  Text(
                    ssid.formattedTotalData,
                    style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (trafficShare / 100).clamp(0.02, 1.0),
                  backgroundColor: Colors.white10,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isTopTraffic ? GlossyColors.amberWarm : GlossyColors.primaryBlue,
                  ),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10)),
        ],
      ),
    );
  }
}
