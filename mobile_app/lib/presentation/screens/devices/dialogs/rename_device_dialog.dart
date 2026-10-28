import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';

class RenameDeviceDialog {
  RenameDeviceDialog._();

  static Future<void> show({
    required BuildContext context,
    required ClientInfo client,
    required RouterController controller,
    required void Function({
      required String message,
      required IconData icon,
      required Color color,
    }) onNotify,
  }) async {
    final textController = TextEditingController(text: client.customName ?? '');

    final result = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: GlossyColors.lightBlue, size: 24),
            SizedBox(width: 8),
            Text(
              'Rename Device',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign a custom nickname to identify this device across the network.',
                style: TextStyle(
                  color: GlossyColors.textSecondary.withValues(alpha: 0.9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: GlossyColors.glassBorderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.router_rounded, size: 16, color: GlossyColors.textMuted),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            client.hostname.isNotEmpty ? client.hostname : 'Unknown Hostname',
                            style: const TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            client.mac,
                            style: const TextStyle(
                              color: GlossyColors.textMuted,
                              fontSize: 10,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: textController,
                autofocus: true,
                style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 14),
                maxLength: 40,
                decoration: InputDecoration(
                  labelText: 'Device Nickname',
                  labelStyle: const TextStyle(color: GlossyColors.lightBlue, fontSize: 13),
                  hintText: 'e.g. Living Room TV, My iPhone',
                  hintStyle: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                  filled: true,
                  fillColor: GlossyColors.glassSurface,
                  counterStyle: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: GlossyColors.glassBorderLight),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: GlossyColors.lightBlue, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (client.customName != null && client.customName!.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(ctx, ''),
              child: const Text(
                'Reset Default',
                style: TextStyle(
                  color: GlossyColors.amberWarm,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text(
              'Cancel',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, textController.text.trim()),
            child: const Text(
              'Save Name',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (result == null) return;

    try {
      await controller.executeAction('rename_client', {
        'target': client.mac,
        'mac': client.mac,
        'name': result,
        'value': result,
        'val': result,
      });
      onNotify(
        message: result.isEmpty
            ? 'Device nickname reset to default (${client.hostname})'
            : 'Device renamed to "$result"',
        icon: Icons.check_circle_outline_rounded,
        color: GlossyColors.emeraldMint,
      );
    } catch (e) {
      onNotify(
        message: 'Failed to rename device: $e',
        icon: Icons.error_outline_rounded,
        color: GlossyColors.roseCoral,
      );
    }
  }
}
