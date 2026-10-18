import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/glossy_input.dart';

class WirelessScreen extends StatefulWidget {
  final RouterController controller;

  const WirelessScreen({super.key, required this.controller});

  @override
  State<WirelessScreen> createState() => _WirelessScreenState();
}

class _WirelessScreenState extends State<WirelessScreen> {
  double? _customTx2g;
  double? _customTx5g;
  bool _isUpdatingTx = false;
  String? _togglingSsidId;

  Future<void> _toggleMasterWifi() async {
    try {
      await widget.controller.executeAction('wifi_toggle');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Master Wi-Fi power toggled successfully.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle Wi-Fi: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    }
  }

  Future<void> _confirmAndToggleSsid(SsidInfo ssid, bool targetState) async {
    // Accidental Touch Protection:
    // When turning off an active network, require explicit confirmation
    // to prevent accidental disconnection of devices
    if (!targetState && ssid.enabled) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: GlossyColors.backgroundElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: GlossyColors.glassBorderLight),
          ),
          title: Row(
            children: const [
              Icon(Icons.power_settings_new_rounded, color: GlossyColors.roseCoral, size: 22),
              SizedBox(width: 8),
              Text(
                'Deactivate Network?',
                style: TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to turn off "${ssid.ssid}"?\n\n'
            '${ssid.connectedClients > 0 ? "${ssid.connectedClients} connected device(s) will be disconnected immediately." : "Devices will not be able to connect to this SSID until re-enabled."}',
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Cancel', style: TextStyle(color: GlossyColors.textMuted)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GlossyColors.roseCoral,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Turn Off', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    await _toggleSsid(ssid, targetState);
  }

  Future<void> _toggleSsid(SsidInfo ssid, [bool? explicitTarget]) async {
    setState(() => _togglingSsidId = ssid.id);
    final targetState = explicitTarget ?? !ssid.enabled;
    try {
      await widget.controller.toggleSsid(ssid.id, targetState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${ssid.ssid} is now ${targetState ? "Active" : "Inactive"}.'),
            backgroundColor: targetState ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle ${ssid.ssid}: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _togglingSsidId = null);
      }
    }
  }

  Future<void> _applyTxPower(String radioId, int powerDbm) async {
    setState(() => _isUpdatingTx = true);
    try {
      await widget.controller.executeAction('set_txpower', {
        'radio': radioId,
        'txpower': powerDbm,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('TX Power for $radioId updated to $powerDbm dBm.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set TX power: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdatingTx = false);
      }
    }
  }

  void _showEditSsidModal(BuildContext context, SsidInfo ssid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSsidSheet(
        controller: widget.controller,
        ssid: ssid,
      ),
    );
  }

  void _showAddSsidModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddSsidSheet(
        controller: widget.controller,
      ),
    );
  }

  void _showShareSsidModal(BuildContext context, SsidInfo ssid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSsidSheet(ssid: ssid),
    );
  }

  void _showConnectedDevicesModal(BuildContext context, SsidInfo ssid, List<ClientInfo> clients) {
    final matchedClients = clients.where(
      (c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase(),
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConnectedDevicesSheet(
        ssid: ssid,
        clients: matchedClients,
      ),
    );
  }

  void _showSsidDetailModal(
    BuildContext context,
    SsidInfo ssid,
    List<ClientInfo> allClients,
    List<SsidInfo> allSsids,
  ) {
    final matchedClients = allClients.where(
      (c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase(),
    ).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SsidDetailSheet(
        ssid: ssid,
        clients: matchedClients,
        allSsids: allSsids,
        onEdit: () {
          Navigator.pop(context);
          _showEditSsidModal(context, ssid);
        },
        onShare: () {
          Navigator.pop(context);
          _showShareSsidModal(context, ssid);
        },
      ),
    );
  }

  void _showProtocolsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ProtocolsDetailSheet(),
    );
  }

  Future<void> _confirmDeleteSsid(SsidInfo ssid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: GlossyColors.roseCoral, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete SSID?',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently remove virtual SSID "${ssid.ssid}" (${ssid.id})? Connected clients will be disconnected.',
          style: const TextStyle(
            color: GlossyColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.roseCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await widget.controller.deleteSsid(ssid.id);
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('SSID "${ssid.ssid}" was deleted.'),
              backgroundColor: GlossyColors.emeraldMint,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('Failed to delete SSID: $e'),
              backgroundColor: GlossyColors.roseCoral,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;
    final wireless = status?.wireless;
    final radio2g = wireless?.radio2g;
    final radio5g = wireless?.radio5g;
    final ssids = wireless?.ssids ?? [];
    final allClients = status?.clients ?? [];

    final isWifiActive = (radio2g?.enabled == true) || (radio5g?.enabled == true);
    final totalClients = wireless?.totalConnectedClients ?? 0;
    final totalSsids = wireless?.totalSsidCount ?? ssids.length;
    final activeSsids = wireless?.activeSsidCount ?? ssids.where((s) => s.enabled).length;
    final inactiveSsids = wireless?.inactiveSsidCount ?? ssids.where((s) => !s.enabled).length;

    final currentTx2g = _customTx2g ?? (radio2g?.txpowerDbm.toDouble() ?? 20.0);
    final currentTx5g = _customTx5g ?? (radio5g?.txpowerDbm.toDouble() ?? 23.0);

    return Scaffold(
      backgroundColor: GlossyColors.backgroundPrimary,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wireless Networks',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GlossyColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Dual-Band Wi-Fi & SSID Management',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: GlossyColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlossyBadge(
              label: '$totalClients Clients',
              dotColor: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
            ),
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
              // 1. Master Wi-Fi Power Control Card
              GlossyCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: (isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: (isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral)
                              .withValues(alpha: 0.35),
                        ),
                      ),
                      child: Icon(
                        isWifiActive ? Icons.wifi : Icons.wifi_off,
                        color: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Master Wi-Fi Power',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isWifiActive ? 'Radios Broadcasting Normally' : 'All Wi-Fi Radios Disabled',
                            style: TextStyle(
                              color: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: isWifiActive,
                      activeThumbColor: GlossyColors.emeraldMint,
                      activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                      onChanged: (_) => _toggleMasterWifi(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. SSID Management & Broadcast Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.3)),
                        ),
                        child: const Icon(Icons.wifi_tethering_rounded, color: GlossyColors.lightBlue, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'SSID Networks',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlossyBadge(
                                label: '$totalSsids SSIDs',
                                dotColor: GlossyColors.primaryBlue,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$activeSsids Active • $inactiveSsids Inactive',
                            style: const TextStyle(
                              color: GlossyColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  GlossyButton(
                    label: 'Add SSID',
                    icon: Icons.add,
                    height: 34,
                    onPressed: () => _showAddSsidModal(context),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // 3. SSID Cards List
              if (ssids.isEmpty)
                GlossyCard(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: const [
                          Icon(Icons.wifi_off_rounded, color: GlossyColors.textMuted, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'No SSIDs configured or detected.',
                            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (wireless?.topTrafficSsid != null && (wireless?.topTrafficSsid?.totalBytes ?? 0) > 0) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: GlossyColors.primaryBlue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.leaderboard_rounded, color: GlossyColors.lightBlue, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Highest Usage: ${wireless!.topTrafficSsid!.ssid} (${wireless.topTrafficSsid!.formattedTotalData})',
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          '${wireless.topTrafficSsid!.formattedDownload} ↓',
                          style: const TextStyle(
                            color: GlossyColors.lightBlue,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                ...ssids.map((ssid) => _buildSsidCard(context, ssid, allClients, ssids, wireless?.topTrafficSsid)),
              ],

              const SizedBox(height: 20),

              // 4. Radio Hardware Section Header
              const Text(
                'Hardware Radios & RF Tuning',
                style: TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // 5.0 GHz High-Speed Radio Card
              if (radio5g != null)
                _buildRadioCard(
                  band: '5.0 GHz (AC Wave 2)',
                  chipset: 'MediaTek MT7613BEN',
                  ssid: radio5g.ssid,
                  channel: radio5g.channel,
                  channelWidth: '80 MHz',
                  clients: radio5g.connectedClients,
                  enabled: radio5g.enabled,
                  txPower: currentTx5g,
                  onTxPowerChanged: (val) => setState(() => _customTx5g = val),
                  onSaveTxPower: () => _applyTxPower('radio0', currentTx5g.round()),
                ),

              const SizedBox(height: 16),

              // 2.4 GHz Long-Range Radio Card
              if (radio2g != null)
                _buildRadioCard(
                  band: '2.4 GHz (Long Range)',
                  chipset: 'MediaTek MT7603E',
                  ssid: radio2g.ssid,
                  channel: radio2g.channel,
                  channelWidth: '20/40 MHz',
                  clients: radio2g.connectedClients,
                  enabled: radio2g.enabled,
                  txPower: currentTx2g,
                  onTxPowerChanged: (val) => setState(() => _customTx2g = val),
                  onSaveTxPower: () => _applyTxPower('radio1', currentTx2g.round()),
                ),

              const SizedBox(height: 20),

              // 5. Protocols & Roaming
              _buildProtocolsCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSsidCard(
    BuildContext context,
    SsidInfo ssid,
    List<ClientInfo> allClients,
    List<SsidInfo> allSsids,
    SsidInfo? topTrafficSsid,
  ) {
    final isToggling = _togglingSsidId == ssid.id;
    final isGuestOrIsolated = ssid.isGuest || ssid.isIsolated;
    final is5g = ssid.band.contains('5');
    final isTopTraffic = topTrafficSsid != null && ssid.id == topTrafficSsid.id && ssid.totalBytes > 0;
    final qualityPercent = WirelessInfo.getSsidSignalQualityPercent(ssid, allClients);
    final qualityText = WirelessInfo.getSsidSignalQualityText(qualityPercent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlossyCard(
        onTap: () => _showSsidDetailModal(context, ssid, allClients, allSsids),
        borderColor: isGuestOrIsolated
            ? GlossyColors.isolatedAccent.withValues(alpha: 0.4)
            : (isTopTraffic ? GlossyColors.amberWarm.withValues(alpha: 0.35) : null),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Badges & Switch
              Row(
                children: [
                  // Band Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      ssid.band,
                      style: TextStyle(
                        color: is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Top Traffic Badge if applicable
                  if (isTopTraffic) ...[
                    GlossyBadge(
                      label: 'Top Traffic',
                      dotColor: GlossyColors.amberWarm,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Guest / Isolated Badge
                  if (isGuestOrIsolated) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GlossyColors.isolatedAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GlossyColors.isolatedAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.shield_outlined, color: GlossyColors.isolatedLight, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Isolated Guest',
                            style: TextStyle(
                              color: GlossyColors.isolatedLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Hidden Beacon Badge
                  if (ssid.isHidden) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: GlossyColors.glassBorderLight),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.visibility_off_outlined, color: GlossyColors.textMuted, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Hidden',
                            style: TextStyle(
                              color: GlossyColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Spacer(),

                  // Active / Inactive Badge
                  GlossyBadge(
                    label: ssid.enabled ? 'Active' : 'Inactive',
                    dotColor: ssid.enabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
                  ),
                  const SizedBox(width: 8),

                  // Accidental-Touch-Protected Switch
                  if (isToggling)
                    const SizedBox(
                      width: 36,
                      height: 24,
                      child: Center(
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: GlossyColors.primaryBlue,
                          ),
                        ),
                      ),
                    )
                  else
                    Switch.adaptive(
                      value: ssid.enabled,
                      activeThumbColor: GlossyColors.emeraldMint,
                      activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                      onChanged: (val) => _confirmAndToggleSsid(ssid, val),
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // SSID Name & Details
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white10).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white24).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      ssid.enabled ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                      color: ssid.enabled ? GlossyColors.lightBlue : GlossyColors.textMuted,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ssid.ssid,
                          style: const TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Interface: ${ssid.id} • ${ssid.ifname.isNotEmpty ? ssid.ifname : ssid.radio}',
                          style: const TextStyle(
                            color: GlossyColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: GlossyColors.textMuted, size: 20),
                ],
              ),

              const SizedBox(height: 10),

              // Telemetry & Range Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GlossyColors.glassBorderLight),
                ),
                child: Row(
                  children: [
                    // Traffic Rx/Tx
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_downward_rounded, color: GlossyColors.lightBlue, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            ssid.formattedDownload,
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_upward_rounded, color: GlossyColors.skyBlue, size: 13),
                          const SizedBox(width: 2),
                          Text(
                            ssid.formattedUpload,
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Quality & Range
                    Row(
                      children: [
                        Icon(
                          Icons.wifi_tethering_rounded,
                          size: 13,
                          color: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$qualityPercent% ($qualityText) • ${ssid.estimatedIndoorRange.split(' ')[0]}',
                          style: TextStyle(
                            color: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Specs Row
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GlossyColors.glassBorderLight),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Security', ssid.encryption),
                    ),
                    Expanded(
                      child: _buildInfoItem('Channel', 'Ch ${ssid.channel}'),
                    ),
                    Expanded(
                      child: _buildInfoItem('Clients', '${ssid.connectedClients} Connected'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
              const Divider(color: GlossyColors.glassDivider, height: 1),
              const SizedBox(height: 8),

              // Action Buttons Toolbar
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Edit & Security
                    GlossyButton(
                      label: 'Edit',
                      icon: Icons.edit_outlined,
                      style: GlossyButtonStyle.secondary,
                      height: 34,
                      onPressed: () => _showEditSsidModal(context, ssid),
                    ),
                    const SizedBox(width: 8),

                    // Share / Credentials
                    GlossyButton(
                      label: 'Share',
                      icon: Icons.qr_code_2_rounded,
                      style: GlossyButtonStyle.secondary,
                      height: 34,
                      onPressed: () => _showShareSsidModal(context, ssid),
                    ),
                    const SizedBox(width: 8),

                    // Connected Devices
                    GlossyButton(
                      label: '${ssid.connectedClients} Devices',
                      icon: Icons.devices_rounded,
                      style: GlossyButtonStyle.secondary,
                      height: 34,
                      onPressed: () => _showConnectedDevicesModal(context, ssid, allClients),
                    ),
                    const SizedBox(width: 8),

                    // Delete SSID (Only for non-primary virtual SSIDs)
                    if (!ssid.isPrimary)
                      GlossyButton(
                        label: 'Delete',
                        icon: Icons.delete_outline_rounded,
                        style: GlossyButtonStyle.danger,
                        height: 34,
                        onPressed: () => _confirmDeleteSsid(ssid),
                      ),
                  ],
                ),
              ),

              // Hint at bottom
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Tap card for usage analysis, range & devices',
                      style: TextStyle(
                        color: GlossyColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: GlossyColors.textMuted, size: 8),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }

  Widget _buildRadioCard({
    required String band,
    required String chipset,
    required String ssid,
    required int channel,
    required String channelWidth,
    required int clients,
    required bool enabled,
    required double txPower,
    required ValueChanged<double> onTxPowerChanged,
    required VoidCallback onSaveTxPower,
  }) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    band,
                    style: const TextStyle(
                      color: GlossyColors.lightBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    chipset,
                    style: const TextStyle(
                      color: GlossyColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              GlossyBadge(
                label: enabled ? '$clients Connected' : 'Radio Off',
                dotColor: enabled ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildInfoItem('SSID', ssid)),
              Expanded(child: _buildInfoItem('Channel', 'Ch $channel ($channelWidth)')),
              Expanded(child: _buildInfoItem('Tx Power', '${txPower.round()} dBm')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: GlossyColors.glassDivider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transmit Power (TX Power)',
                style: TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${txPower.round()} dBm (~${(txPower > 20 ? 100 : 70)}mW)',
                style: const TextStyle(
                  color: GlossyColors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GlossyColors.lightBlue,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: GlossyColors.primaryBlue,
              overlayColor: GlossyColors.primaryBlue.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: txPower.clamp(10.0, 24.0),
              min: 10.0,
              max: 24.0,
              divisions: 14,
              onChanged: onTxPowerChanged,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GlossyButton(
              label: 'Apply ${txPower.round()} dBm',
              icon: Icons.check_circle_outline,
              style: GlossyButtonStyle.secondary,
              height: 36,
              isLoading: _isUpdatingTx,
              onPressed: onSaveTxPower,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProtocolsCard() {
    return SizedBox(
      width: double.infinity,
      child: GlossyCard(
        onTap: () => _showProtocolsModal(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: GlossyColors.primaryBlue.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.cell_tower_rounded, color: GlossyColors.lightBlue, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Supported Wi-Fi Protocols & Roaming',
                    style: TextStyle(
                      color: GlossyColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: GlossyColors.textMuted, size: 20),
              ],
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 8) / 2;
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FeaturePill(
                      title: '802.11ac Wave 2',
                      subtitle: 'MU-MIMO 2x2 (867 Mbps)',
                      width: itemWidth,
                      icon: Icons.speed_rounded,
                    ),
                    _FeaturePill(
                      title: '802.11r FT',
                      subtitle: 'Fast Roaming (<50ms)',
                      width: itemWidth,
                      icon: Icons.sync_rounded,
                    ),
                    _FeaturePill(
                      title: '802.11k/v',
                      subtitle: 'Smart Band Steering',
                      width: itemWidth,
                      icon: Icons.explore_rounded,
                    ),
                    _FeaturePill(
                      title: '802.11w PMF',
                      subtitle: 'Deauth Frame Shield',
                      width: itemWidth,
                      icon: Icons.security_rounded,
                    ),
                    _FeaturePill(
                      title: 'WPA2/WPA3',
                      subtitle: 'Dragonfly SAE Security',
                      width: itemWidth,
                      icon: Icons.lock_outline_rounded,
                    ),
                    _FeaturePill(
                      title: 'WMM QoS',
                      subtitle: 'Voice & Video Priority',
                      width: itemWidth,
                      icon: Icons.multitrack_audio_rounded,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                children: const [
                  Icon(Icons.touch_app_rounded, color: GlossyColors.lightBlue, size: 14),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Tap card to view chipset specs & roaming standards',
                      style: TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(
                    'Specs →',
                    style: TextStyle(
                      color: GlossyColors.lightBlue,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GlossyColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: GlossyColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Modal Sheets (Edit SSID, Add SSID, Share, Connected Devices)
// -----------------------------------------------------------------------------

class _EditSsidSheet extends StatefulWidget {
  final RouterController controller;
  final SsidInfo ssid;

  const _EditSsidSheet({required this.controller, required this.ssid});

  @override
  State<_EditSsidSheet> createState() => _EditSsidSheetState();
}

class _EditSsidSheetState extends State<_EditSsidSheet> {
  late final TextEditingController _ssidController;
  late final TextEditingController _keyController;
  late bool _isHidden;
  late bool _isIsolated;
  bool _obscureKey = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController(text: widget.ssid.ssid);
    _keyController = TextEditingController(text: widget.ssid.password ?? '');
    _isHidden = widget.ssid.isHidden;
    _isIsolated = widget.ssid.isIsolated;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newName = _ssidController.text.trim();
    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SSID name cannot be empty.'), backgroundColor: GlossyColors.roseCoral),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.controller.updateSsidConfig(
        ifaceId: widget.ssid.id,
        newSsid: newName,
        key: _keyController.text.isNotEmpty ? _keyController.text : null,
        hidden: _isHidden,
        isolate: _isIsolated,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SSID "${widget.ssid.id}" settings saved.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update SSID: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit SSID Configuration',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Interface: ${widget.ssid.id} (${widget.ssid.band})',
                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                GlossyBadge(
                  label: widget.ssid.band,
                  dotColor: GlossyColors.primaryBlue,
                  showDot: false,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // SSID Name
            GlossyInput(
              controller: _ssidController,
              label: 'SSID Name (Broadcast Name)',
              hint: 'e.g. MyWiFi_5G',
              prefixIcon: Icons.wifi,
            ),
            const SizedBox(height: 16),

            // WPA Password Key
            GlossyInput(
              controller: _keyController,
              label: 'WPA2/WPA3 Password',
              hint: 'Leave blank to retain current key',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureKey,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: GlossyColors.textSecondary,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
            const SizedBox(height: 18),

            // Toggle Switches Row
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Hide SSID Broadcast',
                            style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Do not broadcast beacon (Stealth)',
                            style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isHidden,
                        activeThumbColor: GlossyColors.primaryBlue,
                        onChanged: (val) => setState(() => _isHidden = val),
                      ),
                    ],
                  ),
                  const Divider(color: GlossyColors.glassDivider, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Client Isolation',
                            style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            'Prevent devices on this SSID from talking',
                            style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isIsolated,
                        activeThumbColor: GlossyColors.isolatedAccent,
                        onChanged: (val) => setState(() => _isIsolated = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Save Button
            GlossyButton(
              label: 'Save Configuration',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddSsidSheet extends StatefulWidget {
  final RouterController controller;

  const _AddSsidSheet({required this.controller});

  @override
  State<_AddSsidSheet> createState() => _AddSsidSheetState();
}

class _AddSsidSheetState extends State<_AddSsidSheet> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _selectedRadio = 'radio0'; // radio0 = 2.4G, radio1 = 5G
  final String _encryption = 'psk2';
  bool _isIsolated = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _ssidController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _createSsid() async {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an SSID name.'), backgroundColor: GlossyColors.roseCoral),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.controller.addSsid(
        ssid: ssid,
        radio: _selectedRadio,
        key: _keyController.text.isNotEmpty ? _keyController.text : null,
        encryption: _encryption,
        isolate: _isIsolated,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Virtual SSID "$ssid" created on $_selectedRadio.'),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add SSID: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const Text(
              'Add New Virtual SSID',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a secondary broadcast network on 2.4 GHz or 5.0 GHz radio.',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),

            // SSID Name
            GlossyInput(
              controller: _ssidController,
              label: 'SSID Name',
              hint: 'e.g. Archer_IoT or Guest_Lounge',
              prefixIcon: Icons.wifi,
            ),
            const SizedBox(height: 14),

            // Radio Band Selector
            const Text(
              'Radio Band',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildRadioChoice(
                    radioId: 'radio0',
                    label: '2.4 GHz Radio',
                    subtitle: 'MT7603E • Long Range',
                    isSelected: _selectedRadio == 'radio0',
                    onTap: () => setState(() => _selectedRadio = 'radio0'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRadioChoice(
                    radioId: 'radio1',
                    label: '5.0 GHz Radio',
                    subtitle: 'MT7613BEN • High Speed',
                    isSelected: _selectedRadio == 'radio1',
                    onTap: () => setState(() => _selectedRadio = 'radio1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Password
            GlossyInput(
              controller: _keyController,
              label: 'WPA2 Passphrase',
              hint: 'Minimum 8 characters',
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 14),

            // Client Isolation Switch
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Enforce Client Isolation',
                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Isolated VLAN-like access for guests',
                        style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isIsolated,
                    activeThumbColor: GlossyColors.isolatedAccent,
                    onChanged: (val) => setState(() => _isIsolated = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Submit Button
            GlossyButton(
              label: 'Create SSID',
              icon: Icons.add_circle_outline,
              isLoading: _isLoading,
              onPressed: _createSsid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioChoice({
    required String radioId,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? GlossyColors.primaryBlue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? GlossyColors.primaryBlue : GlossyColors.glassBorderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? GlossyColors.lightBlue : GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: GlossyColors.lightBlue, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareSsidSheet extends StatelessWidget {
  final SsidInfo ssid;

  const _ShareSsidSheet({required this.ssid});

  @override
  Widget build(BuildContext context) {
    final passwordText = ssid.password ?? 'Managed on Router';
    final qrPayload = 'WIFI:S:${ssid.ssid};T:${ssid.encryption.contains("WPA") ? "WPA" : "nopass"};P:${ssid.password ?? ""};;';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share Wi-Fi Credentials',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      ssid.band,
                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                GlossyBadge(
                  label: ssid.enabled ? 'Active' : 'Inactive',
                  dotColor: ssid.enabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Details Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Column(
                children: [
                  _buildShareRow('Network Name (SSID)', ssid.ssid, context),
                  const Divider(color: GlossyColors.glassDivider, height: 20),
                  _buildShareRow('Security', ssid.encryption, context, canCopy: false),
                  const Divider(color: GlossyColors.glassDivider, height: 20),
                  _buildShareRow('Password', passwordText, context),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Copy Quick Wi-Fi Link Button
            GlossyButton(
              label: 'Copy Wi-Fi Connect String',
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrPayload));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Wi-Fi connection string copied to clipboard!'),
                    backgroundColor: GlossyColors.emeraldMint,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareRow(String label, String value, BuildContext context, {bool canCopy = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: GlossyColors.lightBlue, size: 18),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied "$value" to clipboard.'),
                  backgroundColor: GlossyColors.emeraldMint,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _ConnectedDevicesSheet extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> clients;

  const _ConnectedDevicesSheet({required this.ssid, required this.clients});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ssid.ssid} Clients',
                    style: const TextStyle(
                      color: GlossyColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${clients.length} device(s) currently connected',
                    style: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                  ),
                ],
              ),
              GlossyBadge(
                label: '${clients.length} Online',
                dotColor: clients.isNotEmpty ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (clients.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Column(
                  children: [
                    const Icon(Icons.devices_outlined, color: GlossyColors.textMuted, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'No devices connected to "${ssid.ssid}"',
                      style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Connected clients will appear here automatically.',
                      style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: clients.length,
                separatorBuilder: (_, _) => const Divider(color: GlossyColors.glassDivider, height: 12),
                itemBuilder: (ctx, idx) {
                  final client = clients[idx];
                  return Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GlossyColors.glassBorderLight),
                        ),
                        child: const Icon(Icons.phone_android_rounded, color: GlossyColors.lightBlue, size: 18),
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${client.ip} • ${client.mac}',
                              style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      GlossyBadge(
                        label: '${client.signalDbm} dBm',
                        dotColor: client.signalDbm > -65 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String title;
  final String subtitle;
  final double? width;
  final IconData? icon;

  const _FeaturePill({
    required this.title,
    required this.subtitle,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Row(
        mainAxisSize: width != null ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: GlossyColors.primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: GlossyColors.lightBlue, size: 14),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: width != null ? 1 : 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SsidDetailSheet extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> clients;
  final List<SsidInfo> allSsids;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const _SsidDetailSheet({
    required this.ssid,
    required this.clients,
    required this.allSsids,
    required this.onEdit,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final is5g = ssid.band.contains('5');
    final qualityPercent = WirelessInfo.getSsidSignalQualityPercent(ssid, clients);
    final qualityText = WirelessInfo.getSsidSignalQualityText(qualityPercent);

    // Calculate total traffic share
    final totalAllTraffic = allSsids.fold<int>(0, (sum, s) => sum + s.totalBytes);
    final trafficShare = totalAllTraffic > 0
        ? ((ssid.totalBytes / totalAllTraffic) * 100).clamp(0.0, 100.0)
        : 0.0;

    // Check rank among SSIDs
    final sortedByTraffic = List<SsidInfo>.from(allSsids)
      ..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
    final rank = sortedByTraffic.indexWhere((s) => s.id == ssid.id) + 1;
    final isTopTraffic = rank == 1 && ssid.totalBytes > 0;

    // Average signal of clients
    final String avgSignalText;
    if (clients.isNotEmpty) {
      final avgRssi = (clients.fold<int>(0, (sum, c) => sum + c.signalDbm) / clients.length).round();
      avgSignalText = '$avgRssi dBm (${clients.length} device${clients.length > 1 ? "s" : ""} active)';
    } else {
      avgSignalText = 'No active client telemetry';
    }

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),

          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white10).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white24).withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(
                  ssid.enabled ? Icons.wifi_rounded : Icons.wifi_off_rounded,
                  color: ssid.enabled ? GlossyColors.lightBlue : GlossyColors.textMuted,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            ssid.ssid,
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            ssid.band,
                            style: TextStyle(
                              color: is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ssid.id} • ${ssid.ifname.isNotEmpty ? ssid.ifname : ssid.radio} • Ch ${ssid.channel}',
                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              GlossyBadge(
                label: ssid.enabled ? 'Active' : 'Inactive',
                dotColor: ssid.enabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
              ),
            ],
          ),

          if (isTopTraffic) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: GlossyColors.amberWarm.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GlossyColors.amberWarm.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.emoji_events_rounded, color: GlossyColors.amberWarm, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '#1 Top Data Consuming Wi-Fi Network on this Router',
                      style: TextStyle(
                        color: GlossyColors.amberWarm,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Data Traffic & Throughput Section
                  _buildSectionHeader(
                    icon: Icons.data_usage_rounded,
                    title: 'Data Traffic & Bandwidth',
                    badge: isTopTraffic ? 'Highest Usage' : 'Rank #$rank',
                    badgeColor: isTopTraffic ? GlossyColors.amberWarm : GlossyColors.primaryBlue,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GlossyColors.glassBorderLight),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Download
                            Expanded(
                              child: _buildMetricTile(
                                icon: Icons.arrow_downward_rounded,
                                iconColor: GlossyColors.lightBlue,
                                label: 'Total Downloaded',
                                value: ssid.formattedDownload,
                                subtitle: '${trafficShare.toStringAsFixed(1)}% of Wi-Fi volume',
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Upload
                            Expanded(
                              child: _buildMetricTile(
                                icon: Icons.arrow_upward_rounded,
                                iconColor: GlossyColors.skyBlue,
                                label: 'Total Uploaded',
                                value: ssid.formattedUpload,
                                subtitle: 'Aggregated client Tx',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: GlossyColors.glassDivider, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Combined Throughput',
                              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              ssid.formattedTotalData,
                              style: const TextStyle(
                                color: GlossyColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (trafficShare / 100).clamp(0.02, 1.0),
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTopTraffic ? GlossyColors.amberWarm : GlossyColors.primaryBlue,
                            ),
                            minHeight: 6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Coverage Range & Propagation Section
                  _buildSectionHeader(
                    icon: Icons.radar_rounded,
                    title: 'Coverage Distance & Propagation',
                    badge: ssid.is5GHz ? 'High Speed' : 'Long Range',
                    badgeColor: ssid.is5GHz ? GlossyColors.lightBlue : GlossyColors.emeraldMint,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GlossyColors.glassBorderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Estimated Indoor Range', ssid.estimatedIndoorRange),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow('Outdoor Line-of-Sight', ssid.estimatedOutdoorRange),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow('Wall & Obstacle Penetration', ssid.wallPenetration),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow('Transmit Power (TX)', '${ssid.txpowerDbm} dBm (${ssid.is5GHz ? "200 mW" : "100 mW"})'),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow('Bandwidth Profile', ssid.coverageType),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline_rounded, color: GlossyColors.textMuted, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ssid.is5GHz
                                      ? '5.0 GHz signals provide ultra-low latency and peak speeds, but attenuate faster through solid walls.'
                                      : '2.4 GHz radio frequency provides maximum physical reach and penetrates multiple brick/concrete walls easily.',
                                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11, height: 1.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. Network Quality & Link Health Section
                  _buildSectionHeader(
                    icon: Icons.network_check_rounded,
                    title: 'Network Quality & Health',
                    badge: '$qualityPercent%',
                    badgeColor: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: GlossyColors.glassBorderLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Signal Quality Score',
                              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                            ),
                            Text(
                              qualityText,
                              style: TextStyle(
                                color: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (qualityPercent / 100).clamp(0.05, 1.0),
                            backgroundColor: Colors.white10,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                            ),
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _buildDetailRow('Connected Clients Average Signal', avgSignalText),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow(
                          'Channel Congestion',
                          ssid.is5GHz ? 'Ultra-Clean (80 MHz Wideband)' : 'Ch ${ssid.channel} (Standard 20/40 MHz)',
                        ),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow('Encryption Standard', ssid.encryption),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow(
                          'Client Isolation',
                          ssid.isIsolated ? 'Enabled (Intra-BSS Blocked)' : 'Disabled (LAN Sharing Allowed)',
                        ),
                        const Divider(color: GlossyColors.glassDivider, height: 16),
                        _buildDetailRow(
                          'Beacon Broadcast',
                          ssid.isHidden ? 'Hidden (Stealth SSID)' : 'Visible Broadcast',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. Connected Devices Section
                  _buildSectionHeader(
                    icon: Icons.devices_rounded,
                    title: 'Connected Devices',
                    badge: '${clients.length} Online',
                    badgeColor: clients.isNotEmpty ? GlossyColors.emeraldMint : GlossyColors.textMuted,
                  ),
                  const SizedBox(height: 8),
                  if (clients.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: GlossyColors.glassBorderLight),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.devices_outlined, color: GlossyColors.textMuted, size: 36),
                          const SizedBox(height: 8),
                          Text(
                            'No devices currently connected to "${ssid.ssid}"',
                            style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'When devices join this Wi-Fi, their live stats will appear here.',
                            style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: clients.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, idx) {
                        final client = clients[idx];
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.04),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: GlossyColors.glassBorderLight),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.06),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: Icon(
                                  client.hostname.toLowerCase().contains('mac') || client.hostname.toLowerCase().contains('pc')
                                      ? Icons.laptop_mac_rounded
                                      : (client.hostname.toLowerCase().contains('tv')
                                          ? Icons.tv_rounded
                                          : Icons.phone_android_rounded),
                                  color: GlossyColors.lightBlue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            client.displayName,
                                            style: const TextStyle(
                                              color: GlossyColors.textPrimary,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        if (client.vendor != null) ...[
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${client.vendor})',
                                            style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${client.ip} • ${client.mac}',
                                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.arrow_downward_rounded, color: GlossyColors.lightBlue, size: 11),
                                        const SizedBox(width: 2),
                                        Text(client.formattedRx, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10)),
                                        const SizedBox(width: 6),
                                        const Icon(Icons.arrow_upward_rounded, color: GlossyColors.skyBlue, size: 11),
                                        const SizedBox(width: 2),
                                        Text(client.formattedTx, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  GlossyBadge(
                                    label: '${client.signalDbm} dBm',
                                    dotColor: client.signalDbm >= -65 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    client.signalQualityText,
                                    style: TextStyle(
                                      color: client.signalDbm >= -65 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          const Divider(color: GlossyColors.glassDivider, height: 1),
          const SizedBox(height: 12),

          // Action Toolbar
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Edit Config',
                  icon: Icons.edit_outlined,
                  style: GlossyButtonStyle.secondary,
                  height: 42,
                  onPressed: onEdit,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Share Wi-Fi',
                  icon: Icons.qr_code_2_rounded,
                  style: GlossyButtonStyle.secondary,
                  height: 42,
                  onPressed: onShare,
                ),
              ),
              const SizedBox(width: 10),
              GlossyButton(
                label: 'Close',
                height: 42,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String badge,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Icon(icon, color: GlossyColors.lightBlue, size: 16),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        GlossyBadge(label: badge, dotColor: badgeColor),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String subtitle,
  }) {
    return Container(
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
            children: [
              Icon(icon, color: iconColor, size: 14),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Interactive Protocols & Roaming Standards Detail Sheet
// -----------------------------------------------------------------------------

class _ProtocolsDetailSheet extends StatelessWidget {
  const _ProtocolsDetailSheet();

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
          // Drag Handle
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

          // Header Row
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
                      style: TextStyle(
                        color: GlossyColors.textMuted,
                        fontSize: 12,
                      ),
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

          // Hardware Chips Summary Banner
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

          // Scrollable Standards Explorer
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProtocolSection(
                    icon: Icons.sync_rounded,
                    title: '802.11r FT (Fast BSS Transition)',
                    badge: 'Sub-50ms Handoff',
                    badgeColor: GlossyColors.emeraldMint,
                    description:
                        'Allows client devices to roam seamlessly between APs and frequency bands without performing the full 4-way WPA handshake. Pre-authenticates transition keys so Zoom, WhatsApp, or VoIP calls never drop when moving around.',
                    specs: const [
                      {'Standard': 'IEEE 802.11r-2008'},
                      {'Reassociation': '< 50 milliseconds'},
                      {'Voice/Video Loss': 'Zero packet drop'},
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolSection(
                    icon: Icons.explore_rounded,
                    title: '802.11k & 802.11v (Assisted Steering)',
                    badge: 'Smart Steering',
                    badgeColor: GlossyColors.lightBlue,
                    description:
                        '802.11k provides neighbor AP and channel radio measurement reports, while 802.11v directs clients to optimal BSS IDs. Together they automatically nudge dual-band phones to 5.0 GHz when close and to 2.4 GHz when range drops.',
                    specs: const [
                      {'802.11k': 'Radio Resource Management'},
                      {'802.11v': 'BSS Transition Management'},
                      {'Band Optimization': 'Dynamic RSSI Steering'},
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolSection(
                    icon: Icons.speed_rounded,
                    title: '802.11ac Wave 2 (MU-MIMO 2x2)',
                    badge: '867 Mbps Peak',
                    badgeColor: GlossyColors.amberWarm,
                    description:
                        'Multi-User Multiple-Input Multiple-Output allows simultaneous transmission to multiple client devices concurrently rather than waiting in serial turns. Maximizes airtime efficiency in high-density smart homes.',
                    specs: const [
                      {'Spatial Streams': '2x2 MU-MIMO'},
                      {'Channel Width': '80 MHz (VHT80)'},
                      {'Beamforming': 'TxBF Explicit Beamforming'},
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolSection(
                    icon: Icons.security_rounded,
                    title: '802.11w PMF (Protected Management Frames)',
                    badge: 'Deauth Shield',
                    badgeColor: GlossyColors.emeraldMint,
                    description:
                        'Cryptographically signs unicast and multicast Wi-Fi management action frames (disassociate/deauthenticate) using BIP. Effectively renders rogue deauth packets and evil-twin disruption attacks completely harmless.',
                    specs: const [
                      {'Standard': 'IEEE 802.11w-2009'},
                      {'Protection': 'BIP Management Integrity'},
                      {'WPA3 Prerequisite': 'Mandatory for SAE'},
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolSection(
                    icon: Icons.lock_outline_rounded,
                    title: 'WPA2-PSK / WPA3-SAE (Hybrid Security)',
                    badge: 'Dragonfly SAE',
                    badgeColor: GlossyColors.lightBlue,
                    description:
                        'Provides state-of-the-art Simultaneous Authentication of Equals (SAE) with forward secrecy, preventing offline dictionary attacks while preserving seamless backwards compatibility for legacy 2.4GHz IoT hardware.',
                    specs: const [
                      {'Key Exchange': 'Dragonfly Handshake'},
                      {'Forward Secrecy': 'Active Session Ephemeral'},
                      {'Compatibility': 'WPA2/WPA3 Mixed Transition'},
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildProtocolSection(
                    icon: Icons.multitrack_audio_rounded,
                    title: 'WMM QoS (Wireless Multimedia)',
                    badge: 'HW Queued',
                    badgeColor: GlossyColors.emeraldMint,
                    description:
                        'Wi-Fi Multimedia traffic prioritization divides transmission into 4 Access Categories (Voice, Video, Best Effort, Background) so gaming packets and video streams take precedence over background downloads.',
                    specs: const [
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

          // Bottom Action
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

  Widget _buildProtocolSection({
    required IconData icon,
    required String title,
    required String badge,
    required Color badgeColor,
    required String description,
    required List<Map<String, String>> specs,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: badgeColor, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(label: badge, dotColor: badgeColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                for (int i = 0; i < specs.length; i++) ...[
                  if (i > 0) const Divider(color: GlossyColors.glassDivider, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        specs[i].keys.first,
                        style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          specs[i].values.first,
                          style: const TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
