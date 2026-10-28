import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SecurityDohCard extends StatelessWidget {
  final bool isDohActive;
  final bool isTogglingDoh;
  final ValueChanged<bool> onToggle;

  const SecurityDohCard({
    super.key,
    required this.isDohActive,
    required this.isTogglingDoh,
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
              const Icon(Icons.lock_clock_rounded, color: GlossyColors.emeraldMint, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DNS-over-HTTPS (DoH) Privacy',
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
                label: isDohActive ? 'Encrypted' : 'Standard DNS',
                dotColor: isDohActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Prevents ISP and man-in-the-middle DNS snooping by routing all DNS queries through TLS 1.3.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'DoH Upstream Provider',
                      style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                    ),
                    Text(
                      'Cloudflare (1.1.1.1) • Port 443 TLS',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
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
                value: isDohActive,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: isTogglingDoh ? null : onToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
