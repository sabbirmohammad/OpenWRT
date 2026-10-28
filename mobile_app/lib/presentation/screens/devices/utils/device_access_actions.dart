import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';

typedef NotificationCallback = void Function({
  required String message,
  required IconData icon,
  required Color color,
});

class DeviceAccessActions {
  DeviceAccessActions._();

  static Future<bool> toggleBlock({
    required BuildContext context,
    required ClientInfo client,
    required RouterController controller,
    required NotificationCallback onNotify,
  }) async {
    final willBlock = !client.blocked;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: Row(
          children: [
            Icon(
              willBlock ? Icons.block_rounded : Icons.lock_open_rounded,
              color: willBlock ? GlossyColors.roseCoral : GlossyColors.emeraldMint,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              willBlock ? 'Block Device Access' : 'Unblock Device Access',
              style: const TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          willBlock
              ? 'Are you sure you want to block internet access for "${client.displayName}" (${client.mac})? All active connections will be terminated immediately.'
              : 'Restore full internet access for "${client.displayName}" (${client.mac})?',
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willBlock ? GlossyColors.roseCoral : GlossyColors.emeraldMint,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              willBlock ? 'Block Access' : 'Unblock',
              style: TextStyle(
                color: willBlock ? Colors.white : Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    final action = client.blocked ? 'unblock_client' : 'block_client';
    try {
      await controller.executeAction(action, {
        'target': client.mac,
        'mac': client.mac,
      });
      onNotify(
        message: client.blocked
            ? 'Successfully unblocked ${client.displayName} (${client.mac})'
            : 'Blocked internet access for ${client.displayName}',
        icon: client.blocked ? Icons.lock_open_rounded : Icons.block_rounded,
        color: client.blocked ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
      );
      return true;
    } catch (e) {
      onNotify(
        message: 'Block action failed: $e',
        icon: Icons.error_outline_rounded,
        color: GlossyColors.roseCoral,
      );
      return false;
    }
  }

  static Future<bool> toggleAuthPortal({
    required BuildContext context,
    required ClientInfo client,
    required RouterController controller,
    required NotificationCallback onNotify,
  }) async {
    final isAuth = client.ndsAuthenticated;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: Row(
          children: [
            Icon(
              isAuth ? Icons.lock_reset_rounded : Icons.vpn_key_rounded,
              color: isAuth ? GlossyColors.amberWarm : GlossyColors.emeraldMint,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isAuth ? 'Revoke Portal Auth' : 'Authorize Device',
              style: const TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          isAuth
              ? 'Revoke captive portal authentication for "${client.displayName}"? The device will be redirected to the splash login page.'
              : 'Authorize "${client.displayName}" (${client.mac}) on the captive portal for 120 minutes without credentials?',
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAuth ? GlossyColors.amberWarm : GlossyColors.primaryBlue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              isAuth ? 'Revoke Auth' : 'Authorize (2h)',
              style: TextStyle(
                color: isAuth ? Colors.black : Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    final action = isAuth ? 'nds_deauth' : 'nds_auth';
    try {
      await controller.executeAction(action, {
        'target': client.mac,
        'mac': client.mac,
        'value': '120',
        'val': '120',
        'minutes': 120,
      });
      onNotify(
        message: isAuth
            ? 'Captive portal session revoked for ${client.displayName}'
            : 'Authorized ${client.displayName} on Portal for 2 hours',
        icon: isAuth ? Icons.lock_reset_rounded : Icons.vpn_key_rounded,
        color: isAuth ? GlossyColors.amberWarm : GlossyColors.emeraldMint,
      );
      return true;
    } catch (e) {
      onNotify(
        message: 'Portal action failed: $e',
        icon: Icons.error_outline_rounded,
        color: GlossyColors.roseCoral,
      );
      return false;
    }
  }
}
