import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';

class DeactivateSsidDialog {
  DeactivateSsidDialog._();

  static Future<bool> confirm({
    required BuildContext context,
    required SsidInfo ssid,
  }) async {
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

    return confirmed == true;
  }
}
