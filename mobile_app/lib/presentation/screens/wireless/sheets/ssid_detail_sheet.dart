import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import 'ssid_detail/ssid_detail_clients.dart';
import 'ssid_detail/ssid_detail_coverage.dart';
import 'ssid_detail/ssid_detail_health.dart';
import 'ssid_detail/ssid_detail_traffic.dart';

class SsidDetailSheet extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> clients;
  final List<SsidInfo> allSsids;
  final VoidCallback onEdit;
  final VoidCallback onShare;

  const SsidDetailSheet({
    super.key,
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

    final totalAllTraffic = allSsids.fold<int>(0, (sum, s) => sum + s.totalBytes);
    final trafficShare = totalAllTraffic > 0
        ? ((ssid.totalBytes / totalAllTraffic) * 100).clamp(0.0, 100.0)
        : 0.0;

    final sortedByTraffic = List<SsidInfo>.from(allSsids)
      ..sort((a, b) => b.totalBytes.compareTo(a.totalBytes));
    final rank = sortedByTraffic.indexWhere((s) => s.id == ssid.id) + 1;
    final isTopTraffic = rank == 1 && ssid.totalBytes > 0;

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
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
          ),
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
                      style: TextStyle(color: GlossyColors.amberWarm, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SsidDetailClients(ssid: ssid, clients: clients),
                  const SizedBox(height: 20),
                  SsidDetailTraffic(
                    ssid: ssid,
                    isTopTraffic: isTopTraffic,
                    rank: rank,
                    trafficShare: trafficShare,
                  ),
                  const SizedBox(height: 20),
                  SsidDetailCoverage(ssid: ssid),
                  const SizedBox(height: 20),
                  SsidDetailHealth(
                    ssid: ssid,
                    qualityPercent: qualityPercent,
                    qualityText: qualityText,
                    avgSignalText: avgSignalText,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: GlossyColors.glassDivider, height: 1),
          const SizedBox(height: 12),
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
}
