import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_card.dart';
import 'wireless/dialogs/deactivate_ssid_dialog.dart';
import 'wireless/dialogs/delete_ssid_dialog.dart';
import 'wireless/utils/wireless_sheet_helper.dart';
import 'wireless/widgets/protocols_summary_card.dart';
import 'wireless/widgets/radio_power_card.dart';
import 'wireless/widgets/ssid_card.dart';
import 'wireless/widgets/top_traffic_banner.dart';
import 'wireless/widgets/wireless_ssid_header.dart';

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

  Future<void> _confirmAndToggleSsid(SsidInfo ssid, bool targetState) async {
    if (!targetState && ssid.enabled) {
      final confirmed = await DeactivateSsidDialog.confirm(context: context, ssid: ssid);
      if (!confirmed) return;
    }

    setState(() => _togglingSsidId = ssid.id);
    try {
      await widget.controller.toggleSsid(ssid.id, targetState);
      if (mounted) {
        if (targetState) {
          AppFeedback.showSuccess(context, 'SSID "${ssid.ssid}" enabled.');
        } else {
          AppFeedback.showWarning(context, 'SSID "${ssid.ssid}" disabled.');
        }
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to update SSID: $e');
      }
    } finally {
      if (mounted) setState(() => _togglingSsidId = null);
    }
  }

  Future<void> _applyTxPower(String radio, int power) async {
    setState(() => _isUpdatingTx = true);
    try {
      await widget.controller.executeAction('set_txpower', {
        'radio': radio,
        'txpower': power,
      });
      if (mounted) {
        AppFeedback.showSuccess(context, 'Applied TX power of $power dBm to $radio.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to set TX power: $e');
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTx = false);
    }
  }

  Widget _buildBandHeader({
    required String bandName,
    required String spec,
    required String tag,
    required int clients,
    required Color accentColor,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      bandName,
                      style: const TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  spec,
                  style: const TextStyle(
                    color: GlossyColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GlossyBadge(
            label: '$clients Connected',
            dotColor: clients > 0 ? GlossyColors.emeraldMint : GlossyColors.textMuted,
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader({
    required String title,
    required int count,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_tethering_rounded, size: 14, color: GlossyColors.lightBlue),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
          Text(
            '$count Configured',
            style: const TextStyle(
              color: GlossyColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyBandCard(String bandName) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlossyCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Center(
            child: Column(
              children: [
                const Icon(Icons.wifi_off_rounded, color: GlossyColors.textMuted, size: 30),
                const SizedBox(height: 8),
                Text(
                  'No $bandName SSIDs configured',
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tap "Add SSID" above to create an access point on this radio.',
                  style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

    final ssids2g = ssids.where((s) => !s.is5GHz && s.radio != 'radio1').toList();
    final ssids5g = ssids.where((s) => s.is5GHz || s.radio == 'radio1').toList();

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: GlossyColors.textPrimary, letterSpacing: -0.3),
            ),
            const Text(
              'Dual-Band Wi-Fi & SSID Management',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: GlossyColors.textSecondary),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlossyBadge(label: '$totalClients Clients', dotColor: isWifiActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral),
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
              WirelessSsidHeader(
                totalSsids: totalSsids,
                activeSsids: activeSsids,
                inactiveSsids: inactiveSsids,
                onAddSsid: () => WirelessSheetHelper.showAddSsidModal(context, widget.controller),
              ),
              const SizedBox(height: 14),
              if (wireless?.topTrafficSsid != null && (wireless?.topTrafficSsid?.totalBytes ?? 0) > 0) ...[
                TopTrafficBanner(topTrafficSsid: wireless!.topTrafficSsid!),
                const SizedBox(height: 14),
              ],

              // ── 2.4 GHz Radio & Networks ───────────────────────────
              _buildBandHeader(
                bandName: '2.4 GHz Radio & Networks',
                spec: 'MediaTek MT7603E • Long-Range Wi-Fi',
                tag: '2.4 GHz',
                clients: radio2g?.connectedClients ?? 0,
                accentColor: GlossyColors.skyBlue,
                icon: Icons.wifi_rounded,
              ),
              if (radio2g != null)
                RadioPowerCard(
                  band: '2.4 GHz (Long Range)',
                  chipset: 'MediaTek MT7603E',
                  ssid: radio2g.ssid,
                  channel: radio2g.channel,
                  channelWidth: '20/40 MHz',
                  clients: radio2g.connectedClients,
                  enabled: radio2g.enabled,
                  txPower: currentTx2g,
                  onTxPowerChanged: (val) => setState(() => _customTx2g = val),
                  onSaveTxPower: () => _applyTxPower('radio0', currentTx2g.round()),
                  isUpdatingTx: _isUpdatingTx,
                ),
              _buildSubHeader(
                title: '2.4 GHz Broadcasted SSIDs',
                count: ssids2g.length,
              ),
              if (ssids2g.isEmpty)
                _buildEmptyBandCard('2.4 GHz')
              else
                ...ssids2g.map((ssid) => SsidCard(
                      ssid: ssid,
                      allClients: allClients,
                      topTrafficSsid: wireless?.topTrafficSsid,
                      isToggling: _togglingSsidId == ssid.id,
                      onToggle: (val) => _confirmAndToggleSsid(ssid, val),
                      onTap: () => WirelessSheetHelper.showSsidDetailModal(context, widget.controller, ssid, allClients, ssids),
                      onEdit: () => WirelessSheetHelper.showEditSsidModal(context, widget.controller, ssid),
                      onShare: () => WirelessSheetHelper.showShareSsidModal(context, ssid),
                      onDevices: () => WirelessSheetHelper.showConnectedDevicesModal(context, ssid, allClients),
                      onDelete: !ssid.isPrimary
                          ? () => DeleteSsidDialog.show(context: context, ssid: ssid, controller: widget.controller)
                          : null,
                    )),

              const SizedBox(height: 24),

              // ── 5.0 GHz Radio & Networks ───────────────────────────
              _buildBandHeader(
                bandName: '5.0 GHz Radio & Networks',
                spec: 'MediaTek MT7613BEN • High-Throughput AC Wave 2',
                tag: '5.0 GHz',
                clients: radio5g?.connectedClients ?? 0,
                accentColor: GlossyColors.lightBlue,
                icon: Icons.bolt_rounded,
              ),
              if (radio5g != null)
                RadioPowerCard(
                  band: '5.0 GHz (AC Wave 2)',
                  chipset: 'MediaTek MT7613BEN',
                  ssid: radio5g.ssid,
                  channel: radio5g.channel,
                  channelWidth: '80 MHz',
                  clients: radio5g.connectedClients,
                  enabled: radio5g.enabled,
                  txPower: currentTx5g,
                  onTxPowerChanged: (val) => setState(() => _customTx5g = val),
                  onSaveTxPower: () => _applyTxPower('radio1', currentTx5g.round()),
                  isUpdatingTx: _isUpdatingTx,
                ),
              _buildSubHeader(
                title: '5.0 GHz Broadcasted SSIDs',
                count: ssids5g.length,
              ),
              if (ssids5g.isEmpty)
                _buildEmptyBandCard('5.0 GHz')
              else
                ...ssids5g.map((ssid) => SsidCard(
                      ssid: ssid,
                      allClients: allClients,
                      topTrafficSsid: wireless?.topTrafficSsid,
                      isToggling: _togglingSsidId == ssid.id,
                      onToggle: (val) => _confirmAndToggleSsid(ssid, val),
                      onTap: () => WirelessSheetHelper.showSsidDetailModal(context, widget.controller, ssid, allClients, ssids),
                      onEdit: () => WirelessSheetHelper.showEditSsidModal(context, widget.controller, ssid),
                      onShare: () => WirelessSheetHelper.showShareSsidModal(context, ssid),
                      onDevices: () => WirelessSheetHelper.showConnectedDevicesModal(context, ssid, allClients),
                      onDelete: !ssid.isPrimary
                          ? () => DeleteSsidDialog.show(context: context, ssid: ssid, controller: widget.controller)
                          : null,
                    )),

              const SizedBox(height: 24),
              ProtocolsSummaryCard(onTap: () => WirelessSheetHelper.showProtocolsModal(context)),
            ],
          ),
        ),
      ),
    );
  }
}
