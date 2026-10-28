import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';

class TopTrafficBanner extends StatelessWidget {
  final SsidInfo topTrafficSsid;

  const TopTrafficBanner({super.key, required this.topTrafficSsid});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GlossyColors.primaryBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.leaderboard_rounded, color: GlossyColors.lightBlue, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Highest Usage: ${topTrafficSsid.ssid} (${topTrafficSsid.formattedTotalData})',
              style: const TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${topTrafficSsid.formattedDownload} ↓',
            style: const TextStyle(
              color: GlossyColors.lightBlue,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
