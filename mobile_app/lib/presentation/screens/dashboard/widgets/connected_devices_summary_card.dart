import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/client_info.dart';
import '../../../widgets/glossy_card.dart';

class ConnectedDevicesSummaryCard extends StatelessWidget {
  final List<ClientInfo> clients;
  final ValueChanged<int>? onNavigateToTab;

  const ConnectedDevicesSummaryCard({
    super.key,
    required this.clients,
    this.onNavigateToTab,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.devices, color: GlossyColors.primaryBlue, size: 18),
              const SizedBox(width: 8),
              Text(
                'Connected Devices (${clients.length})',
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (clients.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No active client devices detected.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: clients.length > 5 ? 5 : clients.length,
              separatorBuilder: (_, _) => const Divider(color: GlossyColors.glassDivider),
              itemBuilder: (ctx, idx) {
                final client = clients[idx];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          client.connectionType.contains('5GHz')
                              ? Icons.wifi_sharp
                              : Icons.phone_android,
                          size: 18,
                          color: GlossyColors.lightBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.hostname,
                              style: const TextStyle(
                                color: GlossyColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${client.ip} • ${client.connectionType}',
                              style: const TextStyle(
                                color: GlossyColors.textSecondary,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${client.signalDbm} dBm',
                        style: TextStyle(
                          color: client.signalDbm > -65
                              ? GlossyColors.emeraldMint
                              : GlossyColors.amberWarm,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          if (onNavigateToTab != null) ...[
            const SizedBox(height: 8),
            InkWell(
              onTap: () => onNavigateToTab!(1),
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Manage All ${clients.length} Devices',
                      style: const TextStyle(
                        color: GlossyColors.lightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_rounded, size: 14, color: GlossyColors.lightBlue),
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
