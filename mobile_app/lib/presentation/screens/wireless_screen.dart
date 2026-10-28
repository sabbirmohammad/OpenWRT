import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_card.dart';
import 'wireless/dialogs/deactivate_ssid_dialog.dart';
import 'wireless/dialogs/delete_ssid_dialog.dart';
import 'wireless/utils/wireless_sheet_helper.dart';
import 'wireless/widgets/master_wifi_card.dart';
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

  Future<void> _toggleMasterWifi() async {
    try {
      await widget.controller.executeAction('wifi_toggle');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Master Wi-Fi power toggled successfully.'), backgroundColor: GlossyColors.emeraldMint),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to toggle Wi-Fi: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    }
  }

  Future<void> _confirmAndToggleSsid(SsidInfo ssid, bool targetState) async {
    if (!targetState && ssid.enabled) {
      final confirmed = await DeactivateSsidDialog.confirm(context: context, ssid: ssid);
      if (!confirmed) return;
    }

    setState(() => _togglingSsidId = ssid.id);
    try {
      await widget.controller.toggleSsid(ssid.id, targetState);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SSID "${ssid.ssid}" ${targetState ? "enabled" : "disabled"}.'),
            backgroundColor: targetState ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied TX power of $power dBm to $radio.'), backgroundColor: GlossyColors.emeraldMint),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to set TX power: $e'), backgroundColor: GlossyColors.roseCoral),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdatingTx = false);
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
              MasterWifiCard(isWifiActive: isWifiActive, onToggle: _toggleMasterWifi),
              const SizedBox(height: 24),
              WirelessSsidHeader(
                totalSsids: totalSsids,
                activeSsids: activeSsids,
                inactiveSsids: inactiveSsids,
                onAddSsid: () => WirelessSheetHelper.showAddSsidModal(context, widget.controller),
              ),
              const SizedBox(height: 14),
              if (ssids.isEmpty)
                const GlossyCard(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.wifi_off_rounded, color: GlossyColors.textMuted, size: 36),
                          SizedBox(height: 8),
                          Text('No SSIDs configured or detected.', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (wireless?.topTrafficSsid != null && (wireless?.topTrafficSsid?.totalBytes ?? 0) > 0)
                  TopTrafficBanner(topTrafficSsid: wireless!.topTrafficSsid!),
                ...ssids.map((ssid) => SsidCard(
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
              ],
              const SizedBox(height: 20),
              const Text(
                'Hardware Radios & RF Tuning',
                style: TextStyle(color: GlossyColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: -0.2),
              ),
              const SizedBox(height: 12),
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
                  onSaveTxPower: () => _applyTxPower('radio0', currentTx5g.round()),
                  isUpdatingTx: _isUpdatingTx,
                ),
              const SizedBox(height: 16),
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
                  onSaveTxPower: () => _applyTxPower('radio1', currentTx2g.round()),
                  isUpdatingTx: _isUpdatingTx,
                ),
              const SizedBox(height: 20),
              ProtocolsSummaryCard(onTap: () => WirelessSheetHelper.showProtocolsModal(context)),
            ],
          ),
        ),
      ),
    );
  }
}
