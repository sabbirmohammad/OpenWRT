import 'package:flutter/material.dart';
import '../../../../../core/theme/glossy_colors.dart';
import '../../../../../models/router_status_model.dart';
import '../../../../widgets/glossy_badge.dart';

class SsidDetailClients extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> clients;

  const SsidDetailClients({
    super.key,
    required this.ssid,
    required this.clients,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.devices_rounded, color: GlossyColors.lightBlue, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Connected Devices',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GlossyBadge(
              label: '${clients.length} Online',
              dotColor: clients.isNotEmpty ? GlossyColors.emeraldMint : GlossyColors.textMuted,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (clients.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: GlossyColors.glassBorderLight),
            ),
            child: Column(
              children: [
                const Icon(Icons.devices_outlined, color: GlossyColors.textMuted, size: 36),
                const SizedBox(height: 8),
                Text(
                  'No devices currently connected to "${ssid.ssid}"',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 4),
                const Text(
                  'When devices join this Wi-Fi, their live stats will appear here.',
                  style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: clients.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (ctx, idx) {
              final client = clients[idx];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GlossyColors.glassBorderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: GlossyColors.glassBorderLight),
                      ),
                      child: Icon(
                        client.hostname.toLowerCase().contains('mac') || client.hostname.toLowerCase().contains('pc')
                            ? Icons.laptop_mac_rounded
                            : (client.hostname.toLowerCase().contains('tv')
                                ? Icons.tv_rounded
                                : Icons.phone_android_rounded),
                        color: GlossyColors.lightBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  client.displayName,
                                  style: const TextStyle(
                                    color: GlossyColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (client.vendor != null) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '(${client.vendor})',
                                  style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${client.ip} • ${client.mac}',
                            style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded, color: GlossyColors.lightBlue, size: 11),
                              const SizedBox(width: 2),
                              Text(client.formattedRx, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10)),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_upward_rounded, color: GlossyColors.skyBlue, size: 11),
                              const SizedBox(width: 2),
                              Text(client.formattedTx, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GlossyBadge(
                          label: '${client.signalDbm} dBm',
                          dotColor: client.signalDbm >= -65 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          client.signalQualityText,
                          style: TextStyle(
                            color: client.signalDbm >= -65 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
