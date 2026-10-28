import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../widgets/glossy_card.dart';
import 'firewall_switch_row.dart';

class FirewallOffloadCard extends StatelessWidget {
  final FirewallInfo fw;
  final bool isTogglingFlowOffload;
  final bool isTogglingHwFlowOffload;
  final bool isTogglingMssClamping;
  final bool isTogglingAntiSpoofing;
  final bool isTogglingIpv6;
  final ValueChanged<bool> onToggleFlowOffload;
  final ValueChanged<bool> onToggleHwFlowOffload;
  final ValueChanged<bool> onToggleMssClamping;
  final ValueChanged<bool> onToggleAntiSpoofing;
  final ValueChanged<bool> onToggleIpv6;

  const FirewallOffloadCard({
    super.key,
    required this.fw,
    required this.isTogglingFlowOffload,
    required this.isTogglingHwFlowOffload,
    required this.isTogglingMssClamping,
    required this.isTogglingAntiSpoofing,
    required this.isTogglingIpv6,
    required this.onToggleFlowOffload,
    required this.onToggleHwFlowOffload,
    required this.onToggleMssClamping,
    required this.onToggleAntiSpoofing,
    required this.onToggleIpv6,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: GlossyColors.lightBlue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'NAT Flow Offloading',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Hardware and kernel offloading mechanisms that optimize high-speed throughput and prevent MTU packet fragmentation.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          FirewallSwitchRow(
            title: 'Software Flow Offload',
            subtitle: 'Bypasses standard TCP/UDP stack for established flows',
            value: fw.flowOffload,
            isLoading: isTogglingFlowOffload,
            activeColor: GlossyColors.lightBlue,
            onChanged: onToggleFlowOffload,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'Hardware Flow Offload (MT7621 PPE)',
            subtitle: 'Dedicated MediaTek silicon acceleration (940+ Mbps @ 0% CPU)',
            value: fw.flowOffloadHw,
            isLoading: isTogglingHwFlowOffload,
            activeColor: GlossyColors.emeraldMint,
            onChanged: onToggleHwFlowOffload,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'TCP MSS Clamping (MTU Fix)',
            subtitle: 'Clamps TCP SYN MSS to WAN MTU to prevent packet stalling',
            value: fw.mssClamping,
            isLoading: isTogglingMssClamping,
            activeColor: GlossyColors.primaryBlue,
            onChanged: onToggleMssClamping,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'Anti-Spoofing & Martian Filter (rp_filter)',
            subtitle: 'Discards packets with forged or impossible source IP (RFC 2827)',
            value: fw.antiSpoofing,
            isLoading: isTogglingAntiSpoofing,
            activeColor: GlossyColors.amberWarm,
            onChanged: onToggleAntiSpoofing,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'IPv6 Stateful Firewall',
            subtitle: 'Blocks unsolicited incoming IPv6 WAN scans and probes',
            value: fw.ipv6Firewall,
            isLoading: isTogglingIpv6,
            activeColor: GlossyColors.lightBlue,
            onChanged: onToggleIpv6,
          ),
        ],
      ),
    );
  }
}
