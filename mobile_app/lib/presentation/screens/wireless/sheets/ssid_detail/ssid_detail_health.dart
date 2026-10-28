import 'package:flutter/material.dart';
import '../../../../../core/theme/glossy_colors.dart';
import '../../../../../models/router_status_model.dart';
import '../../../../widgets/glossy_badge.dart';

class SsidDetailHealth extends StatelessWidget {
  final SsidInfo ssid;
  final int qualityPercent;
  final String qualityText;
  final String avgSignalText;

  const SsidDetailHealth({
    super.key,
    required this.ssid,
    required this.qualityPercent,
    required this.qualityText,
    required this.avgSignalText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Icon(Icons.network_check_rounded, color: GlossyColors.lightBlue, size: 16),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'Network Quality & Health',
                      style: TextStyle(
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
            GlossyBadge(
              label: '$qualityPercent%',
              dotColor: qualityPercent >= 80 ? GlossyColors.emeraldMint : GlossyColors.amberWarm,
            ),
          ],
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
                  const Text('Signal Quality Score', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
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
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
