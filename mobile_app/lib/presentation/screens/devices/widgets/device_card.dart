import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import '../utils/device_icon_helper.dart';

class DeviceCard extends StatelessWidget {
  final ClientInfo client;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const DeviceCard({
    super.key,
    required this.client,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final signalColor = DeviceIconHelper.resolveSignalColor(client.signalDbm);
    final isBlocked = client.blocked;
    final isIsolated = client.isIsolated;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: GlossyCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          borderColor: isBlocked
              ? GlossyColors.roseCoral.withValues(alpha: 0.4)
              : (isIsolated
                  ? GlossyColors.isolatedAccent.withValues(alpha: 0.5)
                  : null),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Device Type Icon Avatar
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: (isBlocked
                          ? GlossyColors.roseCoral
                          : (isIsolated
                              ? GlossyColors.isolatedAccent
                              : GlossyColors.primaryBlue))
                      .withValues(alpha: isIsolated ? 0.16 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (isBlocked
                            ? GlossyColors.roseCoral
                            : (isIsolated
                                ? GlossyColors.isolatedAccent
                                : GlossyColors.lightBlue))
                        .withValues(alpha: isIsolated ? 0.5 : 0.3),
                  ),
                ),
                child: Icon(
                  DeviceIconHelper.resolveDeviceIcon(client),
                  size: 24,
                  color: isBlocked
                      ? GlossyColors.roseCoral
                      : (isIsolated
                          ? GlossyColors.isolatedLight
                          : GlossyColors.lightBlue),
                ),
              ),
              const SizedBox(width: 14),

              // Device Info Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Device Name & Network Quality Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.displayName,
                            style: TextStyle(
                              color: isBlocked
                                  ? GlossyColors.roseCoral
                                  : GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (isBlocked)
                          const GlossyBadge(
                            label: 'Blocked',
                            dotColor: GlossyColors.roseCoral,
                          )
                        else if (isIsolated)
                          GlossyBadge(
                            label: client.signalDbm != 0
                                ? 'Isolated • ${client.signalDbm} dBm'
                                : 'Isolated SSID',
                            dotColor: GlossyColors.isolatedAccent,
                          )
                        else if (!client.connectionType.contains('LAN'))
                          GlossyBadge(
                            label: '${client.signalDbm} dBm • ${client.signalQualityText}',
                            dotColor: signalColor,
                          )
                        else
                          const GlossyBadge(
                            label: 'Gigabit LAN',
                            dotColor: GlossyColors.emeraldMint,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),

                    // Row 2: Connected Network Band & SSID
                    Row(
                      children: [
                        Icon(
                          isIsolated
                              ? Icons.wifi_lock_rounded
                              : (client.connectionType.contains('LAN')
                                  ? Icons.settings_ethernet_rounded
                                  : Icons.wifi_rounded),
                          size: 13,
                          color: isIsolated
                              ? GlossyColors.isolatedLight
                              : GlossyColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            isIsolated
                                ? 'Isolated Wi-Fi • SSID: ${client.ssidName.isNotEmpty ? client.ssidName : "Isolated"}'
                                : '${client.connectionType} • SSID: ${client.ssidName.isNotEmpty ? client.ssidName : (client.connectionType.contains('LAN') ? 'Ethernet LAN' : 'Wi-Fi')}',
                            style: TextStyle(
                              color: isIsolated
                                  ? GlossyColors.isolatedLight
                                  : GlossyColors.skyBlue,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Row 3: MAC Address & IP Address
                    Row(
                      children: [
                        const Icon(Icons.fingerprint_rounded, size: 13, color: GlossyColors.textMuted),
                        const SizedBox(width: 4),
                        Text(
                          client.mac,
                          style: const TextStyle(
                            color: GlossyColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${client.ip}',
                          style: const TextStyle(
                            color: GlossyColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 6),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: isIsolated
                    ? GlossyColors.isolatedLight.withValues(alpha: 0.8)
                    : GlossyColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
