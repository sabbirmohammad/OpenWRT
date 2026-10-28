import 'package:flutter/material.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_button.dart';

class SsidCardToolbar extends StatelessWidget {
  final SsidInfo ssid;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onDevices;
  final VoidCallback? onDelete;

  const SsidCardToolbar({
    super.key,
    required this.ssid,
    required this.onEdit,
    required this.onShare,
    required this.onDevices,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          GlossyButton(
            label: 'Edit',
            icon: Icons.edit_outlined,
            style: GlossyButtonStyle.secondary,
            height: 34,
            onPressed: onEdit,
          ),
          const SizedBox(width: 8),
          GlossyButton(
            label: 'Share',
            icon: Icons.qr_code_2_rounded,
            style: GlossyButtonStyle.secondary,
            height: 34,
            onPressed: onShare,
          ),
          const SizedBox(width: 8),
          GlossyButton(
            label: '${ssid.connectedClients} Devices',
            icon: Icons.devices_rounded,
            style: GlossyButtonStyle.secondary,
            height: 34,
            onPressed: onDevices,
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 8),
            GlossyButton(
              label: 'Delete',
              icon: Icons.delete_outline_rounded,
              style: GlossyButtonStyle.danger,
              height: 34,
              onPressed: onDelete!,
            ),
          ],
        ],
      ),
    );
  }
}
