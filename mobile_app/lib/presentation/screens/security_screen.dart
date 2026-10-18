import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/glossy_input.dart';

class SecurityScreen extends StatefulWidget {
  final RouterController controller;

  const SecurityScreen({super.key, required this.controller});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isTogglingStealth = false;
  bool _isTogglingWireGuard = false;
  bool _isTogglingDoh = false;
  bool _isTogglingPmf = false;
  bool _isTogglingDnsRebind = false;
  bool _isTogglingWanLock = false;
  bool _isBlockingMac = false;
  bool _isAutoHardening = false;
  final TextEditingController _macBlockController = TextEditingController();

  @override
  void dispose() {
    _macBlockController.dispose();
    super.dispose();
  }

  int _calculateSecurityScore() {
    final status = widget.controller.status;
    if (status == null) return 80;

    int score = 20; // Base baseline
    if (status.network.wireguardEnabled) score += 20;
    if (status.network.dohEnabled) score += 20;
    if (status.wireless.pmfProtected) score += 15;
    if (status.network.dnsRebindProtection) score += 15;
    if (status.network.wanLockdown) score += 10;

    return score.clamp(0, 100);
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return GlossyColors.emeraldMint;
    if (score >= 70) return GlossyColors.lightBlue;
    if (score >= 50) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  String _getScoreRatingText(int score) {
    if (score >= 90) return 'Security Level: A+ Optimal';
    if (score >= 75) return 'Security Level: A Hardened';
    if (score >= 50) return 'Security Level: B Moderate';
    return 'Security Level: C Action Required';
  }

  Future<void> _togglePmf() async {
    setState(() => _isTogglingPmf = true);
    final current = widget.controller.status?.wireless.pmfProtected ?? true;
    try {
      await widget.controller.togglePmf(!current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current
                ? '802.11w PMF Shield Enabled: Deauth attacks & rogue frame injection blocked.'
                : '802.11w PMF Shield Disabled.'),
            backgroundColor: !current ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PMF toggle failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingPmf = false);
    }
  }

