import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';

class DeleteSsidDialog {
  DeleteSsidDialog._();

  static Future<void> show({
    required BuildContext context,
    required SsidInfo ssid,
    required RouterController controller,
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
            Icon(Icons.delete_forever_rounded, color: GlossyColors.roseCoral, size: 22),
            SizedBox(width: 8),
            Text(
              'Delete Virtual SSID?',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete virtual SSID "${ssid.ssid}" (${ssid.id})?\n\n'
          'This will remove the wireless interface and disconnect all connected clients.',
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 14, height: 1.4),
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
            child: const Text('Delete SSID', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await controller.deleteSsid(ssid.id);
        if (context.mounted) {
          AppFeedback.showSuccess(context, 'Virtual SSID "${ssid.ssid}" deleted.');
        }
      } catch (e) {
        if (context.mounted) {
          AppFeedback.showError(context, 'Failed to delete SSID: $e');
        }
      }
    }
  }
}
