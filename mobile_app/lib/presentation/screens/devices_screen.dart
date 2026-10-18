import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../../models/router_status_model.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';

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

  void _showNotification({
    required String message,
    required IconData icon,
    required Color color,
  }) {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 84),
        elevation: 8,
        backgroundColor: GlossyColors.backgroundElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: color.withValues(alpha: 0.6), width: 1.2),
        ),
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Color _resolveSignalColor(int dbm) {
    if (dbm >= -60) return GlossyColors.emeraldMint;
    if (dbm >= -72) return GlossyColors.lightBlue;
    if (dbm >= -82) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  IconData _resolveDeviceIcon(ClientInfo client) {
    final name = (client.customName?.isNotEmpty == true
            ? client.customName!
            : client.hostname)
        .toLowerCase();
    final vendor = (client.vendor ?? '').toLowerCase();
    final allText = '$name $vendor';

    // 1. Phones & Mobile Devices
    if (allText.contains('iphone') ||
        allText.contains('android') ||
        allText.contains('pixel') ||
        allText.contains('galaxy') ||
        allText.contains('-a34') ||
        allText.contains('-a5') ||
        allText.contains('v2419') ||
        allText.contains('vivo') ||
        allText.contains('oppo') ||
        allText.contains('xiaomi') ||
        allText.contains('redmi') ||
        allText.contains('realme') ||
        allText.contains('oneplus') ||
        allText.contains('poco') ||
        allText.contains('mobile') ||
        allText.contains('phone')) {
      return Icons.phone_android_rounded;
    }

    // 2. Tablets & iPads
    if (allText.contains('ipad') ||
        allText.contains('tablet') ||
        allText.contains('tab') ||
        allText.contains('pad')) {
      return Icons.tablet_mac_rounded;
    }

    // 3. Laptops & MacBooks
    if (allText.contains('macbook') ||
        allText.contains('laptop') ||
        allText.contains('notebook') ||
        allText.contains('thinkpad') ||
        allText.contains('zenbook') ||
        allText.contains('chromebook')) {
      return Icons.laptop_mac_rounded;
    }

    // 4. Desktop PCs & Workstations
    if (allText.contains('desktop') ||
        allText.contains('pc') ||
        allText.contains('imac') ||
        allText.contains('workstation') ||
        allText.contains('windows') ||
        allText.contains('linux')) {
      return Icons.desktop_windows_rounded;
    }

    // 5. Smart TVs & Streaming Devices
    if (allText.contains('tv') ||
        allText.contains('cast') ||
        allText.contains('chromecast') ||
        allText.contains('firestick') ||
        allText.contains('fire tv') ||
        allText.contains('roku') ||
        allText.contains('bravia') ||
        allText.contains('webos') ||
        allText.contains('sony') ||
        allText.contains('shield')) {
      return Icons.tv_rounded;
    }

    // 6. Smart Home, IoT & Raspberry Pi
    if (allText.contains('raspberry') ||
        allText.contains('pi') ||
        allText.contains('homeassistant') ||
        allText.contains('esp') ||
        allText.contains('arduino') ||
        allText.contains('sensor') ||
        allText.contains('smart') ||
        allText.contains('alexa') ||
        allText.contains('echo') ||
        allText.contains('nest')) {
      return Icons.memory_rounded;
    }

    // 7. Security Cameras
    if (allText.contains('cam') ||
        allText.contains('camera') ||
        allText.contains('cctv')) {
      return Icons.videocam_rounded;
    }

    // 8. Gaming Consoles
    if (allText.contains('playstation') ||
        allText.contains('ps4') ||
        allText.contains('ps5') ||
        allText.contains('xbox') ||
        allText.contains('nintendo') ||
        allText.contains('switch')) {
      return Icons.sports_esports_rounded;
    }

    // 9. Physical Media fallback
    if (client.connectionType.contains('LAN')) {
      return Icons.lan_outlined;
    }
    if (client.connectionType.contains('5GHz')) {
      return Icons.wifi_sharp;
    }
    if (client.connectionType.contains('2.4GHz')) {
      return Icons.wifi_2_bar_sharp;
    }

    return Icons.devices_rounded;
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showNotification(
      message: '$label copied to clipboard ($text)',
      icon: Icons.copy_rounded,
      color: GlossyColors.primaryBlue,
    );
  }

  Future<bool> _toggleBlock(ClientInfo client) async {
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
      await widget.controller.executeAction(action, {
        'target': client.mac,
        'mac': client.mac,
      });
      if (mounted) {
        _showNotification(
          message: client.blocked
              ? 'Successfully unblocked ${client.displayName} (${client.mac})'
              : 'Blocked internet access for ${client.displayName}',
          icon: client.blocked ? Icons.lock_open_rounded : Icons.block_rounded,
          color: client.blocked ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showNotification(
          message: 'Block action failed: $e',
          icon: Icons.error_outline_rounded,
          color: GlossyColors.roseCoral,
        );
      }
      return false;
    }
  }

  Future<bool> _toggleAuthPortal(ClientInfo client) async {
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
      await widget.controller.executeAction(action, {
        'target': client.mac,
        'mac': client.mac,
        'value': '120',
        'val': '120',
        'minutes': 120,
      });
      if (mounted) {
        _showNotification(
          message: isAuth
              ? 'Captive portal session revoked for ${client.displayName}'
              : 'Authorized ${client.displayName} on Portal for 2 hours',
          icon: isAuth ? Icons.lock_reset_rounded : Icons.vpn_key_rounded,
          color: isAuth ? GlossyColors.amberWarm : GlossyColors.emeraldMint,
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showNotification(
          message: 'Portal action failed: $e',
          icon: Icons.error_outline_rounded,
          color: GlossyColors.roseCoral,
        );
      }
      return false;
    }
  }

  Future<bool> _disconnectClient(ClientInfo client) async {
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
              style: TextStyle(color: GlossyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
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
            child: const Text('Disconnect (Off)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      await widget.controller.executeAction('disconnect_client', {
        'target': client.mac,
        'mac': client.mac,
      });
      if (mounted) {
        _showNotification(
          message: 'Disconnected and kicked ${client.displayName} from Wi-Fi',
          icon: Icons.power_settings_new_rounded,
          color: GlossyColors.amberWarm,
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showNotification(
          message: 'Disconnect failed: $e',
          icon: Icons.error_outline_rounded,
          color: GlossyColors.roseCoral,
        );
      }
      return false;
    }
  }

  Future<bool> _sendWakeOnLan(ClientInfo client) async {
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
              style: TextStyle(color: GlossyColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
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
            child: const Text('Send Magic Packet', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    try {
      await widget.controller.executeAction('wol', {
        'target': client.mac,
        'mac': client.mac,
      });
      if (mounted) {
        _showNotification(
          message: 'Wake-on-LAN magic packet sent to ${client.displayName} (${client.mac})',
          icon: Icons.bolt_rounded,
          color: GlossyColors.lightBlue,
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showNotification(
          message: 'Wake-on-LAN failed: $e',
          icon: Icons.error_outline_rounded,
          color: GlossyColors.roseCoral,
        );
      }
      return false;
    }
  }

  Future<void> _showRenameDialog(ClientInfo client) async {
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
                style: TextStyle(color: GlossyColors.textSecondary.withValues(alpha: 0.9), fontSize: 12),
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
                style: TextStyle(color: GlossyColors.amberWarm, fontSize: 13, fontWeight: FontWeight.w600),
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
      await widget.controller.executeAction('rename_client', {
        'target': client.mac,
        'mac': client.mac,
        'name': result,
        'value': result,
        'val': result,
      });
      if (mounted) {
        _showNotification(
          message: result.isEmpty
              ? 'Device nickname reset to default (${client.hostname})'
              : 'Device renamed to "$result"',
          icon: Icons.check_circle_outline_rounded,
          color: GlossyColors.emeraldMint,
        );
      }
    } catch (e) {
      if (mounted) {
        _showNotification(
          message: 'Failed to rename device: $e',
          icon: Icons.error_outline_rounded,
          color: GlossyColors.roseCoral,
        );
      }
    }
  }

  void _showDeviceDetails(ClientInfo client) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _DeviceDetailsSheet(
        client: client,
        controller: widget.controller,
        onToggleBlock: () {
          final latest = widget.controller.status?.clients.firstWhere(
            (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
            orElse: () => client,
          ) ?? client;
          return _toggleBlock(latest);
        },
        onToggleAuthPortal: () {
          final latest = widget.controller.status?.clients.firstWhere(
            (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
            orElse: () => client,
          ) ?? client;
          return _toggleAuthPortal(latest);
        },
        onDisconnect: () {
          final latest = widget.controller.status?.clients.firstWhere(
            (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
            orElse: () => client,
          ) ?? client;
          return _disconnectClient(latest);
        },
        onWakeOnLan: () {
          final latest = widget.controller.status?.clients.firstWhere(
            (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
            orElse: () => client,
          ) ?? client;
          return _sendWakeOnLan(latest);
        },
        onRename: () {
          final latest = widget.controller.status?.clients.firstWhere(
            (c) => c.mac.toLowerCase() == client.mac.toLowerCase(),
            orElse: () => client,
          ) ?? client;
          _showRenameDialog(latest);
        },
        onCopy: (val, label) => _copyToClipboard(context, val, label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;
    final allClients = status?.clients ?? [];

    final filteredClients = allClients.where((client) {
      // Filter by selection
      if (_selectedFilter == '5.0 GHz' && !client.connectionType.contains('5GHz')) return false;
      if (_selectedFilter == '2.4 GHz' && !client.connectionType.contains('2.4GHz')) return false;
      if (_selectedFilter == 'LAN' && !client.connectionType.contains('LAN')) return false;
      if (_selectedFilter == 'Isolated' && !client.isIsolated) return false;
      if (_selectedFilter == 'Blocked' && !client.blocked) return false;

      // Filter by search query
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
            // Unified Search Input & Filter Dropdown Row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  // Compact Search Input
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: GlossyColors.glassSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: GlossyColors.glassBorderLight,
                          width: 1.0,
                        ),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: const TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 13,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search device, IP, MAC...',
                          hintStyle: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                          prefixIcon: const Icon(Icons.search, color: GlossyColors.textSecondary, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, size: 16, color: GlossyColors.textMuted),
                                  onPressed: () => setState(() => _searchQuery = ''),
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dropdown Filter Button
                  _buildFilterDropdown(allClients),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // Client Cards List (Clean normal view: Device Name, Band, SSID, MAC, Quality)
            Expanded(
              child: filteredClients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other_rounded,
                            size: 56,
                            color: GlossyColors.textMuted.withValues(alpha: 0.6),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No devices found',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Try clearing search query or change filter category.',
                            style: TextStyle(
                              color: GlossyColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                      itemCount: filteredClients.length,
                      itemBuilder: (ctx, index) {
                        final client = filteredClients[index];
                        final signalColor = _resolveSignalColor(client.signalDbm);
                        final isBlocked = client.blocked;
                        final isIsolated = client.isIsolated;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: InkWell(
                            onTap: () => _showDeviceDetails(client),
                            onLongPress: () => _showRenameDialog(client),
                            borderRadius: BorderRadius.circular(16),
                            child: GlossyCard(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              borderColor: isBlocked
                                  ? GlossyColors.roseCoral.withValues(alpha: 0.4)
                                  : (isIsolated
                                      ? GlossyColors.isolatedAccent.withValues(alpha: 0.5)
                                      : null),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Device Type Icon Avatar
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: (isBlocked
                                              ? GlossyColors.roseCoral
                                              : (isIsolated
                                                  ? GlossyColors.isolatedAccent
                                                  : GlossyColors.primaryBlue))
                                          .withValues(alpha: isIsolated ? 0.16 : 0.12),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: (isBlocked
                                                ? GlossyColors.roseCoral
                                                : (isIsolated
                                                    ? GlossyColors.isolatedAccent
                                                    : GlossyColors.lightBlue))
                                            .withValues(alpha: isIsolated ? 0.5 : 0.3),
                                      ),
                                    ),
                                    child: Icon(
                                      _resolveDeviceIcon(client),
                                      size: 24,
                                      color: isBlocked
                                          ? GlossyColors.roseCoral
                                          : (isIsolated
                                              ? GlossyColors.isolatedLight
                                              : GlossyColors.lightBlue),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // Device Info Body
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Row 1: Device Name & Network Quality Badge
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                client.displayName,
                                                style: TextStyle(
                                                  color: isBlocked
                                                      ? GlossyColors.roseCoral
                                                      : GlossyColors.textPrimary,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: -0.2,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (isBlocked)
                                              const GlossyBadge(
                                                label: 'Blocked',
                                                dotColor: GlossyColors.roseCoral,
                                              )
                                            else if (isIsolated)
                                              GlossyBadge(
                                                label: client.signalDbm != 0
                                                    ? 'Isolated • ${client.signalDbm} dBm'
                                                    : 'Isolated SSID',
                                                dotColor: GlossyColors.isolatedAccent,
                                              )
                                            else if (!client.connectionType.contains('LAN'))
                                              GlossyBadge(
                                                label: '${client.signalDbm} dBm • ${client.signalQualityText}',
                                                dotColor: signalColor,
                                              )
                                            else
                                              const GlossyBadge(
                                                label: 'Gigabit LAN',
                                                dotColor: GlossyColors.emeraldMint,
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),

                                        // Row 2: Connected Network Band & SSID
                                        Row(
                                          children: [
                                            Icon(
                                              isIsolated
                                                  ? Icons.wifi_lock_rounded
                                                  : (client.connectionType.contains('LAN')
                                                      ? Icons.settings_ethernet_rounded
                                                      : Icons.wifi_rounded),
                                              size: 13,
                                              color: isIsolated
                                                  ? GlossyColors.isolatedLight
                                                  : GlossyColors.textMuted,
                                            ),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(
                                                isIsolated
                                                    ? 'Isolated Wi-Fi • SSID: ${client.ssidName.isNotEmpty ? client.ssidName : "Isolated"}'
                                                    : '${client.connectionType} • SSID: ${client.ssidName.isNotEmpty ? client.ssidName : (client.connectionType.contains('LAN') ? 'Ethernet LAN' : 'Wi-Fi')}',
                                                style: TextStyle(
                                                  color: isIsolated
                                                      ? GlossyColors.isolatedLight
                                                      : GlossyColors.skyBlue,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),

                                        // Row 3: MAC Address & IP Address
                                        Row(
                                          children: [
                                            const Icon(Icons.fingerprint_rounded, size: 13, color: GlossyColors.textMuted),
                                            const SizedBox(width: 4),
                                            Text(
                                              client.mac,
                                              style: const TextStyle(
                                                color: GlossyColors.textSecondary,
                                                fontSize: 11,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '• ${client.ip}',
                                              style: const TextStyle(
                                                color: GlossyColors.textMuted,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 6),
                                  // Right navigation chevron indicator
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    size: 18,
                                    color: isIsolated
                                        ? GlossyColors.isolatedLight.withValues(alpha: 0.8)
                                        : GlossyColors.textMuted,
                                  ),
                                ],
                              ),
                            ),
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

  Widget _buildFilterDropdown(List<ClientInfo> allClients) {
    final countAll = allClients.length;
    final count5G = allClients.where((c) => c.connectionType.contains('5GHz')).length;
    final count24G = allClients.where((c) => c.connectionType.contains('2.4GHz')).length;
    final countLan = allClients.where((c) => c.connectionType.contains('LAN')).length;
    final countIsolated = allClients.where((c) => c.isIsolated).length;
    final countBlocked = allClients.where((c) => c.blocked).length;

    int currentFilterCount;
    switch (_selectedFilter) {
      case '5.0 GHz':
        currentFilterCount = count5G;
        break;
      case '2.4 GHz':
        currentFilterCount = count24G;
        break;
      case 'LAN':
        currentFilterCount = countLan;
        break;
      case 'Isolated':
        currentFilterCount = countIsolated;
        break;
      case 'Blocked':
        currentFilterCount = countBlocked;
        break;
      default:
        currentFilterCount = countAll;
    }

    final isIsolatedFilter = _selectedFilter == 'Isolated';
    final isBlockedFilter = _selectedFilter == 'Blocked';

    return PopupMenuButton<String>(
      initialValue: _selectedFilter,
      tooltip: 'Filter devices',
      color: GlossyColors.backgroundElevated,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: GlossyColors.glassBorderLight),
      ),
      onSelected: (val) => setState(() => _selectedFilter = val),
      itemBuilder: (context) => [
        _buildPopupMenuItem('All', 'All Devices', countAll, Icons.devices_rounded),
        _buildPopupMenuItem('5.0 GHz', '5.0 GHz Wi-Fi', count5G, Icons.wifi_sharp),
        _buildPopupMenuItem('2.4 GHz', '2.4 GHz Wi-Fi', count24G, Icons.wifi_2_bar_sharp),
        _buildPopupMenuItem('LAN', 'Gigabit LAN', countLan, Icons.lan_outlined),
        _buildPopupMenuItem('Isolated', 'Isolated SSID', countIsolated, Icons.wifi_lock_rounded, isIsolated: true),
        _buildPopupMenuItem('Blocked', 'Blocked Clients', countBlocked, Icons.block_rounded, isDanger: true),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _selectedFilter != 'All'
              ? (isIsolatedFilter
                  ? GlossyColors.isolatedAccent.withValues(alpha: 0.18)
                  : (isBlockedFilter
                      ? GlossyColors.roseCoral.withValues(alpha: 0.18)
                      : GlossyColors.primaryBlue.withValues(alpha: 0.18)))
              : GlossyColors.glassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedFilter != 'All'
                ? (isIsolatedFilter
                    ? GlossyColors.isolatedAccent.withValues(alpha: 0.5)
                    : (isBlockedFilter
                        ? GlossyColors.roseCoral.withValues(alpha: 0.5)
                        : GlossyColors.lightBlue.withValues(alpha: 0.5)))
                : GlossyColors.glassBorderLight,
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _selectedFilter == 'All'
                  ? Icons.tune_rounded
                  : (isBlockedFilter
                      ? Icons.block_rounded
                      : (isIsolatedFilter ? Icons.wifi_lock_rounded : Icons.wifi_rounded)),
              size: 16,
              color: _selectedFilter == 'All'
                  ? GlossyColors.textSecondary
                  : (isIsolatedFilter
                      ? GlossyColors.isolatedLight
                      : (isBlockedFilter ? GlossyColors.roseCoral : GlossyColors.lightBlue)),
            ),
            const SizedBox(width: 6),
            Text(
              _selectedFilter == 'All' ? 'Filter' : _selectedFilter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _selectedFilter != 'All' ? Colors.white : GlossyColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: _selectedFilter != 'All'
                    ? (isIsolatedFilter
                        ? GlossyColors.isolatedAccent.withValues(alpha: 0.3)
                        : (isBlockedFilter
                            ? GlossyColors.roseCoral.withValues(alpha: 0.3)
                            : GlossyColors.lightBlue.withValues(alpha: 0.3)))
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$currentFilterCount',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _selectedFilter != 'All' ? Colors.white : GlossyColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: GlossyColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildPopupMenuItem(
    String value,
    String title,
    int count,
    IconData icon, {
    bool isDanger = false,
    bool isIsolated = false,
  }) {
    final isSelected = _selectedFilter == value;
    final itemColor = isDanger
        ? GlossyColors.roseCoral
        : (isIsolated
            ? GlossyColors.isolatedLight
            : (isSelected ? GlossyColors.lightBlue : GlossyColors.textSecondary));

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: itemColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: isDanger
                    ? GlossyColors.roseCoral
                    : (isIsolated && isSelected
                        ? GlossyColors.isolatedLight
                        : (isSelected ? Colors.white : GlossyColors.textPrimary)),
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isIsolated
                      ? GlossyColors.isolatedAccent.withValues(alpha: 0.4)
                      : (isDanger
                          ? GlossyColors.roseCoral.withValues(alpha: 0.4)
                          : GlossyColors.primaryBlue.withValues(alpha: 0.4)))
                  : Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: isSelected ? Colors.white : GlossyColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 6),
            Icon(
              Icons.check_rounded,
              size: 16,
              color: isIsolated
                  ? GlossyColors.isolatedLight
                  : (isDanger ? GlossyColors.roseCoral : GlossyColors.lightBlue),
            ),
          ],
        ],
      ),
    );
  }
}

/// Rich, interactive bottom sheet showing complete device details, consumption, duration, and control actions
class _DeviceDetailsSheet extends StatefulWidget {
  final ClientInfo client;
  final RouterController controller;
  final Future<bool> Function() onToggleBlock;
  final Future<bool> Function() onToggleAuthPortal;
  final Future<bool> Function() onDisconnect;
  final Future<bool> Function() onWakeOnLan;
  final VoidCallback onRename;
  final void Function(String text, String label) onCopy;

  const _DeviceDetailsSheet({
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
  State<_DeviceDetailsSheet> createState() => _DeviceDetailsSheetState();
}

class _DeviceDetailsSheetState extends State<_DeviceDetailsSheet> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(_DeviceDetailsSheet oldWidget) {
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

  Color _resolveSignalColor(int dbm) {
    if (dbm >= -60) return GlossyColors.emeraldMint;
    if (dbm >= -72) return GlossyColors.lightBlue;
    if (dbm >= -82) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  @override
  Widget build(BuildContext context) {
    // Look up real-time client data from controller if available to update live
    final latestClient = widget.controller.status?.clients.firstWhere(
          (c) => c.mac.toLowerCase() == widget.client.mac.toLowerCase(),
          orElse: () => widget.client,
        ) ??
        widget.client;

    final dlSpeed = widget.controller.getClientDownloadSpeed(latestClient.mac);
    final ulSpeed = widget.controller.getClientUploadSpeed(latestClient.mac);
    final totalSpeed = widget.controller.getClientTotalSpeed(latestClient.mac);
    final signalColor = _resolveSignalColor(latestClient.signalDbm);

    final totalBytes = latestClient.rxBytes + latestClient.txBytes;
    final rxRatio = totalBytes > 0 ? (latestClient.rxBytes / totalBytes) : 0.5;

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
              // Drag Handle
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

              // Header: Avatar, Name, Close Button
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
                          : (latestClient.isIsolated
                              ? GlossyColors.isolatedLight
                              : GlossyColors.lightBlue),
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
                                  color: latestClient.blocked
                                      ? GlossyColors.roseCoral
                                      : GlossyColors.textPrimary,
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
                                  border: Border.all(
                                    color: GlossyColors.lightBlue.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit_rounded,
                                      size: 13,
                                      color: GlossyColors.lightBlue,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Rename',
                                      style: TextStyle(
                                        color: GlossyColors.lightBlue,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
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
                            color: latestClient.isIsolated
                                ? GlossyColors.isolatedLight
                                : GlossyColors.textSecondary,
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

              // Badges Strip
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  if (latestClient.blocked)
                    const GlossyBadge(
                      label: 'Internet Blocked',
                      dotColor: GlossyColors.roseCoral,
                    )
                  else
                    const GlossyBadge(
                      label: 'Connected Online',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  if (latestClient.isIsolated)
                    const GlossyBadge(
                      label: 'Isolated SSID',
                      dotColor: GlossyColors.isolatedAccent,
                    ),
                  if (latestClient.ndsAuthenticated)
                    const GlossyBadge(
                      label: 'Portal Authenticated',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  if (!latestClient.connectionType.contains('LAN'))
                    GlossyBadge(
                      label: '${latestClient.signalDbm} dBm • ${latestClient.signalQualityText}',
                      dotColor: signalColor,
                    )
                  else
                    const GlossyBadge(
                      label: '1 Gbps Full Duplex',
                      dotColor: GlossyColors.emeraldMint,
                    ),
                  if (latestClient.isStatic)
                    const GlossyBadge(
                      label: 'Static IP',
                      dotColor: GlossyColors.skyBlue,
                    ),
                ],
              ),

              const SizedBox(height: 18),

              // SECTION 1: Real-time & Overall Data Consumption
              GlossyCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.speed_rounded, size: 16, color: GlossyColors.lightBlue),
                            SizedBox(width: 6),
                            Text(
                              'DATA CONSUMPTION',
                              style: TextStyle(
                                color: GlossyColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: GlossyColors.emeraldMint.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: GlossyColors.emeraldMint.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            'Live: $totalSpeed',
                            style: const TextStyle(
                              color: GlossyColors.emeraldMint,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Current Live Speeds Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.arrow_downward_rounded,
                            iconColor: GlossyColors.emeraldMint,
                            title: 'Current Download',
                            value: dlSpeed,
                            subtitle: 'Real-time throughput',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricTile(
                            icon: Icons.arrow_upward_rounded,
                            iconColor: GlossyColors.skyBlue,
                            title: 'Current Upload',
                            value: ulSpeed,
                            subtitle: 'Real-time throughput',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(color: GlossyColors.glassDivider),
                    const SizedBox(height: 10),

                    // Overall Consumption Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Data Consumed',
                              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              latestClient.formattedTotalTraffic,
                              style: const TextStyle(
                                color: GlossyColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'RX (Down)',
                                  style: TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                                ),
                                Text(
                                  latestClient.formattedRx,
                                  style: const TextStyle(
                                    color: GlossyColors.emeraldMint,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'TX (Up)',
                                  style: TextStyle(color: GlossyColors.textMuted, fontSize: 10),
                                ),
                                Text(
                                  latestClient.formattedTx,
                                  style: const TextStyle(
                                    color: GlossyColors.skyBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Visual Download vs Upload Ratio Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        height: 6,
                        color: GlossyColors.skyBlue.withValues(alpha: 0.3),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: rxRatio.clamp(0.02, 0.98),
                          child: Container(color: GlossyColors.emeraldMint),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SECTION 2: Connection Time & Network Duration
              GlossyCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 16, color: GlossyColors.amberWarm),
                        SizedBox(width: 6),
                        Text(
                          'CONNECTION TIMING & UPTIME',
                          style: TextStyle(
                            color: GlossyColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Connected Since',
                                style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                latestClient.formattedConnectedSince,
                                style: const TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: GlossyColors.glassDivider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Duration',
                                style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                latestClient.formattedUptime,
                                style: const TextStyle(
                                  color: GlossyColors.amberWarm,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // SECTION 3: Hardware & Network Addressing
              GlossyCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.settings_ethernet_rounded, size: 16, color: GlossyColors.lightBlue),
                        SizedBox(width: 6),
                        Text(
                          'NETWORK & HARDWARE ADDRESSING',
                          style: TextStyle(
                            color: GlossyColors.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildAddressRow(
                      icon: Icons.link_rounded,
                      label: 'IP Address',
                      value: latestClient.ip,
                      onCopy: () => widget.onCopy(latestClient.ip, 'IP Address'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: GlossyColors.glassDivider),
                    ),
                    _buildAddressRow(
                      icon: Icons.fingerprint_rounded,
                      label: 'MAC Address',
                      value: latestClient.mac,
                      onCopy: () => widget.onCopy(latestClient.mac, 'MAC Address'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: GlossyColors.glassDivider),
                    ),
                    _buildAddressRow(
                      icon: latestClient.isIsolated
                          ? Icons.wifi_lock_rounded
                          : Icons.wifi_tethering_rounded,
                      label: 'Network SSID',
                      value: latestClient.isIsolated
                          ? '${latestClient.ssidName.isNotEmpty ? latestClient.ssidName : "Isolated"} (Isolated SSID)'
                          : (latestClient.ssidName.isNotEmpty
                              ? latestClient.ssidName
                              : 'Ethernet Physical Link'),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: GlossyColors.glassDivider),
                    ),
                    _buildAddressRow(
                      icon: Icons.network_check_rounded,
                      label: 'Signal Strength',
                      value: latestClient.connectionType.contains('LAN')
                          ? 'Wired (LAN Link)'
                          : '${latestClient.signalDbm} dBm (${latestClient.signalQualityPercent}%)',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SECTION 4: Interactive Control Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      // Block / Unblock Button
                      Expanded(
                        child: GlossyButton(
                          label: latestClient.blocked ? 'Unblock Access' : 'Block Access',
                          icon: latestClient.blocked ? Icons.lock_open_rounded : Icons.block_rounded,
                          style: latestClient.blocked
                              ? GlossyButtonStyle.primary
                              : GlossyButtonStyle.danger,
                          height: 44,
                          onPressed: () async {
                            final success = await widget.onToggleBlock();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Auth / Deauth Portal Button
                      Expanded(
                        child: GlossyButton(
                          label: latestClient.ndsAuthenticated ? 'Deauth Portal' : 'Auth Portal',
                          icon: latestClient.ndsAuthenticated
                              ? Icons.lock_reset_rounded
                              : Icons.vpn_key_rounded,
                          style: latestClient.ndsAuthenticated
                              ? GlossyButtonStyle.secondary
                              : GlossyButtonStyle.primary,
                          height: 44,
                          onPressed: () async {
                            final success = await widget.onToggleAuthPortal();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      // Disconnect / Turn Off Button
                      Expanded(
                        child: GlossyButton(
                          label: 'Disconnect (Off)',
                          icon: Icons.power_settings_new_rounded,
                          style: GlossyButtonStyle.danger,
                          height: 44,
                          onPressed: () async {
                            final success = await widget.onDisconnect();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Wake-on-LAN Button
                      Expanded(
                        child: GlossyButton(
                          label: 'Wake-on-LAN',
                          icon: Icons.bolt_rounded,
                          style: GlossyButtonStyle.secondary,
                          height: 44,
                          onPressed: () async {
                            final success = await widget.onWakeOnLan();
                            if (success && context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Rename Device Action Button
                  GlossyButton(
                    label: (latestClient.customName != null && latestClient.customName!.isNotEmpty)
                        ? 'Edit Nickname ("${latestClient.displayName}")'
                        : 'Rename Device',
                    icon: Icons.edit_note_rounded,
                    style: GlossyButtonStyle.secondary,
                    height: 44,
                    onPressed: () => widget.onRename(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: GlossyColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: GlossyColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        if (onCopy != null) ...[
          const SizedBox(width: 8),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(Icons.copy_rounded, size: 13, color: GlossyColors.lightBlue),
            ),
          ),
        ],
      ],
    );
  }
}
