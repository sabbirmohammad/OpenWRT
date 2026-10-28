import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_card.dart';

class DeviceDetailsNetwork extends StatelessWidget {
  final ClientInfo client;
  final void Function(String text, String label) onCopy;

  const DeviceDetailsNetwork({
    super.key,
    required this.client,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SECTION 2: Connection Time & Network Duration
        GlossyCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 16, color: GlossyColors.amberWarm),
                  SizedBox(width: 6),
                  Text(
                    'CONNECTION TIMING & UPTIME',
                    style: TextStyle(
                      color: GlossyColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Connected Since',
                          style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          client.formattedConnectedSince,
                          style: const TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 36,
                    color: GlossyColors.glassDivider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Active Duration',
                          style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          client.formattedUptime,
                          style: const TextStyle(
                            color: GlossyColors.amberWarm,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // SECTION 3: Hardware & Network Addressing
        GlossyCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.settings_ethernet_rounded, size: 16, color: GlossyColors.lightBlue),
                  SizedBox(width: 6),
                  Text(
                    'NETWORK & HARDWARE ADDRESSING',
                    style: TextStyle(
                      color: GlossyColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildAddressRow(
                icon: Icons.link_rounded,
                label: 'IP Address',
                value: client.ip,
                onCopy: () => onCopy(client.ip, 'IP Address'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: GlossyColors.glassDivider),
              ),
              _buildAddressRow(
                icon: Icons.fingerprint_rounded,
                label: 'MAC Address',
                value: client.mac,
                onCopy: () => onCopy(client.mac, 'MAC Address'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: GlossyColors.glassDivider),
              ),
              _buildAddressRow(
                icon: client.isIsolated
                    ? Icons.wifi_lock_rounded
                    : Icons.wifi_tethering_rounded,
                label: 'Network SSID',
                value: client.isIsolated
                    ? '${client.ssidName.isNotEmpty ? client.ssidName : "Isolated"} (Isolated SSID)'
                    : (client.ssidName.isNotEmpty
                        ? client.ssidName
                        : 'Ethernet Physical Link'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: GlossyColors.glassDivider),
              ),
              _buildAddressRow(
                icon: Icons.network_check_rounded,
                label: 'Signal Strength',
                value: client.connectionType.contains('LAN')
                    ? 'Wired (LAN Link)'
                    : '${client.signalDbm} dBm (${client.signalQualityPercent}%)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: GlossyColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: GlossyColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.copy_rounded, size: 13, color: GlossyColors.lightBlue),
            ),
          ),
        ],
      ],
    );
  }
}
