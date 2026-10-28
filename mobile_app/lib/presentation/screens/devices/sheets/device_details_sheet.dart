import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_badge.dart';
import '../utils/device_icon_helper.dart';
import 'device_details_actions.dart';
import 'device_details_consumption.dart';
import 'device_details_network.dart';

class DeviceDetailsSheet extends StatefulWidget {
  final ClientInfo client;
  final RouterController controller;
  final Future<bool> Function() onToggleBlock;
  final Future<bool> Function() onToggleAuthPortal;
  final Future<bool> Function() onDisconnect;
  final Future<bool> Function() onWakeOnLan;
  final VoidCallback onRename;
  final void Function(String text, String label) onCopy;

  const DeviceDetailsSheet({
    super.key,
    required this.client,
    required this.controller,
    required this.onToggleBlock,
    required this.onToggleAuthPortal,
    required this.onDisconnect,
    required this.onWakeOnLan,
    required this.onRename,
    required this.onCopy,
  });

  @override
  State<DeviceDetailsSheet> createState() => _DeviceDetailsSheetState();
}

class _DeviceDetailsSheetState extends State<DeviceDetailsSheet> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DeviceDetailsSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final latestClient = widget.controller.status?.clients.firstWhere(
          (c) => c.mac.toLowerCase() == widget.client.mac.toLowerCase(),
          orElse: () => widget.client,
        ) ?? widget.client;

    final dlSpeed = widget.controller.getClientDownloadSpeed(latestClient.mac);
    final ulSpeed = widget.controller.getClientUploadSpeed(latestClient.mac);
    final totalSpeed = widget.controller.getClientTotalSpeed(latestClient.mac);
    final signalColor = DeviceIconHelper.resolveSignalColor(latestClient.signalDbm);

    return Container(
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: GlossyColors.glassBorderLight, width: 1.5),
          left: BorderSide(color: GlossyColors.glassBorderLight, width: 0.5),
          right: BorderSide(color: GlossyColors.glassBorderLight, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: GlossyColors.glassBorderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: (latestClient.blocked
                              ? GlossyColors.roseCoral
                              : (latestClient.isIsolated
                                  ? GlossyColors.isolatedAccent
                                  : GlossyColors.primaryBlue))
                          .withValues(alpha: latestClient.isIsolated ? 0.2 : 0.16),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: (latestClient.blocked
                                ? GlossyColors.roseCoral
                                : (latestClient.isIsolated
                                    ? GlossyColors.isolatedAccent
                                    : GlossyColors.lightBlue))
                            .withValues(alpha: latestClient.isIsolated ? 0.5 : 0.4),
                      ),
                    ),
                    child: Icon(
                      latestClient.isIsolated
                          ? Icons.wifi_lock_rounded
                          : (latestClient.connectionType.contains('5GHz')
                              ? Icons.wifi_sharp
                              : (latestClient.connectionType.contains('LAN')
                                  ? Icons.lan_outlined
                                  : Icons.devices_rounded)),
                      size: 26,
                      color: latestClient.blocked
                          ? GlossyColors.roseCoral
                          : (latestClient.isIsolated ? GlossyColors.isolatedLight : GlossyColors.lightBlue),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                latestClient.displayName,
                                style: TextStyle(
                                  color: latestClient.blocked ? GlossyColors.roseCoral : GlossyColors.textPrimary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            InkWell(
                              onTap: widget.onRename,
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: GlossyColors.lightBlue.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: GlossyColors.lightBlue.withValues(alpha: 0.3), width: 0.8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.edit_rounded, size: 13, color: GlossyColors.lightBlue),
                                    SizedBox(width: 4),
                                    Text('Rename', style: TextStyle(color: GlossyColors.lightBlue, fontSize: 10, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          latestClient.isIsolated
                              ? 'Isolated Wi-Fi • SSID: ${latestClient.ssidName}'
                              : '${latestClient.connectionType} • ${latestClient.ssidName.isNotEmpty ? latestClient.ssidName : "Ethernet Link"}',
                          style: TextStyle(
                            color: latestClient.isIsolated ? GlossyColors.isolatedLight : GlossyColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: GlossyColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  latestClient.blocked
                      ? const GlossyBadge(label: 'Internet Blocked', dotColor: GlossyColors.roseCoral)
                      : const GlossyBadge(label: 'Connected Online', dotColor: GlossyColors.emeraldMint),
                  if (latestClient.isIsolated)
                    const GlossyBadge(label: 'Isolated SSID', dotColor: GlossyColors.isolatedAccent),
                  if (latestClient.ndsAuthenticated)
                    const GlossyBadge(label: 'Portal Authenticated', dotColor: GlossyColors.emeraldMint),
                  if (!latestClient.connectionType.contains('LAN'))
                    GlossyBadge(
                      label: '${latestClient.signalDbm} dBm • ${latestClient.signalQualityText}',
                      dotColor: signalColor,
                    )
                  else
                    const GlossyBadge(label: '1 Gbps Full Duplex', dotColor: GlossyColors.emeraldMint),
                  if (latestClient.isStatic)
                    const GlossyBadge(label: 'Static IP', dotColor: GlossyColors.skyBlue),
                ],
              ),
              const SizedBox(height: 18),
              DeviceDetailsConsumption(client: latestClient, dlSpeed: dlSpeed, ulSpeed: ulSpeed, totalSpeed: totalSpeed),
              const SizedBox(height: 14),
              DeviceDetailsNetwork(client: latestClient, onCopy: widget.onCopy),
              const SizedBox(height: 20),
              DeviceDetailsActions(
                client: latestClient,
                onToggleBlock: widget.onToggleBlock,
                onToggleAuthPortal: widget.onToggleAuthPortal,
                onDisconnect: widget.onDisconnect,
                onWakeOnLan: widget.onWakeOnLan,
                onRename: widget.onRename,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
