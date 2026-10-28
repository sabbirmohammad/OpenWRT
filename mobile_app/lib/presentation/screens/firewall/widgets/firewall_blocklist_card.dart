import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/client_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class FirewallBlocklistCard extends StatelessWidget {
  final List<ClientInfo> blockedClients;
  final VoidCallback onOpenBlockSheet;
  final Function(String mac) onUnblockClient;

  const FirewallBlocklistCard({
    super.key,
    required this.blockedClients,
    required this.onOpenBlockSheet,
    required this.onUnblockClient,
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
                    const Icon(Icons.block_rounded, color: GlossyColors.roseCoral, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Firewall Blocklist',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${blockedClients.length} Blocked',
                      dotColor: blockedClients.isNotEmpty ? GlossyColors.roseCoral : GlossyColors.emeraldMint,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Block MAC',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.roseCoral, size: 22),
                onPressed: onOpenBlockSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Hardware devices blocked at the kernel forward chain. All internet packets from these MACs are dropped immediately.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (blockedClients.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No devices currently blocked at the firewall.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...blockedClients.map((client) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phonelink_erase_rounded, color: GlossyColors.roseCoral, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.hostname,
                              style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'MAC: ${client.mac.toUpperCase()} • IP: ${client.ip}',
                              style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => onUnblockClient(client.mac),
                        icon: const Icon(Icons.lock_open_rounded, size: 14, color: GlossyColors.emeraldMint),
                        label: const Text('Unblock', style: TextStyle(color: GlossyColors.emeraldMint, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }
}
