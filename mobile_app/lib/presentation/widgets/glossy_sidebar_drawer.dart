import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../screens/firewall_screen.dart';
import '../screens/security_screen.dart';
import '../screens/settings_modal.dart';
import '../screens/tools_screen.dart';
import 'glossy_badge.dart';

class GlossySidebarDrawer extends StatelessWidget {
  final RouterController controller;
  final ValueChanged<int>? onNavigateToTab;
  final bool isEndDrawer;

  const GlossySidebarDrawer({
    super.key,
    required this.controller,
    this.onNavigateToTab,
    this.isEndDrawer = true,
  });

  Color _resolveLatencyColor(int ms) {
    if (ms < 0) return GlossyColors.roseCoral;
    if (ms <= 15) return GlossyColors.emeraldMint;
    if (ms <= 50) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  void _confirmReboot(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: const Text(
          'Reboot Router?',
          style: TextStyle(color: GlossyColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will restart your TP-Link Archer C6 router. Network connection will briefly disconnect for ~60 seconds.',
          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.roseCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.executeAction('reboot');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reboot command dispatched to router.'),
                  backgroundColor: GlossyColors.primaryBlue,
                ),
              );
            },
            child: const Text('Reboot Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _flushMemory(BuildContext context) async {
    try {
      await controller.executeAction('drop_caches');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('RAM buffers & cache cleared successfully.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Flush failed: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    }
  }

  Future<void> _toggleStealth(BuildContext context) async {
    final current = controller.status?.stealthLeds ?? false;
    try {
      await controller.executeAction('led_stealth', {
        'value': !current ? 'on' : 'off',
        'enabled': !current,
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current ? 'Stealth LED Mode ON' : 'Stealth LED Mode OFF'),
            backgroundColor: GlossyColors.lightBlue,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stealth toggle failed: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    final isConnected = controller.isConnected;
    final latency = controller.latencyMs;
    final isStealth = status?.stealthLeds ?? false;
    final uptime = status?.cpu.formattedUptime ?? '0m';

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.84,
      child: ClipRRect(
        borderRadius: BorderRadius.horizontal(
          left: isEndDrawer ? const Radius.circular(28) : Radius.zero,
          right: isEndDrawer ? Radius.zero : const Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            decoration: BoxDecoration(
              color: GlossyColors.backgroundSecondary.withValues(alpha: 0.94),
              border: Border(
                left: isEndDrawer
                    ? const BorderSide(color: GlossyColors.glassBorderLight, width: 1.0)
                    : BorderSide.none,
                right: !isEndDrawer
                    ? const BorderSide(color: GlossyColors.glassBorderLight, width: 1.0)
                    : BorderSide.none,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: Offset(isEndDrawer ? -4 : 4, 0),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Drawer Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [GlossyColors.primaryBlue, GlossyColors.lightBlue],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: GlossyColors.primaryBlue.withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.router_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'ArcherGuard C6',
                                    style: TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    controller.routerIp,
                                    style: const TextStyle(
                                      color: GlossyColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.close_rounded, color: GlossyColors.textMuted, size: 20),
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Close Menu',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        // Connection badge & uptime pill
                        Row(
                          children: [
                            GlossyBadge(
                              label: isConnected
                                  ? (latency >= 0 ? '${latency}ms Ping' : 'Online')
                                  : 'Offline',
                              dotColor: isConnected
                                  ? _resolveLatencyColor(latency)
                                  : GlossyColors.roseCoral,
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GlossyColors.glassBorderLight),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.schedule, size: 11, color: GlossyColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Up $uptime',
                                    style: const TextStyle(
                                      color: GlossyColors.textSecondary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
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

                  const Divider(color: GlossyColors.glassBorderDark, height: 1),

                  // Menu Sections List
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            'CONTROL & SECURITY',
                            style: TextStyle(
                              color: GlossyColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                        // 1. Settings Section (সেটিংস)
                        _DrawerMenuTile(
                          icon: Icons.tune_rounded,
                          title: 'Settings',
                          subtitle: 'Gateway IP, port, token & polling',
                          accentColor: GlossyColors.primaryBlue,
                          badge: 'Gateway',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            SettingsModal.show(context, controller);
                          },
                        ),

                        const SizedBox(height: 8),

                        // 2. Security Section (সিকিউরিটি)
                        _DrawerMenuTile(
                          icon: Icons.shield_rounded,
                          title: 'Security',
                          subtitle: 'Stealth LEDs, blocklist & VPN shield',
                          accentColor: GlossyColors.emeraldMint,
                          badge: 'Protected',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SecurityScreen(controller: controller),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // 3. Firewall Section (ফায়ারওয়াল)
                        _DrawerMenuTile(
                          icon: Icons.local_fire_department_rounded,
                          title: 'Firewall',
                          subtitle: 'nftables engine, NAT & DDoS guard',
                          accentColor: GlossyColors.amberWarm,
                          badge: 'Active',
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => FirewallScreen(controller: controller),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // 4. System Tools & Hardware Specs
                        _DrawerMenuTile(
                          icon: Icons.memory_rounded,
                          title: 'System & Tools',
                          subtitle: 'MT7621DAT specs, memory & diagnostics',
                          accentColor: GlossyColors.lightBlue,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ToolsScreen(controller: controller),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Text(
                            'QUICK ACTIONS',
                            style: TextStyle(
                              color: GlossyColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),

                        // Stealth LED Mode Toggle Tile
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: GlossyColors.glassBorderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: (isStealth ? GlossyColors.primaryBlue : Colors.white)
                                      .withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isStealth ? Icons.nightlight_round : Icons.lightbulb_outline,
                                  color: isStealth ? GlossyColors.lightBlue : GlossyColors.amberWarm,
                                  size: 19,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Stealth LED Mode',
                                      style: TextStyle(
                                        color: GlossyColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Front lights toggle',
                                      style: TextStyle(
                                        color: GlossyColors.textSecondary,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: isStealth,
                                activeThumbColor: GlossyColors.lightBlue,
                                activeTrackColor: GlossyColors.lightBlue.withValues(alpha: 0.3),
                                onChanged: (_) => _toggleStealth(context),
                              ),
                            ],
                          ),
                        ),

                        // Flush Memory Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _flushMemory(context),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: GlossyColors.glassBorderLight),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: GlossyColors.emeraldMint.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.cleaning_services_rounded,
                                      color: GlossyColors.emeraldMint,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Flush Memory',
                                          style: TextStyle(
                                            color: GlossyColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Clear RAM drop_caches',
                                          style: TextStyle(
                                            color: GlossyColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: GlossyColors.textMuted,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Reboot Router Button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _confirmReboot(context),
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: GlossyColors.roseCoral.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: GlossyColors.roseCoral.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: GlossyColors.roseCoral.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.restart_alt_rounded,
                                      color: GlossyColors.roseCoral,
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Reboot Router',
                                          style: TextStyle(
                                            color: GlossyColors.roseCoral,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Safe 60s cold restart',
                                          style: TextStyle(
                                            color: GlossyColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: GlossyColors.roseCoral,
                                    size: 13,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drawer Bottom Info
                  const Divider(color: GlossyColors.glassBorderDark, height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: GlossyColors.emeraldMint),
                            SizedBox(width: 6),
                            Text(
                              'ArcherGuard C6 Engine',
                              style: TextStyle(
                                color: GlossyColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'v2.4.0',
                          style: TextStyle(
                            color: GlossyColors.textMuted.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final String? badge;
  final VoidCallback onTap;

  const _DrawerMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: accentColor.withValues(alpha: 0.15),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GlossyColors.glassBorderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badge!,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: GlossyColors.textMuted,
                size: 13,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
