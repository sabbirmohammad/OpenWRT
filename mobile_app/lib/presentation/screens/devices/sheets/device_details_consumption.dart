import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_card.dart';

class DeviceDetailsConsumption extends StatelessWidget {
  final ClientInfo client;
  final String dlSpeed;
  final String ulSpeed;
  final String totalSpeed;

  const DeviceDetailsConsumption({
    super.key,
    required this.client,
    required this.dlSpeed,
    required this.ulSpeed,
    required this.totalSpeed,
  });

  @override
  Widget build(BuildContext context) {
    final totalBytes = client.rxBytes + client.txBytes;
    final rxRatio = totalBytes > 0 ? (client.rxBytes / totalBytes) : 0.5;

    return GlossyCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.speed_rounded, size: 16, color: GlossyColors.lightBlue),
                  SizedBox(width: 6),
                  Text(
                    'DATA CONSUMPTION',
                    style: TextStyle(
                      color: GlossyColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: GlossyColors.emeraldMint.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GlossyColors.emeraldMint.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Live: $totalSpeed',
                  style: const TextStyle(
                    color: GlossyColors.emeraldMint,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Current Live Speeds Row
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: GlossyColors.emeraldMint,
                  title: 'Current Download',
                  value: dlSpeed,
                  subtitle: 'Real-time throughput',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: GlossyColors.skyBlue,
                  title: 'Current Upload',
                  value: ulSpeed,
                  subtitle: 'Real-time throughput',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: GlossyColors.glassDivider),
          const SizedBox(height: 10),

          // Overall Consumption Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Data Consumed',
                    style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    client.formattedTotalTraffic,
                    style: const TextStyle(
                      color: GlossyColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'RX (Down)',
                        style: TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                      ),
                      Text(
                        client.formattedRx,
                        style: const TextStyle(
                          color: GlossyColors.emeraldMint,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'TX (Up)',
                        style: TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                      ),
                      Text(
                        client.formattedTx,
                        style: const TextStyle(
                          color: GlossyColors.skyBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Visual Download vs Upload Ratio Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 6,
              color: GlossyColors.skyBlue.withValues(alpha: 0.3),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: rxRatio.clamp(0.02, 0.98),
                child: Container(color: GlossyColors.emeraldMint),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }
}
