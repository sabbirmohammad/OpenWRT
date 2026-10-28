import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_card.dart';

class SecurityThreatMatrixCard extends StatelessWidget {
  final bool isPmfActive;
  final bool isRebindActive;
  final bool isWanLockActive;

  const SecurityThreatMatrixCard({
    super.key,
    required this.isPmfActive,
    required this.isRebindActive,
    required this.isWanLockActive,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_rounded, color: GlossyColors.emeraldMint, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Automated Threat Defenses',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildDefenseRow('802.11w PMF Frame Shield', 'Deauth attack & frame spoof filter', isPmfActive),
          _buildDefenseRow('DNS Rebinding Shield', 'Blocks malicious LAN IP resolution', isRebindActive),
          _buildDefenseRow('Remote WAN Access Lockdown', 'Drops incoming WAN port 80/443/22', isWanLockActive),
          _buildDefenseRow('SYN Flood Defense (SYN Cookies)', 'Protects against half-open TCP exhaustion', true),
          _buildDefenseRow('Bogon / Martian Packet Filter', 'Discards invalid WAN source IP packets', true),
          _buildDefenseRow('Brute-Force SSH Rate Limiting', 'Temporary ban on repeated password failures', true),
          _buildDefenseRow('Guest Network Isolation', 'Hardware VLAN isolation separating visitors', true),
          _buildDefenseRow('WPS PIN Attack Lockout', 'Mitigates Pixie Dust and Reaver PIN attacks', true),
        ],
      ),
    );
  }

  Widget _buildDefenseRow(String title, String desc, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  desc,
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
            color: enabled ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
            size: 18,
          ),
        ],
      ),
    );
  }
}
