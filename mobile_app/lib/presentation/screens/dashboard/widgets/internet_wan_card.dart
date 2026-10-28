import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import '../../../widgets/traffic_sparkline.dart';

class InternetWanCard extends StatelessWidget {
  final RouterStatusModel status;
  final RouterController controller;

  const InternetWanCard({
    super.key,
    required this.status,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.public, color: GlossyColors.primaryBlue, size: 18),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Internet (WAN)',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GlossyColors.emeraldMint.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record, size: 6, color: GlossyColors.emeraldMint),
                          SizedBox(width: 3),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: GlossyColors.emeraldMint,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: status.traffic.wanIp,
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSpeedMeter(
                  label: 'Live Download',
                  speed: controller.formattedDownloadSpeed,
                  color: GlossyColors.emeraldMint,
                  icon: Icons.arrow_downward_rounded,
                  history: controller.downloadSpeedHistory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSpeedMeter(
                  label: 'Live Upload',
                  speed: controller.formattedUploadSpeed,
                  color: GlossyColors.lightBlue,
                  icon: Icons.arrow_upward_rounded,
                  history: controller.uploadSpeedHistory,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GlossyColors.glassBorderDark),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Rx: ', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
                      Flexible(
                        child: Text(
                          status.traffic.formattedRx,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 12, color: GlossyColors.glassDivider),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Total Tx: ', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
                      Flexible(
                        child: Text(
                          status.traffic.formattedTx,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (status.network.gateway.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Gateway: ${status.network.gateway}',
                    style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Protocol: ${status.network.protocol}',
                    style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpeedMeter({
    required String label,
    required String speed,
    required Color color,
    required IconData icon,
    required List<double> history,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(icon, color: color, size: 14),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 5, height: 5, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            speed,
            style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          TrafficSparkline(data: history, color: color, height: 20),
        ],
      ),
    );
  }
}
