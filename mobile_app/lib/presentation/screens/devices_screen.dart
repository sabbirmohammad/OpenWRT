import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import 'devices/dialogs/rename_device_dialog.dart';
import 'devices/sheets/device_details_sheet.dart';
import 'devices/utils/device_access_actions.dart';
import 'devices/utils/device_feedback_helper.dart';
import 'devices/utils/device_network_actions.dart';
import 'devices/widgets/device_card.dart';
import 'devices/widgets/device_empty_state.dart';
import 'devices/widgets/device_filter_bar.dart';

class DevicesScreen extends StatefulWidget {
  final RouterController controller;

  const DevicesScreen({super.key, required this.controller});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(DevicesScreen oldWidget) {
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

  void _notify({required String message, required IconData icon, required Color color}) {
    DeviceFeedbackHelper.showNotification(context: context, message: message, icon: icon, color: color);
  }

  ClientInfo _latestClient(ClientInfo client) {
    return widget.controller.status?.clients.firstWhere(
      (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
      orElse: () => client,
    ) ?? client;
  }

  void _showDeviceDetails(ClientInfo client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DeviceDetailsSheet(
        client: client,
        controller: widget.controller,
        onToggleBlock: () => DeviceAccessActions.toggleBlock(
          context: context,
          client: _latestClient(client),
          controller: widget.controller,
          onNotify: _notify,
        ),
        onToggleAuthPortal: () => DeviceAccessActions.toggleAuthPortal(
          context: context,
          client: _latestClient(client),
          controller: widget.controller,
          onNotify: _notify,
        ),
        onDisconnect: () => DeviceNetworkActions.disconnectClient(
          context: context,
          client: _latestClient(client),
          controller: widget.controller,
          onNotify: _notify,
        ),
        onWakeOnLan: () => DeviceNetworkActions.sendWakeOnLan(
          context: context,
          client: _latestClient(client),
          controller: widget.controller,
          onNotify: _notify,
        ),
        onRename: () => RenameDeviceDialog.show(
          context: context,
          client: _latestClient(client),
          controller: widget.controller,
          onNotify: _notify,
        ),
        onCopy: (val, label) => DeviceFeedbackHelper.copyToClipboard(context: context, text: val, label: label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;
    final allClients = status?.clients ?? [];

    final filteredClients = allClients.where((client) {
      if (_selectedFilter == '5.0 GHz' && !client.connectionType.contains('5GHz')) return false;
      if (_selectedFilter == '2.4 GHz' && !client.connectionType.contains('2.4GHz')) return false;
      if (_selectedFilter == 'LAN' && !client.connectionType.contains('LAN')) return false;
      if (_selectedFilter == 'Isolated' && !client.isIsolated) return false;
      if (_selectedFilter == 'Blocked' && !client.blocked) return false;

      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesHost = client.hostname.toLowerCase().contains(query);
        final matchesCustom = client.customName?.toLowerCase().contains(query) ?? false;
        final matchesIp = client.ip.toLowerCase().contains(query);
        final matchesMac = client.mac.toLowerCase().contains(query);
        if (!matchesHost && !matchesCustom && !matchesIp && !matchesMac) return false;
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: GlossyColors.backgroundPrimary,
      appBar: AppBar(
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connected Devices',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GlossyColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              '${allClients.length} Total Devices Online',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: GlossyColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GlossyBadge(
              label: '${allClients.length} Online',
              dotColor: GlossyColors.emeraldMint,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.controller.refresh(),
        color: GlossyColors.primaryBlue,
        backgroundColor: GlossyColors.backgroundSecondary,
        child: Column(
          children: [
            DeviceFilterBar(
              searchQuery: _searchQuery,
              selectedFilter: _selectedFilter,
              onSearchChanged: (val) => setState(() => _searchQuery = val),
              onFilterSelected: (val) => setState(() => _selectedFilter = val),
              allClients: allClients,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: filteredClients.isEmpty
                  ? const DeviceEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: filteredClients.length,
                      itemBuilder: (ctx, index) {
                        final client = filteredClients[index];
                        return DeviceCard(
                          client: client,
                          onTap: () => _showDeviceDetails(client),
                          onLongPress: () => RenameDeviceDialog.show(
                            context: context,
                            client: _latestClient(client),
                            controller: widget.controller,
                            onNotify: _notify,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
