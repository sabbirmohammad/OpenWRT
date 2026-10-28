import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/firewall_info.dart';
import '../../../widgets/glossy_card.dart';
import 'firewall_switch_row.dart';
import 'firewall_zone_card.dart';

class FirewallZonesCard extends StatelessWidget {
  final FirewallInfo fw;
  final bool isTogglingGuestIso;
  final bool isTogglingDmz;
  final ValueChanged<bool> onToggleGuestIso;
  final ValueChanged<bool> onToggleDmz;
  final VoidCallback onOpenDmzConfig;

  const FirewallZonesCard({
    super.key,
    required this.fw,
    required this.isTogglingGuestIso,
    required this.isTogglingDmz,
    required this.onToggleGuestIso,
    required this.onToggleDmz,
    required this.onOpenDmzConfig,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lan_outlined, color: GlossyColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Zone Forwarding & Isolation',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const FirewallZoneCard(name: 'LAN Zone (Private)', iface: 'br-lan', forward: 'wan (ACCEPT)', input: 'lan (ACCEPT)', accent: GlossyColors.emeraldMint),
          const SizedBox(height: 8),
          const FirewallZoneCard(name: 'WAN Zone (Public)', iface: 'eth0.2', forward: 'lan (REJECT)', input: 'wan (DROP)', accent: GlossyColors.roseCoral),
          const SizedBox(height: 8),
          FirewallZoneCard(name: 'Guest Zone (Isolated)', iface: 'br-guest', forward: 'wan (ACCEPT)', input: fw.guestIsolation ? 'lan (DROP)' : 'lan (ACCEPT)', accent: GlossyColors.isolatedAccent),
          const SizedBox(height: 16),
          FirewallSwitchRow(
            title: 'Guest Network Isolation',
            subtitle: 'Prevents guest clients from accessing internal LAN servers & NAS',
            value: fw.guestIsolation,
            isLoading: isTogglingGuestIso,
            activeColor: GlossyColors.isolatedAccent,
            onChanged: onToggleGuestIso,
          ),
          const Divider(height: 20, color: GlossyColors.glassBorderLight),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demilitarized Zone (DMZ)',
                      style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fw.dmzEnabled ? 'Forwarding unmapped WAN to ${fw.dmzIp}' : 'Disabled (No DMZ host assigned)',
                      style: TextStyle(color: fw.dmzEnabled ? GlossyColors.amberWarm : GlossyColors.textSecondary, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: fw.dmzEnabled,
                activeThumbColor: GlossyColors.amberWarm,
                activeTrackColor: GlossyColors.amberWarm.withValues(alpha: 0.3),
                onChanged: isTogglingDmz ? null : onToggleDmz,
              ),
            ],
          ),
          if (fw.dmzEnabled) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Host: ${fw.dmzIp}',
                    style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: onOpenDmzConfig,
                  icon: const Icon(Icons.edit_rounded, size: 14, color: GlossyColors.lightBlue),
                  label: const Text('Change IP', style: TextStyle(color: GlossyColors.lightBlue, fontSize: 12)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
