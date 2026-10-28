import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../models/firewall_info.dart';
import '../controllers/router_controller.dart';
import 'firewall/sheets/add_port_forward_sheet.dart';
import 'firewall/sheets/add_traffic_rule_sheet.dart';
import 'firewall/sheets/block_mac_sheet.dart';
import 'firewall/sheets/dmz_config_sheet.dart';
import 'firewall/widgets/firewall_blocklist_card.dart';
import 'firewall/widgets/firewall_ddos_card.dart';
import 'firewall/widgets/firewall_engine_card.dart';
import 'firewall/widgets/firewall_maintenance_card.dart';
import 'firewall/widgets/firewall_offload_card.dart';
import 'firewall/widgets/firewall_port_forwards_card.dart';
import 'firewall/widgets/firewall_traffic_rules_card.dart';
import 'firewall/widgets/firewall_zones_card.dart';

class FirewallScreen extends StatefulWidget {
  final RouterController controller;

  const FirewallScreen({super.key, required this.controller});

  @override
  State<FirewallScreen> createState() => _FirewallScreenState();
}

class _FirewallScreenState extends State<FirewallScreen> {
  bool _isTogglingFlowOffload = false;
  bool _isTogglingHwFlowOffload = false;
  bool _isTogglingMssClamping = false;
  bool _isTogglingAntiSpoofing = false;
  bool _isTogglingIpv6 = false;
  bool _isTogglingSynFlood = false;
  bool _isTogglingDropInvalid = false;
  bool _isTogglingStealth = false;
  bool _isTogglingWanPing = false;
  bool _isTogglingWanLock = false;
  bool _isTogglingDnsRebind = false;
  bool _isTogglingGuestIso = false;
  bool _isTogglingDmz = false;
  bool _isReloadingFirewall = false;
  bool _isRestartingFirewall = false;
  bool _isFlushingConntrack = false;
  bool _isResettingFirewall = false;

  Future<void> _runToggle(void Function(bool) setLoader, Future<void> Function() action, String successMsg) async {
    setState(() => setLoader(true));
    try {
      await action();
      if (mounted) AppFeedback.showSuccess(context, successMsg);
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Action failed: $e');
    } finally {
      if (mounted) setState(() => setLoader(false));
    }
  }

