import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SecurityRebindCard extends StatelessWidget {
  final bool isRebindActive;
  final bool isTogglingDnsRebind;
  final VoidCallback onToggle;

  const SecurityRebindCard({
    super.key,
    required this.isRebindActive,
    required this.isTogglingDnsRebind,
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
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (isRebindActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.security_update_good_rounded,
                  color: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'DNS Rebinding Attack Guard',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GlossyBadge(
                label: isRebindActive ? 'Guarded' : 'Unfiltered',
                dotColor: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Prevents malicious external websites from querying RFC 1918 private LAN IP addresses via upstream DNS responses.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isRebindActive ? 'RFC 1918 Filter Enforced (dnsmasq)' : 'Rebinding protection disabled',
                  style: TextStyle(
                    color: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isRebindActive,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: isTogglingDnsRebind ? null : (_) => onToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
