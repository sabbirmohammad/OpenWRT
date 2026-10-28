import 'package:flutter/material.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_button.dart';

class DeviceDetailsActions extends StatelessWidget {
  final ClientInfo client;
  final Future<bool> Function() onToggleBlock;
  final Future<bool> Function() onToggleAuthPortal;
  final Future<bool> Function() onDisconnect;
  final Future<bool> Function() onWakeOnLan;
  final VoidCallback onRename;

  const DeviceDetailsActions({
    super.key,
    required this.client,
    required this.onToggleBlock,
    required this.onToggleAuthPortal,
    required this.onDisconnect,
    required this.onWakeOnLan,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: GlossyButton(
                label: client.blocked ? 'Unblock Access' : 'Block Access',
                icon: client.blocked ? Icons.lock_open_rounded : Icons.block_rounded,
                style: client.blocked ? GlossyButtonStyle.primary : GlossyButtonStyle.danger,
                height: 44,
                onPressed: () async {
                  final success = await onToggleBlock();
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlossyButton(
                label: client.ndsAuthenticated ? 'Deauth Portal' : 'Auth Portal',
                icon: client.ndsAuthenticated ? Icons.lock_reset_rounded : Icons.vpn_key_rounded,
                style: client.ndsAuthenticated ? GlossyButtonStyle.secondary : GlossyButtonStyle.primary,
                height: 44,
                onPressed: () async {
                  final success = await onToggleAuthPortal();
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: GlossyButton(
                label: 'Disconnect (Off)',
                icon: Icons.power_settings_new_rounded,
                style: GlossyButtonStyle.danger,
                height: 44,
                onPressed: () async {
                  final success = await onDisconnect();
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GlossyButton(
                label: 'Wake-on-LAN',
                icon: Icons.bolt_rounded,
                style: GlossyButtonStyle.secondary,
                height: 44,
                onPressed: () async {
                  final success = await onWakeOnLan();
                  if (success && context.mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GlossyButton(
          label: (client.customName != null && client.customName!.isNotEmpty)
              ? 'Edit Nickname ("${client.displayName}")'
              : 'Rename Device',
          icon: Icons.edit_note_rounded,
          style: GlossyButtonStyle.secondary,
          height: 44,
          onPressed: onRename,
        ),
      ],
    );
  }
}
