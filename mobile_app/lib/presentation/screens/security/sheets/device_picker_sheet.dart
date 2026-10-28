import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/client_info.dart';
import '../../../widgets/glossy_badge.dart';

class DevicePickerSheet extends StatelessWidget {
  final List<ClientInfo> clients;
  final Function(String mac, String hostname) onKickClient;
  final Function(String mac) onBlockClient;
  final Function(String mac) onUnblockClient;

  const DevicePickerSheet({
    super.key,
    required this.clients,
    required this.onKickClient,
    required this.onBlockClient,
    required this.onUnblockClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      decoration: BoxDecoration(
        color: GlossyColors.backgroundSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Client to Kick or Block',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Direct hardware deauth & firewall drop rules',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GlossyBadge(
                label: '${clients.length} Online',
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: clients.isEmpty
                ? const Center(
                    child: Text(
                      'No active connected clients found.',
                      style: TextStyle(color: GlossyColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    itemCount: clients.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final client = clients[index];
                      final isBlocked = client.blocked;

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isBlocked
                                ? GlossyColors.roseCoral.withValues(alpha: 0.4)
                                : GlossyColors.glassBorderLight,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: (isBlocked ? GlossyColors.roseCoral : GlossyColors.primaryBlue)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                client.connectionType.contains('LAN')
                                    ? Icons.settings_ethernet_rounded
                                    : Icons.wifi_rounded,
                                color: isBlocked ? GlossyColors.roseCoral : GlossyColors.lightBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    client.displayName,
                                    style: const TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${client.ip} • ${client.mac}',
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
                            if (!isBlocked) ...[
                              IconButton(
                                tooltip: 'Kick from Wi-Fi (802.11 deauth)',
                                icon: const Icon(Icons.wifi_off_rounded, color: GlossyColors.amberWarm, size: 20),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onKickClient(client.mac, client.displayName);
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlossyColors.roseCoral.withValues(alpha: 0.2),
                                  foregroundColor: GlossyColors.roseCoral,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(56, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: GlossyColors.roseCoral.withValues(alpha: 0.4)),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onBlockClient(client.mac);
                                },
                                child: const Text('Block', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ] else
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlossyColors.emeraldMint.withValues(alpha: 0.2),
                                  foregroundColor: GlossyColors.emeraldMint,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: BorderSide(color: GlossyColors.emeraldMint.withValues(alpha: 0.4)),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  onUnblockClient(client.mac);
                                },
                                child: const Text('Unblock', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