  Future<void> _toggleDnsRebind() async {
    setState(() => _isTogglingDnsRebind = true);
    final current = widget.controller.status?.network.dnsRebindProtection ?? true;
    try {
      await widget.controller.toggleDnsRebind(!current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current
                ? 'DNS Rebind Shield Enabled: RFC 1918 resolution blocked at dnsmasq.'
                : 'DNS Rebind Protection Disabled.'),
            backgroundColor: !current ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DNS Rebind toggle failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingDnsRebind = false);
    }
  }

  Future<void> _toggleWanLockdown() async {
    setState(() => _isTogglingWanLock = true);
    final current = widget.controller.status?.network.wanLockdown ?? true;
    try {
      await widget.controller.toggleWanLockdown(!current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current
                ? 'Remote WAN Management Locked: Port 80/443/22 closed to external WAN.'
                : 'Remote WAN Management Lockdown Disabled.'),
            backgroundColor: !current ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WAN lockdown toggle failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingWanLock = false);
    }
  }

  Future<void> _toggleStealth() async {
    setState(() => _isTogglingStealth = true);
    final current = widget.controller.status?.stealthLeds ?? false;
    try {
      await widget.controller.executeAction('led_stealth', {
        'value': !current ? 'on' : 'off',
        'enabled': !current,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(!current ? 'Stealth Mode ON: All LEDs off.' : 'Stealth Mode OFF: Normal LEDs active.'),
            backgroundColor: GlossyColors.lightBlue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stealth toggle failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingStealth = false);
    }
  }

  Future<void> _toggleWireguard(bool enable) async {
    setState(() => _isTogglingWireGuard = true);
    try {
      await widget.controller.toggleWireguard(enable);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable ? 'WireGuard VPN Tunnel Connected.' : 'WireGuard VPN Disconnected.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WireGuard action failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingWireGuard = false);
    }
  }

  Future<void> _toggleDoh(bool enable) async {
    setState(() => _isTogglingDoh = true);
    try {
      await widget.controller.toggleDoh(enable);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enable ? 'DNS-over-HTTPS (DoH) Enabled.' : 'DNS-over-HTTPS Disabled.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('DoH toggle failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isTogglingDoh = false);
    }
  }

  Future<void> _blockCustomMac() async {
    final mac = _macBlockController.text.trim().toLowerCase();
    final macRegex = RegExp(r'^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$');
    if (!macRegex.hasMatch(mac)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid MAC address. Format: AA:BB:CC:DD:EE:FF'),
          backgroundColor: GlossyColors.roseCoral,
        ),
      );
      return;
    }

    setState(() => _isBlockingMac = true);
    try {
      await widget.controller.blockClient(mac);
      _macBlockController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Client $mac blocked at firewall!'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to block client: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isBlockingMac = false);
    }
  }

  Future<void> _unblockClient(String mac) async {
    try {
      await widget.controller.unblockClient(mac);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Client $mac unblocked successfully.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unblock client: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    }
  }

  Future<void> _kickClient(String mac, String hostname) async {
    try {
      await widget.controller.kickClient(mac);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kicked $hostname ($mac) from Wi-Fi via 802.11 deauth.'),
            backgroundColor: GlossyColors.amberWarm,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to kick client: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    }
  }

  Future<void> _autoHardenAll() async {
    setState(() => _isAutoHardening = true);
    try {
      await widget.controller.autoHardenSecurity();
      if (mounted) {
        Navigator.of(context).pop(); // Dismiss bottom sheet if open
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-Hardening Complete! PMF 802.11w, DNS Rebind, and WAN Lock active.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Auto-hardening failed: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isAutoHardening = false);
    }
  }

  void _showSecurityAuditSheet() {
    final status = widget.controller.status;
    final score = _calculateSecurityScore();
    final isPmf = status?.wireless.pmfProtected ?? true;
    final isRebind = status?.network.dnsRebindProtection ?? true;
    final isWanLock = status?.network.wanLockdown ?? true;
    final isDoh = status?.network.dohEnabled ?? true;
    final isWg = status?.network.wireguardEnabled ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        decoration: BoxDecoration(
          color: GlossyColors.backgroundSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: Border.all(color: GlossyColors.glassBorderLight),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.security_rounded, color: _getScoreColor(score), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security Audit & Posture',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Current Armor Rating: $score / 100 • ${_getScoreRatingText(score)}',
                        style: TextStyle(color: _getScoreColor(score), fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildAuditItem('802.11w Protected Management Frames (PMF)', 'Deauth attack & spoof protection', isPmf),
            _buildAuditItem('DNS Rebinding Attack Protection', 'RFC 1918 private IP resolution defense', isRebind),
            _buildAuditItem('Remote WAN Management Lockdown', 'Port 80/443/22 drop on public WAN', isWanLock),
            _buildAuditItem('DNS-over-HTTPS (DoH) TLS 1.3', 'ISP snooping & DNS hijacking defense', isDoh),
            _buildAuditItem('WireGuard VPN Tunnel', 'Peer-to-peer encrypted communications', isWg),
            const SizedBox(height: 22),
            if (score < 100)
              SizedBox(
                width: double.infinity,
                child: GlossyButton(
                  label: 'One-Tap Auto-Harden Router Now',
                  icon: Icons.shield_rounded,
                  style: GlossyButtonStyle.primary,
                  isLoading: _isAutoHardening,
                  onPressed: _autoHardenAll,
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: GlossyColors.emeraldMint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GlossyColors.emeraldMint.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, color: GlossyColors.emeraldMint, size: 20),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'All Essential Router Protections Active!',
                        style: TextStyle(color: GlossyColors.emeraldMint, fontWeight: FontWeight.w700, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditItem(String title, String desc, bool passed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
            color: passed ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                Text(desc, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          GlossyBadge(
            label: passed ? 'Active' : 'Missing',
            dotColor: passed ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
          ),
        ],
      ),
    );
  }

  void _showConnectedDevicePicker() {
    final clients = widget.controller.status?.clients ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          return Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            decoration: BoxDecoration(
              color: GlossyColors.backgroundSecondary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: GlossyColors.glassBorderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Client to Kick or Block',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Direct hardware deauth & firewall drop rules',
                            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GlossyBadge(
                      label: '${clients.length} Online',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: clients.isEmpty
                      ? const Center(
                          child: Text(
                            'No active connected clients found.',
                            style: TextStyle(color: GlossyColors.textSecondary),
                          ),
                        )
                      : ListView.separated(
                          itemCount: clients.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final client = clients[index];
                            final isBlocked = client.blocked;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isBlocked
                                      ? GlossyColors.roseCoral.withValues(alpha: 0.4)
                                      : GlossyColors.glassBorderLight,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (isBlocked ? GlossyColors.roseCoral : GlossyColors.primaryBlue)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      client.connectionType.contains('LAN')
                                          ? Icons.settings_ethernet_rounded
                                          : Icons.wifi_rounded,
                                      color: isBlocked ? GlossyColors.roseCoral : GlossyColors.lightBlue,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          client.displayName,
                                          style: const TextStyle(
                                            color: GlossyColors.textPrimary,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${client.ip} • ${client.mac}',
                                          style: const TextStyle(
                                            color: GlossyColors.textSecondary,
                                            fontSize: 11,
                                            fontFamily: 'monospace',
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isBlocked) ...[
                                    IconButton(
                                      tooltip: 'Kick from Wi-Fi (802.11 deauth)',
                                      icon: const Icon(Icons.wifi_off_rounded, color: GlossyColors.amberWarm, size: 20),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _kickClient(client.mac, client.displayName);
                                      },
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GlossyColors.roseCoral,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        minimumSize: const Size(54, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        widget.controller.blockClient(client.mac);
                                      },
                                      child: const Text(
                                        'Block',
                                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ] else
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: GlossyColors.emeraldMint,
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        minimumSize: const Size(60, 30),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _unblockClient(client.mac);
                                      },
                                      child: const Text(
                                        'Unblock',
                                        style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;
    final isStealth = status?.stealthLeds ?? false;
    final network = status?.network;
    final wireless = status?.wireless;
    final isWgActive = network?.wireguardEnabled ?? false;
    final isDohActive = network?.dohEnabled ?? false;
    final isPmfActive = wireless?.pmfProtected ?? true;
    final isRebindActive = network?.dnsRebindProtection ?? true;
    final isWanLockActive = network?.wanLockdown ?? true;
    final clients = status?.clients ?? [];
    final blockedClients = clients.where((c) => c.blocked).toList();
    final score = _calculateSecurityScore();
    final scoreColor = _getScoreColor(score);

    return Scaffold(
      backgroundColor: GlossyColors.backgroundPrimary,
      appBar: AppBar(
        titleSpacing: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security Hub',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GlossyColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '802.11w PMF, VPN Shield, DNS Rebind & Access Control',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: GlossyColors.textSecondary,
              ),
            ),
          ],
        ),
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
              // 1. Dynamic Security Health Score & Audit Card
              GlossyCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Circular Score Indicator
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: scoreColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                            border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 2),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$score%',
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'SCORE',
                                  style: TextStyle(
                                    color: scoreColor.withValues(alpha: 0.8),
                                    fontSize: 8,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _getScoreRatingText(score),
                                      style: const TextStyle(
                                        color: GlossyColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  GlossyBadge(
                                    label: score >= 90 ? 'Hardened' : 'Checkup',
                                    dotColor: scoreColor,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'PMF ${isPmfActive ? "Active" : "Off"} • Rebind ${isRebindActive ? "Guarded" : "Off"} • DoH ${isDohActive ? "Encrypted" : "Off"}',
                                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: GlossyButton(
                        label: 'Security Audit & Posture Checklist',
                        icon: Icons.checklist_rounded,
                        style: GlossyButtonStyle.secondary,
                        onPressed: _showSecurityAuditSheet,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Client Access Control & Quick Block / Kick Picker Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined, color: GlossyColors.roseCoral, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Client Access & Blocklist',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlossyBadge(
                          label: '${blockedClients.length} Blocked',
                          dotColor: blockedClients.isEmpty ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enforces kernel-level DROP rules at forward chain and instant 802.11 deauthentication.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Quick Device Picker Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.devices_rounded, size: 18, color: Colors.white),
                        label: Text(
                          'Quick Action: Select Connected Device (${clients.length} Online)',
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlossyColors.primaryBlue.withValues(alpha: 0.35),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: GlossyColors.lightBlue, width: 0.8),
                          ),
                        ),
                        onPressed: _showConnectedDevicePicker,
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Manual MAC input
                    Row(
                      children: [
                        Expanded(
                          child: GlossyInput(
                            controller: _macBlockController,
                            label: 'Block Target MAC Address',
                            hint: 'ca:66:df:1b:b0:17',
                            prefixIcon: Icons.fingerprint_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: GlossyButton(
                            label: 'Block',
                            icon: Icons.block_rounded,
                            style: GlossyButtonStyle.danger,
                            isLoading: _isBlockingMac,
                            onPressed: _blockCustomMac,
                          ),
                        ),
                      ],
                    ),

                    if (blockedClients.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Text(
                        'Currently Blocked Devices:',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...blockedClients.map(
                        (c) => Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: GlossyColors.roseCoral.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GlossyColors.roseCoral.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.displayName.isNotEmpty ? c.displayName : 'Unknown Device',
                                      style: const TextStyle(
                                        color: GlossyColors.textPrimary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      c.mac,
                                      style: const TextStyle(
                                        color: GlossyColors.textSecondary,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GlossyColors.emeraldMint,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  minimumSize: const Size(60, 30),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () => _unblockClient(c.mac),
                                child: const Text(
                                  'Unblock',
                                  style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. 802.11w PMF (Protected Management Frames) Deauth Shield Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (isPmfActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.wifi_password_rounded,
                            color: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            '802.11w PMF Deauth Defense',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GlossyBadge(
                          label: isPmfActive ? 'Protected' : 'Vulnerable',
                          dotColor: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cryptographically signs Wi-Fi management frames. Thwarts deauth packet spoofing, Evil Twin rogue APs, and handshake capture attacks.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isPmfActive ? 'ieee80211w Required / Capable' : 'Management frames unencrypted',
                            style: TextStyle(
                              color: isPmfActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isPmfActive,
                          activeThumbColor: GlossyColors.emeraldMint,
                          activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                          onChanged: _isTogglingPmf ? null : (_) => _togglePmf(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 4. DNS Rebinding Attack Shield Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (isRebindActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.security_update_good_rounded,
                            color: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'DNS Rebinding Attack Guard',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GlossyBadge(
                          label: isRebindActive ? 'Guarded' : 'Unfiltered',
                          dotColor: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prevents malicious external websites from querying RFC 1918 private LAN IP addresses via upstream DNS responses.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isRebindActive ? 'RFC 1918 Filter Enforced (dnsmasq)' : 'Rebinding protection disabled',
                            style: TextStyle(
                              color: isRebindActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isRebindActive,
                          activeThumbColor: GlossyColors.emeraldMint,
                          activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                          onChanged: _isTogglingDnsRebind ? null : (_) => _toggleDnsRebind(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 5. Remote WAN Management Lockdown Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: (isWanLockActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.lock_person_rounded,
                            color: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Remote WAN Access Lockdown',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GlossyBadge(
                          label: isWanLockActive ? 'Locked' : 'Exposed',
                          dotColor: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Blocks public WAN connections to router LuCI web UI (80/443) and SSH console (22). Management strictly confined to private LAN.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            isWanLockActive ? 'WAN Port 80/443/22 Dropped' : 'WAN management ports open',
                            style: TextStyle(
                              color: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isWanLockActive,
                          activeThumbColor: GlossyColors.emeraldMint,
                          activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                          onChanged: _isTogglingWanLock ? null : (_) => _toggleWanLockdown(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 6. WireGuard VPN Tunnel Shield Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.vpn_lock_rounded, color: GlossyColors.lightBlue, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'WireGuard VPN Tunnel Shield',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlossyBadge(
                          label: isWgActive ? 'Connected' : 'Standby',
                          dotColor: isWgActive ? GlossyColors.emeraldMint : GlossyColors.textMuted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ChaCha20-Poly1305 peer-to-peer encrypted remote tunnel directly connecting over wg0.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tunnel Status',
                                style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                              ),
                              Text(
                                isWgActive ? 'Active (Endpoint: 10.14.0.1:51820)' : 'Tunnel Offline / Standby',
                                style: TextStyle(
                                  color: isWgActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isWgActive,
                          activeThumbColor: GlossyColors.emeraldMint,
                          activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                          onChanged: _isTogglingWireGuard ? null : (val) => _toggleWireguard(val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 7. DNS-over-HTTPS (DoH) Privacy Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lock_clock_rounded, color: GlossyColors.emeraldMint, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'DNS-over-HTTPS (DoH) Privacy',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GlossyBadge(
                          label: isDohActive ? 'Encrypted' : 'Standard DNS',
                          dotColor: isDohActive ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Prevents ISP and man-in-the-middle DNS snooping by routing all DNS queries through TLS 1.3.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DoH Upstream Provider',
                                style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                              ),
                              Text(
                                'Cloudflare (1.1.1.1) • Port 443 TLS',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Switch.adaptive(
                          value: isDohActive,
                          activeThumbColor: GlossyColors.emeraldMint,
                          activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                          onChanged: _isTogglingDoh ? null : (val) => _toggleDoh(val),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 8. Stealth LED Night Mode Card
              GlossyCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (isStealth ? GlossyColors.primaryBlue : Colors.white).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isStealth ? GlossyColors.lightBlue : GlossyColors.glassBorderLight),
                        ),
                      ),
                      child: Icon(
                        isStealth ? Icons.nightlight_round : Icons.lightbulb_outline,
                        color: isStealth ? GlossyColors.lightBlue : GlossyColors.amberWarm,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stealth LED Night Mode',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isStealth ? 'Front LEDs turned OFF for physical stealth' : 'Normal LED activity lights ON',
                            style: TextStyle(
                              color: isStealth ? GlossyColors.lightBlue : GlossyColors.textSecondary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isStealth,
                      activeThumbColor: GlossyColors.lightBlue,
                      activeTrackColor: GlossyColors.lightBlue.withValues(alpha: 0.3),
                      onChanged: _isTogglingStealth ? null : (_) => _toggleStealth(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 9. Automated Threat Defense Matrix Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_rounded, color: GlossyColors.emeraldMint, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Automated Threat Defenses',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildDefenseRow('802.11w PMF Frame Shield', 'Deauth attack & frame spoof filter', isPmfActive),
                    _buildDefenseRow('DNS Rebinding Shield', 'Blocks malicious LAN IP resolution', isRebindActive),
                    _buildDefenseRow('Remote WAN Access Lockdown', 'Drops incoming WAN port 80/443/22', isWanLockActive),
                    _buildDefenseRow('SYN Flood Defense (SYN Cookies)', 'Protects against half-open TCP exhaustion', true),
                    _buildDefenseRow('Bogon / Martian Packet Filter', 'Discards invalid WAN source IP packets', true),
                    _buildDefenseRow('Brute-Force SSH Rate Limiting', 'Temporary ban on repeated password failures', true),
                    _buildDefenseRow('Guest Network Isolation', 'Hardware VLAN isolation separating visitors', true),
                    _buildDefenseRow('WPS PIN Attack Lockout', 'Mitigates Pixie Dust and Reaver PIN attacks', true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefenseRow(String title, String desc, bool enabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
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
                Text(
                  desc,
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            enabled ? Icons.check_circle_rounded : Icons.cancel_outlined,
            color: enabled ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
            size: 18,
          ),
        ],
      ),
    );
  }
}
