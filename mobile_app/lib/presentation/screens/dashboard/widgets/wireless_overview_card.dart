import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class WirelessOverviewCard extends StatelessWidget {
  final RouterStatusModel status;

  const WirelessOverviewCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Row(
                  children: [
                    Icon(Icons.wifi, color: GlossyColors.primaryBlue, size: 18),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Wireless Radios',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: '${status.wireless.totalConnectedClients} Clients',
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRadioTile(
                  band: '2.4 GHz',
                  ssid: status.wireless.radio2g.ssid,
                  channel: status.wireless.radio2g.channel,
                  powerDbm: status.wireless.radio2g.txpowerDbm,
                  clients: status.wireless.radio2g.connectedClients,
                  enabled: status.wireless.radio2g.enabled,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRadioTile(
                  band: '5.0 GHz',
                  ssid: status.wireless.radio5g.ssid,
                  channel: status.wireless.radio5g.channel,
                  powerDbm: status.wireless.radio5g.txpowerDbm,
                  clients: status.wireless.radio5g.connectedClients,
                  enabled: status.wireless.radio5g.enabled,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRadioTile({
    required String band,
    required String ssid,
    required int channel,
    required int powerDbm,
    required int clients,
    required bool enabled,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                band,
                style: const TextStyle(
                  color: GlossyColors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: enabled ? GlossyColors.emeraldMint : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ssid,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Ch $channel • $powerDbm dBm • $clients dev',
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
