import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SecurityPmfCard extends StatelessWidget {
  final bool isPmfActive;
  final bool isTogglingPmf;
  final VoidCallback onToggle;

  const SecurityPmfCard({
    super.key,
    required this.isPmfActive,
    required this.isTogglingPmf,
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
                  color: (isPmfActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.wifi_password_rounded,
                  color: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  '802.11w PMF Deauth Defense',
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
                label: isPmfActive ? 'Protected' : 'Vulnerable',
                dotColor: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Cryptographically signs Wi-Fi management frames. Thwarts deauth packet spoofing, Evil Twin rogue APs, and handshake capture attacks.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isPmfActive ? 'ieee80211w Required / Capable' : 'Management frames unencrypted',
                  style: TextStyle(
                    color: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isPmfActive,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: isTogglingPmf ? null : (_) => onToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
