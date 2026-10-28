import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';

class ShareSsidSheet extends StatelessWidget {
  final SsidInfo ssid;

  const ShareSsidSheet({super.key, required this.ssid});

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
            GlossyButton(
              label: 'Copy Wi-Fi Connect String',
              icon: Icons.copy_rounded,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: qrPayload));
                Navigator.pop(context);
                AppFeedback.showSuccess(context, 'Wi-Fi connection string copied to clipboard!');
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
            onPressed: () => ClipboardHelper.copy(context, value, label),
          ),
      ],
    );
  }
}
