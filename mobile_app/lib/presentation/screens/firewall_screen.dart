import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/glossy_input.dart';

class FirewallScreen extends StatefulWidget {
  final RouterController controller;

  const FirewallScreen({super.key, required this.controller});

  @override
  State<FirewallScreen> createState() => _FirewallScreenState();
}

class _FirewallScreenState extends State<FirewallScreen> {
  // Action Loading States
  bool _isReloadingFirewall = false;
  bool _isRestartingFirewall = false;
  bool _isFlushingConntrack = false;
  bool _isResettingFirewall = false;

  // Toggle Loading States
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

  void _showNotification(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? GlossyColors.roseCoral : GlossyColors.emeraldMint,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Subsystem Action Handlers ---

  Future<void> _reloadFirewall() async {
    setState(() => _isReloadingFirewall = true);
    try {
      await widget.controller.reloadFirewall();
      _showNotification('Firewall 4 rules reloaded successfully without session drops.');
    } catch (e) {
      _showNotification('Firewall reload failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isReloadingFirewall = false);
    }
  }

  Future<void> _restartFirewall() async {
    setState(() => _isRestartingFirewall = true);
    try {
      await widget.controller.restartFirewall();
      _showNotification('Firewall 4 subsystem restarted cleanly.');
    } catch (e) {
      _showNotification('Firewall restart failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isRestartingFirewall = false);
    }
  }

  Future<void> _flushConntrack() async {
    setState(() => _isFlushingConntrack = true);
    try {
      await widget.controller.flushConntrack();
      _showNotification('Conntrack state table purged successfully.');
    } catch (e) {
      _showNotification('Conntrack flush failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isFlushingConntrack = false);
    }
  }

  Future<void> _resetFirewallDefaults() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Firewall to Factory Defaults?', style: TextStyle(color: GlossyColors.textPrimary)),
        content: const Text(
          'This will restore factory nftables fw4 rules and clear all custom port forwards and custom traffic rules.',
          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GlossyColors.roseCoral),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset Rules', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isResettingFirewall = true);
    try {
      await widget.controller.resetFirewallDefaults();
      _showNotification('Firewall restored to default factory rules.');
    } catch (e) {
      _showNotification('Reset failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isResettingFirewall = false);
    }
  }

  // --- Toggle Handlers ---

  Future<void> _toggleFlowOffload(bool val) async {
    setState(() => _isTogglingFlowOffload = true);
    try {
      await widget.controller.toggleHwOffload(val);
      _showNotification(val ? 'Software Flow Offload Enabled.' : 'Software Flow Offload Disabled.');
    } catch (e) {
      _showNotification('Flow offload toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingFlowOffload = false);
    }
  }

  Future<void> _toggleHwFlowOffload(bool val) async {
    setState(() => _isTogglingHwFlowOffload = true);
    try {
      await widget.controller.toggleHwFlowOffload(val);
      _showNotification(val ? 'Hardware PPE Flow Offload Enabled (MediaTek MT7621).' : 'Hardware Flow Offload Disabled.');
    } catch (e) {
      _showNotification('Hardware flow offload toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingHwFlowOffload = false);
    }
  }

  Future<void> _toggleMssClamping(bool val) async {
    setState(() => _isTogglingMssClamping = true);
    try {
      await widget.controller.toggleMssClamping(val);
      _showNotification(val ? 'TCP MSS Clamping Enabled (MTU fragmentation prevented).' : 'MSS Clamping Disabled.');
    } catch (e) {
      _showNotification('MSS Clamping toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingMssClamping = false);
    }
  }

  Future<void> _toggleAntiSpoofing(bool val) async {
    setState(() => _isTogglingAntiSpoofing = true);
    try {
      await widget.controller.toggleAntiSpoofing(val);
      _showNotification(val ? 'Anti-Spoofing & Martian Filter Enabled (RFC 2827).' : 'Anti-Spoofing Disabled.');
    } catch (e) {
      _showNotification('Anti-Spoofing toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingAntiSpoofing = false);
    }
  }

  Future<void> _toggleIpv6(bool val) async {
    setState(() => _isTogglingIpv6 = true);
    try {
      await widget.controller.toggleIpv6Firewall(val);
      _showNotification(val ? 'IPv6 Inbound Stateful Firewall Enabled.' : 'IPv6 Inbound Firewall Disabled.');
    } catch (e) {
      _showNotification('IPv6 firewall toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingIpv6 = false);
    }
  }

  Future<void> _toggleSynFlood(bool val) async {
    setState(() => _isTogglingSynFlood = true);
    try {
      await widget.controller.toggleSynFlood(val);
      _showNotification(val ? 'TCP SYN Flood Defense Enabled.' : 'SYN Flood Defense Disabled.');
    } catch (e) {
      _showNotification('SYN flood toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingSynFlood = false);
    }
  }

  Future<void> _toggleDropInvalid(bool val) async {
    setState(() => _isTogglingDropInvalid = true);
    try {
      await widget.controller.toggleDropInvalid(val);
      _showNotification(val ? 'Invalid Packet Drops Enabled.' : 'Invalid Packet Drops Disabled.');
    } catch (e) {
      _showNotification('Invalid packet drop toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingDropInvalid = false);
    }
  }

  Future<void> _toggleStealth(bool val) async {
    setState(() => _isTogglingStealth = true);
    try {
      await widget.controller.toggleStealthMode(val);
      _showNotification(val ? 'Stealth Port Probing Enabled (drops scans without RST).' : 'Stealth Probing Disabled.');
    } catch (e) {
      _showNotification('Stealth toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingStealth = false);
    }
  }

  Future<void> _toggleWanPing(bool val) async {
    setState(() => _isTogglingWanPing = true);
    try {
      await widget.controller.toggleWanPing(val);
      _showNotification(val ? 'WAN Ping Response Enabled (router responds to ping).' : 'WAN Ping Response Disabled (Stealth mode active).');
    } catch (e) {
      _showNotification('WAN ping toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingWanPing = false);
    }
  }

  Future<void> _toggleWanLock(bool val) async {
    setState(() => _isTogglingWanLock = true);
    try {
      await widget.controller.toggleWanLockdown(val);
      _showNotification(val ? 'Remote WAN Management Locked (Ports 80/443/22 dropped).' : 'Remote WAN Lockdown Disabled.');
    } catch (e) {
      _showNotification('WAN lockdown toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingWanLock = false);
    }
  }

  Future<void> _toggleDnsRebind(bool val) async {
    setState(() => _isTogglingDnsRebind = true);
    try {
      await widget.controller.toggleDnsRebind(val);
      _showNotification(val ? 'DNS Rebind Mitigation Enabled.' : 'DNS Rebind Mitigation Disabled.');
    } catch (e) {
      _showNotification('DNS Rebind toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingDnsRebind = false);
    }
  }

  Future<void> _toggleGuestIso(bool val) async {
    setState(() => _isTogglingGuestIso = true);
    try {
      await widget.controller.toggleGuestIsolation(val);
      _showNotification(val ? 'Guest to LAN Isolation Enforced.' : 'Guest to LAN Isolation Disabled.');
    } catch (e) {
      _showNotification('Guest isolation toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingGuestIso = false);
    }
  }

  Future<void> _toggleDmz(bool val) async {
    setState(() => _isTogglingDmz = true);
    try {
      await widget.controller.toggleDmz(enabled: val);
      _showNotification(val ? 'DMZ Host Enabled.' : 'DMZ Host Disabled.');
    } catch (e) {
      _showNotification('DMZ toggle failed: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isTogglingDmz = false);
    }
  }

  // --- Modal Sheets ---

  void _openAddPortForwardSheet() {
    final nameCtrl = TextEditingController();
    final extPortCtrl = TextEditingController();
    final intIpCtrl = TextEditingController(text: '192.168.1.100');
    final intPortCtrl = TextEditingController();
    String selectedProto = 'tcp';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: GlossyColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlossyColors.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.alt_route_rounded, color: GlossyColors.primaryBlue, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add Port Forwarding Rule',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Forward inbound WAN traffic to a specific local device and port.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              GlossyInput(
                controller: nameCtrl,
                label: 'Rule Name',
                hint: 'e.g. Web Server / Minecraft',
                prefixIcon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 12),
              const Text(
                'Protocol',
                style: TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: ['tcp', 'udp', 'tcp+udp'].map((p) {
                  final isSelected = selectedProto == p;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(p.toUpperCase()),
                      selected: isSelected,
                      selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.25),
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      labelStyle: TextStyle(
                        color: isSelected ? GlossyColors.primaryBlue : GlossyColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      onSelected: (_) => setModalState(() => selectedProto = p),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GlossyInput(
                      controller: extPortCtrl,
                      label: 'External Port',
                      hint: 'e.g. 8080',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.input_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlossyInput(
                      controller: intPortCtrl,
                      label: 'Internal Port',
                      hint: 'e.g. 80',
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.output_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GlossyInput(
                controller: intIpCtrl,
                label: 'Internal Destination IP',
                hint: 'e.g. 192.168.1.101',
                keyboardType: TextInputType.datetime,
                prefixIcon: Icons.computer_rounded,
              ),
              const SizedBox(height: 8),
              // Connected device suggestions chips
              if (widget.controller.status?.clients.isNotEmpty == true) ...[
                const Text(
                  'Quick Select Client:',
                  style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.controller.status!.clients.take(4).map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.devices, size: 14, color: GlossyColors.lightBlue),
                          label: Text(c.hostname, style: const TextStyle(fontSize: 11, color: GlossyColors.textPrimary)),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          onPressed: () {
                            intIpCtrl.text = c.ip;
                            setModalState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              GlossyButton(
                label: 'Apply Port Forward Rule',
                icon: Icons.check_rounded,
                isLoading: isSaving,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty || extPortCtrl.text.trim().isEmpty || intIpCtrl.text.trim().isEmpty) {
                    _showNotification('Please fill in Rule Name, External Port and Destination IP.', isError: true);
                    return;
                  }
                  setModalState(() => isSaving = true);
                  try {
                    await widget.controller.addPortForward(
                      name: nameCtrl.text.trim(),
                      proto: selectedProto,
                      extPort: extPortCtrl.text.trim(),
                      intIp: intIpCtrl.text.trim(),
                      intPort: intPortCtrl.text.trim().isEmpty ? extPortCtrl.text.trim() : intPortCtrl.text.trim(),
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _showNotification('Port Forwarding rule "${nameCtrl.text}" added successfully.');
                  } catch (e) {
                    _showNotification('Failed to add rule: $e', isError: true);
                  } finally {
                    if (ctx.mounted) setModalState(() => isSaving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAddTrafficRuleSheet() {
    final nameCtrl = TextEditingController();
    String selectedProto = 'tcp';
    String selectedSrc = 'lan';
    String selectedDest = 'wan';
    String selectedTarget = 'DROP';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: GlossyColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlossyColors.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.filter_list_rounded, color: GlossyColors.emeraldMint, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Add Traffic Filter Rule',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Define packet filtering policies between router network zones.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              GlossyInput(
                controller: nameCtrl,
                label: 'Rule Name',
                hint: 'e.g. Block DoH Bypass / Drop Guest Admin',
                prefixIcon: Icons.label_outline_rounded,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Source Zone', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: selectedSrc,
                          isExpanded: true,
                          dropdownColor: GlossyColors.backgroundSecondary,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: GlossyColors.glassBorderLight)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'lan', child: Text('LAN (Private)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'wan', child: Text('WAN (Internet)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'guest', child: Text('Guest Zone', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) => setModalState(() => selectedSrc = val ?? 'lan'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Destination Zone', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: selectedDest,
                          isExpanded: true,
                          dropdownColor: GlossyColors.backgroundSecondary,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: GlossyColors.glassBorderLight)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'router', child: Text('Router', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'wan', child: Text('WAN (Internet)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'lan', child: Text('LAN (Private)', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) => setModalState(() => selectedDest = val ?? 'wan'),
                        ),
                      ],
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
                        const Text('Protocol', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: selectedProto,
                          isExpanded: true,
                          dropdownColor: GlossyColors.backgroundSecondary,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: GlossyColors.glassBorderLight)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'tcp', child: Text('TCP', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'udp', child: Text('UDP', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'icmp', child: Text('ICMP (Ping)', overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'all', child: Text('ALL Protocols', overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) => setModalState(() => selectedProto = val ?? 'tcp'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Action Target', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        DropdownButtonFormField<String>(
                          initialValue: selectedTarget,
                          isExpanded: true,
                          dropdownColor: GlossyColors.backgroundSecondary,
                          style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: GlossyColors.glassBorderLight)),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'ACCEPT', child: Text('ACCEPT', style: TextStyle(color: GlossyColors.emeraldMint, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'DROP', child: Text('DROP', style: TextStyle(color: GlossyColors.roseCoral, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                            DropdownMenuItem(value: 'REJECT', child: Text('REJECT', style: TextStyle(color: GlossyColors.amberWarm, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                          ],
                          onChanged: (val) => setModalState(() => selectedTarget = val ?? 'DROP'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GlossyButton(
                label: 'Save Traffic Filter Rule',
                icon: Icons.check_rounded,
                isLoading: isSaving,
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    _showNotification('Please enter a rule name.', isError: true);
                    return;
                  }
                  setModalState(() => isSaving = true);
                  try {
                    await widget.controller.addTrafficRule(
                      name: nameCtrl.text.trim(),
                      proto: selectedProto,
                      src: selectedSrc,
                      dest: selectedDest,
                      target: selectedTarget,
                    );
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _showNotification('Traffic filter "${nameCtrl.text}" applied successfully.');
                  } catch (e) {
                    _showNotification('Failed to add traffic rule: $e', isError: true);
                  } finally {
                    if (ctx.mounted) setModalState(() => isSaving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDmzConfigSheet(String currentIp) {
    final ipCtrl = TextEditingController(text: currentIp);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: GlossyColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlossyColors.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.shield_outlined, color: GlossyColors.amberWarm, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Configure DMZ Host IP',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'All unmapped incoming WAN packets will be forwarded directly to this local device IP.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              GlossyInput(
                controller: ipCtrl,
                label: 'DMZ Destination IP',
                hint: 'e.g. 192.168.1.150',
                keyboardType: TextInputType.datetime,
                prefixIcon: Icons.dns_rounded,
              ),
              const SizedBox(height: 20),
              GlossyButton(
                label: 'Save & Apply DMZ',
                icon: Icons.check_rounded,
                isLoading: isSaving,
                onPressed: () async {
                  final ip = ipCtrl.text.trim();
                  if (ip.isEmpty) {
                    _showNotification('Please enter a valid IP address.', isError: true);
                    return;
                  }
                  setModalState(() => isSaving = true);
                  try {
                    await widget.controller.toggleDmz(enabled: true, ip: ip);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _showNotification('DMZ Host updated to $ip.');
                  } catch (e) {
                    _showNotification('Failed to update DMZ: $e', isError: true);
                  } finally {
                    if (ctx.mounted) setModalState(() => isSaving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBlockMacSheet() {
    final macCtrl = TextEditingController();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: GlossyColors.backgroundSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlossyColors.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.block_rounded, color: GlossyColors.roseCoral, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Block Client at Firewall Forward Chain',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Drops all internet and forwarding packets for the target MAC at the Linux kernel firewall level.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 16),
              GlossyInput(
                controller: macCtrl,
                label: 'Client Hardware MAC Address',
                hint: 'XX:XX:XX:XX:XX:XX',
                prefixIcon: Icons.fingerprint_rounded,
              ),
              const SizedBox(height: 12),
              if (widget.controller.status?.clients.isNotEmpty == true) ...[
                const Text(
                  'Connected Devices:',
                  style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                ),
                const SizedBox(height: 4),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: widget.controller.status!.clients.where((c) => !c.blocked).take(5).map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          avatar: const Icon(Icons.device_unknown, size: 14, color: GlossyColors.roseCoral),
                          label: Text(c.hostname, style: const TextStyle(fontSize: 11, color: GlossyColors.textPrimary)),
                          backgroundColor: Colors.white.withValues(alpha: 0.06),
                          onPressed: () {
                            macCtrl.text = c.mac;
                            setModalState(() {});
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              GlossyButton(
                label: 'Enforce Firewall Drop Rule',
                icon: Icons.gavel_rounded,
                style: GlossyButtonStyle.danger,
                isLoading: isSaving,
                onPressed: () async {
                  final mac = macCtrl.text.trim().toLowerCase();
                  if (!RegExp(r'^([0-9a-fA-F]{2}[:-]){5}([0-9a-fA-F]{2})$').hasMatch(mac)) {
                    _showNotification('Please enter a valid MAC address format.', isError: true);
                    return;
                  }
                  setModalState(() => isSaving = true);
                  try {
                    await widget.controller.blockClient(mac);
                    if (ctx.mounted) Navigator.of(ctx).pop();
                    _showNotification('Client $mac blocked at kernel forward chain.');
                  } catch (e) {
                    _showNotification('Failed to block client: $e', isError: true);
                  } finally {
                    if (ctx.mounted) setModalState(() => isSaving = false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Main Build ---

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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GlossyColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Firewall 4, nftables, NAT & Flow Offload',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: GlossyColors.textSecondary,
                  ),
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
                  // 1. Firewall 4 Engine Telemetry & Conntrack Table Card
                  _buildEngineTelemetryCard(fw),

                  const SizedBox(height: 16),

                  // 2. Core NAT & Packet Acceleration Toggles Card
                  _buildAccelerationTogglesCard(fw),

                  const SizedBox(height: 16),

                  // 3. Cyber Attack & DDoS Defenses (Fully interactive toggles)
                  _buildDdosDefenseCard(fw),

                  const SizedBox(height: 16),

                  // 4. Inter-Zone Forwarding, Isolation & DMZ Card
                  _buildZoneIsolationCard(fw),

                  const SizedBox(height: 16),

                  // 5. NAT Port Forwarding Rules Section
                  _buildPortForwardingCard(fw),

                  const SizedBox(height: 16),

                  // 6. Custom Traffic Filter Rules Section
                  _buildTrafficRulesCard(fw),

                  const SizedBox(height: 16),

                  // 7. Firewall Blocklist (Kernel Level MAC Drop)
                  _buildFirewallBlocklistCard(blockedClients),

                  const SizedBox(height: 16),

                  // 8. Firewall Maintenance & Subsystem Controls
                  _buildMaintenanceCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Section Widgets ---

  Widget _buildEngineTelemetryCard(FirewallInfo fw) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department_rounded, color: GlossyColors.amberWarm, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Firewall 4 (nftables)',
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const GlossyBadge(
                label: 'Enforcing',
                dotColor: GlossyColors.emeraldMint,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Modern Linux nftables subsystem running on OpenWrt kernel. Manages stateful packet inspection, NAT translations, and per-zone routing rules.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),
          _buildMetricRow('Subsystem Engine', fw.engine),
          _buildMetricRow('State Table', fw.table),
          _buildMetricRow('NAT Masquerade', 'Active (eth0.2 / pppoe-wan)'),
          _buildMetricRow('Default WAN Policy', fw.wanLockdown ? 'DROP Inbound (Drop Unsolicited)' : 'ACCEPT (Open)'),
          _buildMetricRow('Default LAN Policy', 'ACCEPT Outbound (Full Internet)'),
          const SizedBox(height: 14),
          // Conntrack Table Gauge
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GlossyColors.glassBorderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.hub_outlined, color: GlossyColors.lightBlue, size: 15),
                        SizedBox(width: 5),
                        Text(
                          'Conntrack State Table',
                          style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${fw.conntrackCount} / ${fw.conntrackMax} (${fw.conntrackPercent.toStringAsFixed(1)}%)',
                        style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fw.conntrackPercent / 100.0,
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      fw.conntrackPercent > 80 ? GlossyColors.roseCoral : GlossyColors.lightBlue,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Active Defenses: ${fw.activeDefensesCount}/${fw.totalDefensesCount}',
                        style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 11, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _isFlushingConntrack ? null : _flushConntrack,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Row(
                          children: [
                            if (_isFlushingConntrack)
                              const SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2, color: GlossyColors.amberWarm))
                            else
                              const Icon(Icons.cleaning_services_rounded, color: GlossyColors.amberWarm, size: 13),
                            const SizedBox(width: 4),
                            const Text('Flush Table', style: TextStyle(color: GlossyColors.amberWarm, fontSize: 11, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccelerationTogglesCard(FirewallInfo fw) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
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
          _buildSwitchRow(
            title: 'Software Flow Offload',
            subtitle: 'Bypasses standard TCP/UDP stack for established flows',
            value: fw.flowOffload,
            isLoading: _isTogglingFlowOffload,
            activeColor: GlossyColors.lightBlue,
            onChanged: _toggleFlowOffload,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'Hardware Flow Offload (MT7621 PPE)',
            subtitle: 'Dedicated MediaTek silicon acceleration (940+ Mbps @ 0% CPU)',
            value: fw.flowOffloadHw,
            isLoading: _isTogglingHwFlowOffload,
            activeColor: GlossyColors.emeraldMint,
            onChanged: _toggleHwFlowOffload,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'TCP MSS Clamping (MTU Fix)',
            subtitle: 'Clamps TCP SYN MSS to WAN MTU to prevent packet stalling',
            value: fw.mssClamping,
            isLoading: _isTogglingMssClamping,
            activeColor: GlossyColors.primaryBlue,
            onChanged: _toggleMssClamping,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'Anti-Spoofing & Martian Filter (rp_filter)',
            subtitle: 'Discards packets with forged or impossible source IP (RFC 2827)',
            value: fw.antiSpoofing,
            isLoading: _isTogglingAntiSpoofing,
            activeColor: GlossyColors.amberWarm,
            onChanged: _toggleAntiSpoofing,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'IPv6 Stateful Firewall',
            subtitle: 'Blocks unsolicited incoming IPv6 WAN scans and probes',
            value: fw.ipv6Firewall,
            isLoading: _isTogglingIpv6,
            activeColor: GlossyColors.lightBlue,
            onChanged: _toggleIpv6,
          ),
        ],
      ),
    );
  }

  Widget _buildDdosDefenseCard(FirewallInfo fw) {
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
          _buildSwitchRow(
            title: 'TCP SYN Flood Protection',
            subtitle: 'Activates syncookies under memory exhaustion pressure',
            value: fw.synFlood,
            isLoading: _isTogglingSynFlood,
            activeColor: GlossyColors.emeraldMint,
            onChanged: _toggleSynFlood,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'Drop Invalid Packets',
            subtitle: 'Silently discards packets that fail conntrack validation',
            value: fw.dropInvalid,
            isLoading: _isTogglingDropInvalid,
            activeColor: GlossyColors.emeraldMint,
            onChanged: _toggleDropInvalid,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'Stealth Port Probing Shield',
            subtitle: 'Ignores unsolicited port scans without sending TCP RST response',
            value: fw.stealthMode,
            isLoading: _isTogglingStealth,
            activeColor: GlossyColors.lightBlue,
            onChanged: _toggleStealth,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'WAN Ping Response (ICMP Echo)',
            subtitle: fw.wanPing ? 'Router responds to WAN ping requests' : 'Stealth active: Router drops WAN ping requests silently',
            value: fw.wanPing,
            isLoading: _isTogglingWanPing,
            activeColor: GlossyColors.amberWarm,
            onChanged: _toggleWanPing,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'Remote WAN Lockdown',
            subtitle: 'Blocks external management access to ports 80/443/22',
            value: fw.wanLockdown,
            isLoading: _isTogglingWanLock,
            activeColor: GlossyColors.emeraldMint,
            onChanged: _toggleWanLock,
          ),
          const Divider(height: 16, color: GlossyColors.glassBorderLight),
          _buildSwitchRow(
            title: 'DNS Rebind Mitigation',
            subtitle: 'Blocks external domains from resolving to private 192.168.x.x',
            value: fw.dnsRebind,
            isLoading: _isTogglingDnsRebind,
            activeColor: GlossyColors.emeraldMint,
            onChanged: _toggleDnsRebind,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneIsolationCard(FirewallInfo fw) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
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
          _buildZoneCard('LAN Zone (Private)', 'br-lan', 'wan (ACCEPT)', 'lan (ACCEPT)', GlossyColors.emeraldMint),
          const SizedBox(height: 8),
          _buildZoneCard('WAN Zone (Public)', 'eth0.2', 'lan (REJECT)', 'wan (DROP)', GlossyColors.roseCoral),
          const SizedBox(height: 8),
          _buildZoneCard('Guest Zone (Isolated)', 'br-guest', 'wan (ACCEPT)', fw.guestIsolation ? 'lan (DROP)' : 'lan (ACCEPT)', GlossyColors.isolatedAccent),
          const SizedBox(height: 16),
          // Guest isolation toggle switch
          _buildSwitchRow(
            title: 'Guest Network Isolation',
            subtitle: 'Prevents guest clients from accessing internal LAN servers & NAS',
            value: fw.guestIsolation,
            isLoading: _isTogglingGuestIso,
            activeColor: GlossyColors.isolatedAccent,
            onChanged: _toggleGuestIso,
          ),
          const Divider(height: 20, color: GlossyColors.glassBorderLight),
          // DMZ Configuration
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
                onChanged: _isTogglingDmz ? null : _toggleDmz,
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
                  onPressed: () => _openDmzConfigSheet(fw.dmzIp),
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

  Widget _buildPortForwardingCard(FirewallInfo fw) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.alt_route_rounded, color: GlossyColors.primaryBlue, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Port Forwarding (NAT)',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${fw.activePortForwardsCount} Active',
                      dotColor: GlossyColors.primaryBlue,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Add Rule',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.primaryBlue, size: 22),
                onPressed: _openAddPortForwardSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Route specific external public ports to local servers, gaming consoles, or IP cameras.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (fw.portForwards.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No port forwarding rules configured.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...fw.portForwards.map((rule) => _buildPortForwardItem(rule)),
        ],
      ),
    );
  }

  Widget _buildPortForwardItem(PortForwardRule rule) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rule.proto.toUpperCase(),
              style: const TextStyle(color: GlossyColors.primaryBlue, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'WAN :${rule.extPort} ➔ ${rule.intIp}:${rule.intPort}',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: rule.enabled,
            activeThumbColor: GlossyColors.primaryBlue,
            activeTrackColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
            onChanged: (val) => widget.controller.togglePortForward(rule.id, val),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: GlossyColors.roseCoral, size: 18),
            onPressed: () => widget.controller.deletePortForward(rule.id),
          ),
        ],
      ),
    );
  }

  Widget _buildTrafficRulesCard(FirewallInfo fw) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.filter_list_rounded, color: GlossyColors.emeraldMint, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Traffic Filter Rules',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${fw.activeTrafficRulesCount} Active',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Add Filter',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.emeraldMint, size: 22),
                onPressed: _openAddTrafficRuleSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Granular packet inspection policies for accepting, dropping, or rejecting inter-zone traffic.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (fw.trafficRules.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No custom traffic rules configured.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...fw.trafficRules.map((rule) => _buildTrafficRuleItem(rule)),
        ],
      ),
    );
  }

  Widget _buildTrafficRuleItem(TrafficRule rule) {
    Color targetColor;
    switch (rule.target) {
      case 'ACCEPT':
        targetColor = GlossyColors.emeraldMint;
        break;
      case 'DROP':
        targetColor = GlossyColors.roseCoral;
        break;
      case 'REJECT':
      default:
        targetColor = GlossyColors.amberWarm;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: targetColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              rule.target,
              style: TextStyle(color: targetColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.name,
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${rule.src.toUpperCase()} ➔ ${rule.dest.toUpperCase()} • ${rule.proto.toUpperCase()}',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: rule.enabled,
            activeThumbColor: targetColor,
            activeTrackColor: targetColor.withValues(alpha: 0.3),
            onChanged: (val) => widget.controller.toggleTrafficRule(rule.id, val),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: GlossyColors.roseCoral, size: 18),
            onPressed: () => widget.controller.deleteTrafficRule(rule.id),
          ),
        ],
      ),
    );
  }

  Widget _buildFirewallBlocklistCard(List<ClientInfo> blockedClients) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.block_rounded, color: GlossyColors.roseCoral, size: 20),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        'Firewall Blocklist',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${blockedClients.length} Blocked',
                      dotColor: blockedClients.isNotEmpty ? GlossyColors.roseCoral : GlossyColors.emeraldMint,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Block MAC',
                icon: const Icon(Icons.add_circle_outline_rounded, color: GlossyColors.roseCoral, size: 22),
                onPressed: _openBlockMacSheet,
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Hardware devices blocked at the kernel forward chain. All internet packets from these MACs are dropped immediately.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (blockedClients.isEmpty)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: const Text('No devices currently blocked at the firewall.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
            )
          else
            ...blockedClients.map((client) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GlossyColors.glassBorderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.phonelink_erase_rounded, color: GlossyColors.roseCoral, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.hostname,
                              style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'MAC: ${client.mac.toUpperCase()} • IP: ${client.ip}',
                              style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => widget.controller.unblockClient(client.mac),
                        icon: const Icon(Icons.lock_open_rounded, size: 14, color: GlossyColors.emeraldMint),
                        label: const Text('Unblock', style: TextStyle(color: GlossyColors.emeraldMint, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _buildMaintenanceCard() {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firewall Maintenance & Control',
            style: TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Apply updated nftables rules, restart the packet engine, or restore factory defaults without rebooting the router OS.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Reload Rules',
                  icon: Icons.refresh_rounded,
                  style: GlossyButtonStyle.secondary,
                  isLoading: _isReloadingFirewall,
                  onPressed: _reloadFirewall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Restart Subsystem',
                  icon: Icons.restart_alt_rounded,
                  style: GlossyButtonStyle.primary,
                  isLoading: _isRestartingFirewall,
                  onPressed: _restartFirewall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Flush Conntrack',
                  icon: Icons.cleaning_services_rounded,
                  style: GlossyButtonStyle.secondary,
                  isLoading: _isFlushingConntrack,
                  onPressed: _flushConntrack,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Factory Defaults',
                  icon: Icons.restore_rounded,
                  style: GlossyButtonStyle.danger,
                  isLoading: _isResettingFirewall,
                  onPressed: _resetFirewallDefaults,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers ---

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required bool isLoading,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        isLoading
            ? SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: activeColor),
                  ),
                ),
              )
            : Switch.adaptive(
                value: value,
                activeThumbColor: activeColor,
                activeTrackColor: activeColor.withValues(alpha: 0.3),
                onChanged: onChanged,
              ),
      ],
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneCard(String name, String iface, String forward, String input, Color accent) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Interface: $iface • Input: $input',
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              forward,
              style: TextStyle(
                color: accent,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
