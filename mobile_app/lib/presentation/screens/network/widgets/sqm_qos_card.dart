import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SqmQosCard extends StatelessWidget {
  final NetworkInfo? network;
  final ValueChanged<bool> onToggle;
  final VoidCallback onOpenTuneModal;

  const SqmQosCard({
    super.key,
    required this.network,
    required this.onToggle,
    required this.onOpenTuneModal,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = network?.sqmEnabled ?? false;

    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.speed_rounded, color: GlossyColors.emeraldMint, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'CAKE SQM QoS',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: isEnabled ? 'A+ Low Latency' : 'Standby',
                dotColor: isEnabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Common Applications Kept Enhanced (CAKE) dynamically manages active queue buffers to guarantee sub-10ms latency for competitive gaming and video calls, preventing bufferbloat during concurrent 4K streaming.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Download Limit', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        '${network?.sqmDownloadMbps.toStringAsFixed(1) ?? "95.0"} Mbps ↓',
                        style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Upload Limit', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(
                        '${network?.sqmUploadMbps.toStringAsFixed(1) ?? "20.0"} Mbps ↑',
                        style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 12, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Active Queue Discipline (${network?.sqmQdisc.toUpperCase() ?? "CAKE"})',
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: onOpenTuneModal,
                      child: const Text(
                        'Tap to configure bandwidth limits',
                        style: TextStyle(color: GlossyColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isEnabled,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
