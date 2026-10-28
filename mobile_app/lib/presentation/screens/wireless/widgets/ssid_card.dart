import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_card.dart';
import 'ssid_card_badges_row.dart';
import 'ssid_card_toolbar.dart';

class SsidCard extends StatelessWidget {
  final SsidInfo ssid;
  final List<ClientInfo> allClients;
  final SsidInfo? topTrafficSsid;
  final bool isToggling;
  final ValueChanged<bool> onToggle;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDevices;
  final VoidCallback? onDelete;

  const SsidCard({
    super.key,
    required this.ssid,
    required this.allClients,
    this.topTrafficSsid,
    this.isToggling = false,
    required this.onToggle,
    required this.onTap,
    required this.onEdit,
    required this.onShare,
    required this.onDevices,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isGuestOrIsolated = ssid.isGuest || ssid.isIsolated;
    final is5g = ssid.band.contains('5');
    final isTopTraffic = topTrafficSsid != null && ssid.id == topTrafficSsid!.id && ssid.totalBytes > 0;
    final qualityPercent = WirelessInfo.getSsidSignalQualityPercent(ssid, allClients);
    final qualityText = WirelessInfo.getSsidSignalQualityText(qualityPercent);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GlossyCard(
        onTap: onTap,
        borderColor: isGuestOrIsolated
            ? GlossyColors.isolatedAccent.withValues(alpha: 0.4)
            : (isTopTraffic ? GlossyColors.amberWarm.withValues(alpha: 0.35) : null),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SsidCardBadgesRow(
              ssid: ssid,
              is5g: is5g,
              isTopTraffic: isTopTraffic,
              isGuestOrIsolated: isGuestOrIsolated,
              isToggling: isToggling,
              onToggle: onToggle,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white10).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (ssid.enabled ? GlossyColors.primaryBlue : Colors.white24).withValues(alpha: 0.25)),
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
                        style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: -0.2),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Interface: ${ssid.id} • ${ssid.ifname.isNotEmpty ? ssid.ifname : ssid.radio}',
                        style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: GlossyColors.textMuted, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_downward_rounded, color: GlossyColors.lightBlue, size: 13),
                        const SizedBox(width: 2),
                        Text(ssid.formattedDownload, style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_upward_rounded, color: GlossyColors.skyBlue, size: 13),
                        const SizedBox(width: 2),
                        Text(ssid.formattedUpload, style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Icon(Icons.wifi_tethering_rounded, size: 13, color: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm),
                      const SizedBox(width: 4),
                      Text(
                        '$qualityPercent% ($qualityText) • ${ssid.estimatedIndoorRange.split(' ')[0]}',
                        style: TextStyle(color: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm, fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                children: [
                  Expanded(child: _buildInfoItem('Security', ssid.encryption)),
                  Expanded(child: _buildInfoItem('Channel', 'Ch ${ssid.channel}')),
                  Expanded(child: _buildInfoItem('Clients', '${ssid.connectedClients} Connected')),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: GlossyColors.glassDivider, height: 1),
            const SizedBox(height: 8),
            SsidCardToolbar(
              ssid: ssid,
              onEdit: onEdit,
              onShare: onShare,
              onDevices: onDevices,
              onDelete: onDelete,
            ),
            const SizedBox(height: 8),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Tap card for usage analysis, range & devices', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10, fontWeight: FontWeight.w500)),
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

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
  }
}
