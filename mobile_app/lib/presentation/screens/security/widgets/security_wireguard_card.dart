import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SecurityWireguardCard extends StatelessWidget {
  final bool isWgActive;
  final bool isTogglingWireGuard;
  final ValueChanged<bool> onToggle;

  const SecurityWireguardCard({
    super.key,
    required this.isWgActive,
    required this.isTogglingWireGuard,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
                  'WireGuard VPN Tunnel Shield',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: isWgActive ? 'Connected' : 'Standby',
                dotColor: isWgActive ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ChaCha20-Poly1305 peer-to-peer encrypted remote tunnel directly connecting over wg0.',
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
                    const Text(
                      'Tunnel Status',
                      style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      isWgActive ? 'Active (Endpoint: 10.14.0.1:51820)' : 'Tunnel Offline / Standby',
                      style: TextStyle(
                        color: isWgActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isWgActive,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: isTogglingWireGuard ? null : onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
