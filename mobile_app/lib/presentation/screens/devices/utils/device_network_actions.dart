import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';
import 'device_access_actions.dart';

class DeviceNetworkActions {
  DeviceNetworkActions._();

  static Future<bool> disconnectClient({
    required BuildContext context,
    required ClientInfo client,
    required RouterController controller,
    required NotificationCallback onNotify,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: const Row(
          children: [
            Icon(Icons.power_settings_new_rounded, color: GlossyColors.roseCoral, size: 22),
            SizedBox(width: 8),
            Text(
              'Turn Off Connection',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Do you want to disconnect and kick ${client.displayName} (${client.mac}) from the Wi-Fi network?',
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.roseCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Disconnect (Off)',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      await controller.executeAction('disconnect_client', {
        'target': client.mac,
        'mac': client.mac,
      });
      onNotify(
        message: 'Disconnected and kicked ${client.displayName} from Wi-Fi',
        icon: Icons.power_settings_new_rounded,
        color: GlossyColors.amberWarm,
      );
      return true;
    } catch (e) {
      onNotify(
        message: 'Disconnect failed: $e',
        icon: Icons.error_outline_rounded,
        color: GlossyColors.roseCoral,
      );
      return false;
    }
  }

  static Future<bool> sendWakeOnLan({
    required BuildContext context,
    required ClientInfo client,
    required RouterController controller,
    required NotificationCallback onNotify,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: const Row(
          children: [
            Icon(Icons.bolt_rounded, color: GlossyColors.amberWarm, size: 22),
            SizedBox(width: 8),
            Text(
              'Wake-on-LAN',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'Send Wake-on-LAN magic packet to broadcast ethernet frame for "${client.displayName}" (${client.mac})?',
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.amberWarm,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Send Magic Packet',
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      await controller.executeAction('wol', {
        'target': client.mac,
        'mac': client.mac,
      });
      onNotify(
        message: 'Wake-on-LAN magic packet sent to ${client.displayName} (${client.mac})',
        icon: Icons.bolt_rounded,
        color: GlossyColors.lightBlue,
      );
      return true;
    } catch (e) {
      onNotify(
        message: 'Wake-on-LAN failed: $e',
        icon: Icons.error_outline_rounded,
        color: GlossyColors.roseCoral,
      );
      return false;
    }
  }
}
