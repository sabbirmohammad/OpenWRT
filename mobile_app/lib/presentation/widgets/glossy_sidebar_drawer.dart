import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../dialogs/update_dialog.dart';
import '../screens/firewall_screen.dart';
import '../screens/security_screen.dart';
import '../screens/settings_modal.dart';
import '../screens/tools_screen.dart';
import 'drawer/drawer_header_section.dart';
import 'drawer/drawer_menu_tile.dart';
import 'drawer/drawer_quick_actions.dart';

export 'drawer/drawer_header_section.dart';
export 'drawer/drawer_menu_tile.dart';
export 'drawer/drawer_quick_actions.dart';

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

  @override
  Widget build(BuildContext context) {
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
                  DrawerHeaderSection(controller: controller),
                  const Divider(color: GlossyColors.glassBorderDark, height: 1),
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
                        DrawerMenuTile(
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
                        DrawerMenuTile(
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
                        DrawerMenuTile(
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
                        DrawerMenuTile(
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
                        const SizedBox(height: 8),
                        DrawerMenuTile(
                          icon: Icons.system_update_rounded,
                          title: 'Check for Updates',
                          subtitle: controller.availableUpdate?.hasUpdate == true
                              ? 'New update ${controller.availableUpdate?.tagName} ready'
                              : 'Auto-update via GitHub Releases',
                          accentColor: controller.availableUpdate?.hasUpdate == true
                              ? GlossyColors.emeraldMint
                              : GlossyColors.skyBlue,
                          badge: controller.availableUpdate?.hasUpdate == true
                              ? 'Update!'
                              : (controller.isCheckingUpdate ? 'Checking' : null),
                          onTap: () async {
                            HapticFeedback.selectionClick();
                            Navigator.of(context).pop();
                            final info = await controller.checkForUpdate(force: true);
                            if (!context.mounted) return;
                            if (info != null && info.hasUpdate) {
                              UpdateDialog.show(
                                context,
                                updateInfo: info,
                                updateService: controller.updateService,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: GlossyColors.backgroundElevated,
                                  content: Text(
                                    info != null
                                        ? 'আপনার অ্যাপ্লিকেশনটি আপ-টু-ডেট আছে (v${info.currentVersion})'
                                        : 'আপডেট চেক করতে সমস্যা হয়েছে। ইন্টারনেট কানেকশন চেক করুন।',
                                    style: const TextStyle(color: GlossyColors.textPrimary),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        DrawerQuickActions(controller: controller),
                      ],
                    ),
                  ),
                  const Divider(color: GlossyColors.glassBorderDark, height: 1),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
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
                            color: GlossyColors.textMuted,
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
