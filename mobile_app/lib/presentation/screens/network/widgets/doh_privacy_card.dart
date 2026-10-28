import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class DohPrivacyCard extends StatelessWidget {
  final NetworkInfo? network;
  final ValueChanged<bool> onToggle;

  const DohPrivacyCard({
    super.key,
    required this.network,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = network?.dohEnabled ?? false;

    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.enhanced_encryption_rounded, color: GlossyColors.primaryBlue, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'DNS-over-HTTPS (DoH) Privacy',
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
                label: isEnabled ? 'TLS 1.3 Active' : 'Off',
                dotColor: isEnabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Encrypts all DNS queries with HTTPS (port 443), preventing ISP metadata logging, SNI spoofing, and ISP advertisement injection.',
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
                      network?.dohProvider ?? 'Cloudflare (1.1.1.1)',
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text('Zero Logging • DNSSEC Validated', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
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
