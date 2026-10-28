import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/client_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';
import '../../../widgets/glossy_input.dart';

class SecurityBlocklistCard extends StatelessWidget {
  final List<ClientInfo> clients;
  final List<ClientInfo> blockedClients;
  final TextEditingController macController;
  final bool isBlockingMac;
  final VoidCallback onSelectConnectedDevice;
  final VoidCallback onBlockCustomMac;
  final Function(String mac) onUnblockClient;

  const SecurityBlocklistCard({
    super.key,
    required this.clients,
    required this.blockedClients,
    required this.macController,
    required this.isBlockingMac,
    required this.onSelectConnectedDevice,
    required this.onBlockCustomMac,
    required this.onUnblockClient,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: GlossyColors.roseCoral, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Client Access & Blocklist',
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
                label: '${blockedClients.length} Blocked',
                dotColor: blockedClients.isEmpty ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Enforces kernel-level DROP rules at forward chain and instant 802.11 deauthentication.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.devices_rounded, size: 18, color: Colors.white),
              label: Text(
                'Quick Action: Select Connected Device (${clients.length} Online)',
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: GlossyColors.primaryBlue.withValues(alpha: 0.35),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: GlossyColors.lightBlue, width: 0.8),
                ),
              ),
              onPressed: onSelectConnectedDevice,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GlossyInput(
                  controller: macController,
                  label: 'Block Target MAC Address',
                  hint: 'ca:66:df:1b:b0:17',
                  prefixIcon: Icons.fingerprint_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: GlossyButton(
                  label: 'Block',
                  icon: Icons.block_rounded,
                  style: GlossyButtonStyle.danger,
                  isLoading: isBlockingMac,
                  onPressed: onBlockCustomMac,
                ),
              ),
            ],
          ),
          if (blockedClients.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Currently Blocked Devices:',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...blockedClients.map(
              (c) => Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: GlossyColors.roseCoral.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GlossyColors.roseCoral.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.displayName.isNotEmpty ? c.displayName : 'Unknown Device',
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            c.mac,
                            style: const TextStyle(
                              color: GlossyColors.textSecondary,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GlossyColors.emeraldMint,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        minimumSize: const Size(60, 30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => onUnblockClient(c.mac),
                      child: const Text(
                        'Unblock',
                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