  void _openAddPortForwardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddPortForwardSheet(
        controller: widget.controller,
        clients: widget.controller.status?.clients ?? [],
      ),
    );
  }

  void _openAddTrafficRuleSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddTrafficRuleSheet(controller: widget.controller),
    );
  }

  void _openBlockMacSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlockMacSheet(
        controller: widget.controller,
        clients: widget.controller.status?.clients ?? [],
      ),
    );
  }

  void _openDmzConfigSheet(String currentIp) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DmzConfigSheet(controller: widget.controller, currentIp: currentIp),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final status = widget.controller.status;
        final fw = status?.firewall ?? FirewallInfo.defaultConfig();
        final blockedClients = status?.clients.where((c) => c.blocked).toList() ?? [];

        return Scaffold(
          backgroundColor: GlossyColors.backgroundPrimary,
          appBar: AppBar(
            titleSpacing: 0,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Firewall & Traffic Guard',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: GlossyColors.textPrimary, letterSpacing: -0.3),
                ),
                Text(
                  'Firewall 4, nftables, NAT & Flow Offload',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: GlossyColors.textSecondary),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh Rules',
                icon: const Icon(Icons.refresh_rounded, color: GlossyColors.textPrimary),
                onPressed: () => widget.controller.refresh(),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => widget.controller.refresh(),
            color: GlossyColors.primaryBlue,
            backgroundColor: GlossyColors.backgroundSecondary,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FirewallEngineCard(
                    fw: fw,
                    isFlushingConntrack: _isFlushingConntrack,
                    onFlushConntrack: () => _runToggle((v) => _isFlushingConntrack = v, () => widget.controller.flushConntrack(), 'Conntrack state table flushed.'),
                  ),
                  const SizedBox(height: 16),
                  FirewallOffloadCard(
                    fw: fw,
                    isTogglingFlowOffload: _isTogglingFlowOffload,
                    isTogglingHwFlowOffload: _isTogglingHwFlowOffload,
                    isTogglingMssClamping: _isTogglingMssClamping,
                    isTogglingAntiSpoofing: _isTogglingAntiSpoofing,
                    isTogglingIpv6: _isTogglingIpv6,
                    onToggleFlowOffload: (val) => _runToggle((v) => _isTogglingFlowOffload = v, () => widget.controller.toggleHwOffload(val), val ? 'Software Flow Offload Enabled.' : 'Software Flow Offload Disabled.'),
                    onToggleHwFlowOffload: (val) => _runToggle((v) => _isTogglingHwFlowOffload = v, () => widget.controller.toggleHwFlowOffload(val), val ? 'Hardware Flow Offload (PPE) Enabled.' : 'Hardware Flow Offload Disabled.'),
                    onToggleMssClamping: (val) => _runToggle((v) => _isTogglingMssClamping = v, () => widget.controller.toggleMssClamping(val), val ? 'TCP MSS Clamping Enabled.' : 'TCP MSS Clamping Disabled.'),
                    onToggleAntiSpoofing: (val) => _runToggle((v) => _isTogglingAntiSpoofing = v, () => widget.controller.toggleAntiSpoofing(val), val ? 'Anti-Spoofing Filter Enabled.' : 'Anti-Spoofing Filter Disabled.'),
                    onToggleIpv6: (val) => _runToggle((v) => _isTogglingIpv6 = v, () => widget.controller.toggleIpv6Firewall(val), val ? 'IPv6 Firewall Active.' : 'IPv6 Firewall Disabled.'),
                  ),
                  const SizedBox(height: 16),
                  FirewallDdosCard(
                    fw: fw,
                    isTogglingSynFlood: _isTogglingSynFlood,
                    isTogglingDropInvalid: _isTogglingDropInvalid,
                    isTogglingStealth: _isTogglingStealth,
                    isTogglingWanPing: _isTogglingWanPing,
                    isTogglingWanLock: _isTogglingWanLock,
                    isTogglingDnsRebind: _isTogglingDnsRebind,
                    onToggleSynFlood: (val) => _runToggle((v) => _isTogglingSynFlood = v, () => widget.controller.toggleSynFlood(val), val ? 'SYN Flood Protection Enabled.' : 'SYN Flood Protection Disabled.'),
                    onToggleDropInvalid: (val) => _runToggle((v) => _isTogglingDropInvalid = v, () => widget.controller.toggleDropInvalid(val), val ? 'Invalid Packet Drops Enabled.' : 'Invalid Packet Drops Disabled.'),
                    onToggleStealth: (val) => _runToggle((v) => _isTogglingStealth = v, () => widget.controller.toggleStealthMode(val), val ? 'Stealth Port Probing Enabled.' : 'Stealth Probing Disabled.'),
                    onToggleWanPing: (val) => _runToggle((v) => _isTogglingWanPing = v, () => widget.controller.toggleWanPing(val), val ? 'WAN Ping Response Enabled.' : 'WAN Ping Response Disabled.'),
                    onToggleWanLock: (val) => _runToggle((v) => _isTogglingWanLock = v, () => widget.controller.toggleWanLockdown(val), val ? 'Remote WAN Management Locked.' : 'Remote WAN Lockdown Disabled.'),
                    onToggleDnsRebind: (val) => _runToggle((v) => _isTogglingDnsRebind = v, () => widget.controller.toggleDnsRebind(val), val ? 'DNS Rebind Mitigation Enabled.' : 'DNS Rebind Mitigation Disabled.'),
                  ),
                  const SizedBox(height: 16),
                  FirewallZonesCard(
                    fw: fw,
                    isTogglingGuestIso: _isTogglingGuestIso,
                    isTogglingDmz: _isTogglingDmz,
                    onToggleGuestIso: (val) => _runToggle((v) => _isTogglingGuestIso = v, () => widget.controller.toggleGuestIsolation(val), val ? 'Guest to LAN Isolation Enforced.' : 'Guest Isolation Disabled.'),
                    onToggleDmz: (val) => _runToggle((v) => _isTogglingDmz = v, () => widget.controller.toggleDmz(enabled: val), val ? 'DMZ Host Enabled.' : 'DMZ Host Disabled.'),
                    onOpenDmzConfig: () => _openDmzConfigSheet(fw.dmzIp),
                  ),
                  const SizedBox(height: 16),
                  FirewallPortForwardsCard(
                    fw: fw,
                    onOpenAddSheet: _openAddPortForwardSheet,
                    onToggleRule: (id, enabled) => widget.controller.togglePortForward(id, enabled),
                    onDeleteRule: (id) => widget.controller.deletePortForward(id),
                  ),
                  const SizedBox(height: 16),
                  FirewallTrafficRulesCard(
                    fw: fw,
                    onOpenAddSheet: _openAddTrafficRuleSheet,
                    onToggleRule: (id, enabled) => widget.controller.toggleTrafficRule(id, enabled),
                    onDeleteRule: (id) => widget.controller.deleteTrafficRule(id),
                  ),
                  const SizedBox(height: 16),
                  FirewallBlocklistCard(
                    blockedClients: blockedClients,
                    onOpenBlockSheet: _openBlockMacSheet,
                    onUnblockClient: (mac) => widget.controller.unblockClient(mac),
                  ),
                  const SizedBox(height: 16),
                  FirewallMaintenanceCard(
                    isReloading: _isReloadingFirewall,
                    isRestarting: _isRestartingFirewall,
                    isFlushing: _isFlushingConntrack,
                    isResetting: _isResettingFirewall,
                    onReload: () => _runToggle((v) => _isReloadingFirewall = v, () => widget.controller.reloadFirewall(), 'Firewall 4 nftables rules reloaded.'),
                    onRestart: () => _runToggle((v) => _isRestartingFirewall = v, () => widget.controller.restartFirewall(), 'Firewall subsystem restarted.'),
                    onFlush: () => _runToggle((v) => _isFlushingConntrack = v, () => widget.controller.flushConntrack(), 'Conntrack state table flushed.'),
                    onReset: () => _runToggle((v) => _isResettingFirewall = v, () => widget.controller.resetFirewallDefaults(), 'Firewall restored to factory defaults.'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
