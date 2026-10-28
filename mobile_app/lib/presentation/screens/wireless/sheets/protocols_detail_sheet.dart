import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_button.dart';
import 'protocols/protocol_section_card.dart';

class ProtocolsDetailSheet extends StatelessWidget {
  const ProtocolsDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.only(top: 12, left: 18, right: 18, bottom: 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: GlossyColors.glassBorderLight, width: 1.5),
          left: BorderSide(color: GlossyColors.glassBorderLight, width: 1),
          right: BorderSide(color: GlossyColors.glassBorderLight, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.cell_tower_rounded, color: GlossyColors.lightBlue, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Wi-Fi Protocols & Roaming',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Archer C6 Hardware Silicon & RF Standards',
                      style: TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: GlossyColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: GlossyColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.memory_rounded, color: GlossyColors.lightBlue, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'MediaTek Dual-Band SoC Architecture',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'radio0: MT7603E (2.4GHz) • radio1: MT7613BEN (5GHz Wave 2)',
                        style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  ProtocolSectionCard(
                    icon: Icons.sync_rounded,
                    title: '802.11r FT (Fast BSS Transition)',
                    badge: 'Sub-50ms Handoff',
                    badgeColor: GlossyColors.emeraldMint,
                    description: 'Allows client devices to roam seamlessly between APs and frequency bands without performing the full 4-way WPA handshake. Pre-authenticates transition keys so Zoom, WhatsApp, or VoIP calls never drop when moving around.',
                    specs: [
                      {'Standard': 'IEEE 802.11r-2008'},
                      {'Reassociation': '< 50 milliseconds'},
                      {'Voice/Video Loss': 'Zero packet drop'},
                    ],
                  ),
                  SizedBox(height: 12),
                  ProtocolSectionCard(
                    icon: Icons.explore_rounded,
                    title: '802.11k & 802.11v (Assisted Steering)',
                    badge: 'Smart Steering',
                    badgeColor: GlossyColors.lightBlue,
                    description: '802.11k provides neighbor AP and channel radio measurement reports, while 802.11v directs clients to optimal BSS IDs. Together they automatically nudge dual-band phones to 5.0 GHz when close and to 2.4 GHz when range drops.',
                    specs: [
                      {'802.11k': 'Radio Resource Management'},
                      {'802.11v': 'BSS Transition Management'},
                      {'Band Optimization': 'Dynamic RSSI Steering'},
                    ],
                  ),
                  SizedBox(height: 12),
                  ProtocolSectionCard(
                    icon: Icons.speed_rounded,
                    title: '802.11ac Wave 2 (MU-MIMO 2x2)',
                    badge: '867 Mbps Peak',
                    badgeColor: GlossyColors.amberWarm,
                    description: 'Multi-User Multiple-Input Multiple-Output allows simultaneous transmission to multiple client devices concurrently rather than waiting in serial turns. Maximizes airtime efficiency in high-density smart homes.',
                    specs: [
                      {'Spatial Streams': '2x2 MU-MIMO'},
                      {'Channel Width': '80 MHz (VHT80)'},
                      {'Beamforming': 'TxBF Explicit Beamforming'},
                    ],
                  ),
                  SizedBox(height: 12),
                  ProtocolSectionCard(
                    icon: Icons.security_rounded,
                    title: '802.11w PMF (Protected Management Frames)',
                    badge: 'Deauth Shield',
                    badgeColor: GlossyColors.emeraldMint,
                    description: 'Cryptographically signs unicast and multicast Wi-Fi management action frames (disassociate/deauthenticate) using BIP. Effectively renders rogue deauth packets and evil-twin disruption attacks completely harmless.',
                    specs: [
                      {'Standard': 'IEEE 802.11w-2009'},
                      {'Protection': 'BIP Management Integrity'},
                      {'WPA3 Prerequisite': 'Mandatory for SAE'},
                    ],
                  ),
                  SizedBox(height: 12),
                  ProtocolSectionCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'WPA2-PSK / WPA3-SAE (Hybrid Security)',
                    badge: 'Dragonfly SAE',
                    badgeColor: GlossyColors.lightBlue,
                    description: 'Provides state-of-the-art Simultaneous Authentication of Equals (SAE) with forward secrecy, preventing offline dictionary attacks while preserving seamless backwards compatibility for legacy 2.4GHz IoT hardware.',
                    specs: [
                      {'Key Exchange': 'Dragonfly Handshake'},
                      {'Forward Secrecy': 'Active Session Ephemeral'},
                      {'Compatibility': 'WPA2/WPA3 Mixed Transition'},
                    ],
                  ),
                  SizedBox(height: 12),
                  ProtocolSectionCard(
                    icon: Icons.multitrack_audio_rounded,
                    title: 'WMM QoS (Wireless Multimedia)',
                    badge: 'HW Queued',
                    badgeColor: GlossyColors.emeraldMint,
                    description: 'Wi-Fi Multimedia traffic prioritization divides transmission into 4 Access Categories (Voice, Video, Best Effort, Background) so gaming packets and video streams take precedence over background downloads.',
                    specs: [
                      {'VO (Voice)': 'Highest priority queue'},
                      {'VI (Video)': 'Prioritized throughput'},
                      {'Offload': 'Hardware MediaTek Queue'},
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GlossyButton(
            label: 'Close Standards Explorer',
            icon: Icons.check_circle_outline_rounded,
            style: GlossyButtonStyle.primary,
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
