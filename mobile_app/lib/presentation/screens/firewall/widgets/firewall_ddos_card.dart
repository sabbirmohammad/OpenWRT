import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import 'firewall_switch_row.dart';

class FirewallDdosCard extends StatelessWidget {
  final FirewallInfo fw;
  final bool isTogglingSynFlood;
  final bool isTogglingDropInvalid;
  final bool isTogglingStealth;
  final bool isTogglingWanPing;
  final bool isTogglingWanLock;
  final bool isTogglingDnsRebind;
  final ValueChanged<bool> onToggleSynFlood;
  final ValueChanged<bool> onToggleDropInvalid;
  final ValueChanged<bool> onToggleStealth;
  final ValueChanged<bool> onToggleWanPing;
  final ValueChanged<bool> onToggleWanLock;
  final ValueChanged<bool> onToggleDnsRebind;

  const FirewallDdosCard({
    super.key,
    required this.fw,
    required this.isTogglingSynFlood,
    required this.isTogglingDropInvalid,
    required this.isTogglingStealth,
    required this.isTogglingWanPing,
    required this.isTogglingWanLock,
    required this.isTogglingDnsRebind,
    required this.onToggleSynFlood,
    required this.onToggleDropInvalid,
    required this.onToggleStealth,
    required this.onToggleWanPing,
    required this.onToggleWanLock,
    required this.onToggleDnsRebind,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: GlossyColors.emeraldMint, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Cyber Attack & DDoS Defenses',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(
                label: '${fw.activeDefensesCount}/10 Active',
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Stateful kernel shields mitigating SYN floods, port probes, and unauthorized WAN administration access.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          FirewallSwitchRow(
            title: 'TCP SYN Flood Protection',
            subtitle: 'Activates syncookies under memory exhaustion pressure',
            value: fw.synFlood,
            isLoading: isTogglingSynFlood,
            activeColor: GlossyColors.emeraldMint,
            onChanged: onToggleSynFlood,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'Drop Invalid Packets',
            subtitle: 'Silently discards packets that fail conntrack validation',
            value: fw.dropInvalid,
            isLoading: isTogglingDropInvalid,
            activeColor: GlossyColors.emeraldMint,
            onChanged: onToggleDropInvalid,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'Stealth Port Probing Shield',
            subtitle: 'Ignores unsolicited port scans without sending TCP RST response',
            value: fw.stealthMode,
            isLoading: isTogglingStealth,
            activeColor: GlossyColors.lightBlue,
            onChanged: onToggleStealth,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'WAN Ping Response (ICMP Echo)',
            subtitle: fw.wanPing ? 'Router responds to WAN ping requests' : 'Stealth active: Router drops WAN ping requests silently',
            value: fw.wanPing,
            isLoading: isTogglingWanPing,
            activeColor: GlossyColors.amberWarm,
            onChanged: onToggleWanPing,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'Remote WAN Lockdown',
            subtitle: 'Blocks external management access to ports 80/443/22',
            value: fw.wanLockdown,
            isLoading: isTogglingWanLock,
            activeColor: GlossyColors.emeraldMint,
            onChanged: onToggleWanLock,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          FirewallSwitchRow(
            title: 'DNS Rebind Mitigation',
            subtitle: 'Blocks external domains from resolving to private 192.168.x.x',
            value: fw.dnsRebind,
            isLoading: isTogglingDnsRebind,
            activeColor: GlossyColors.emeraldMint,
            onChanged: onToggleDnsRebind,
          ),
        ],
      ),
    );
  }
}
