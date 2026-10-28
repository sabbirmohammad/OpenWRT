import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';
import '../../devices/utils/device_icon_helper.dart';

class ConnectedDevicesSheet extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> clients;

  const ConnectedDevicesSheet({super.key, required this.ssid, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ssid.ssid} Clients',
                    style: const TextStyle(
                      color: GlossyColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${clients.length} device(s) currently connected',
                    style: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              GlossyBadge(
                label: '${clients.length} Online',
                dotColor: clients.isNotEmpty ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (clients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.devices_outlined, color: GlossyColors.textMuted, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'No devices connected to "${ssid.ssid}"',
                      style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connected clients will appear here automatically.',
                      style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: clients.length,
                separatorBuilder: (_, _) => const Divider(color: GlossyColors.glassDivider, height: 12),
                itemBuilder: (ctx, idx) {
                  final client = clients[idx];
                  final signalColor = DeviceIconHelper.resolveSignalColor(client.signalDbm);
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
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
                            DeviceIconHelper.resolveDeviceIcon(client),
                            color: GlossyColors.lightBlue,
                            size: 19,
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
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (client.vendor != null && client.vendor!.isNotEmpty) ...[
                                    const SizedBox(width: 6),
                                    Text(
                                      '(${client.vendor})',
                                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${client.ip} • ${client.mac}',
                                style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                              ),
                              if (client.rxBytes > 0 || client.txBytes > 0) ...[
                                const SizedBox(height: 3),
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
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GlossyBadge(
                              label: '${client.signalDbm} dBm',
                              dotColor: signalColor,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              client.signalQualityText,
                              style: TextStyle(
                                color: signalColor,
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
            ),
        ],
      ),
    );
  }
}
