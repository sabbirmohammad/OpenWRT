import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class NetworkWireguardCard extends StatelessWidget {
  final NetworkInfo? network;
  final ValueChanged<bool> onToggle;

  const NetworkWireguardCard({
    super.key,
    required this.network,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = network?.wireguardEnabled ?? false;

    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_lock_rounded, color: GlossyColors.lightBlue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'WireGuard VPN Tunnel',
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
                label: isEnabled ? 'wg0 Connected' : 'Standby',
                dotColor: isEnabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'High-performance kernel-space encrypted tunnel connecting entire LAN to remote gateway or cloud VPS.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      network?.wireguardEndpoint ?? 'sg-vpn.cyberguard.net:51820',
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Handshake: ${network?.wireguardLatestHandshake ?? "Never"}',
                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          if (isEnabled) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RX: ${Formatters.formatBytes(network?.wireguardTransferRx ?? 0)}',
                      style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'TX: ${Formatters.formatBytes(network?.wireguardTransferTx ?? 0)}',
                      style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
