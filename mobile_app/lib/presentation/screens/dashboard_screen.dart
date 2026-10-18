import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/circular_gauge.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/hardware_vital_tile.dart';
import '../widgets/traffic_sparkline.dart';

class DashboardScreen extends StatelessWidget {
  final RouterController controller;
  final ValueChanged<int>? onNavigateToTab;
  final VoidCallback? onOpenDrawer;

  const DashboardScreen({
    super.key,
    required this.controller,
    this.onNavigateToTab,
    this.onOpenDrawer,
  });

  Color _resolveLatencyColor(int ms) {
    if (ms < 0) return GlossyColors.roseCoral;
    if (ms <= 15) return GlossyColors.emeraldMint;
    if (ms <= 50) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  @override
  Widget build(BuildContext context) {
    final status = controller.status;
    final isConnected = controller.isConnected;
    final latency = controller.latencyMs;

    return Scaffold(
      backgroundColor: GlossyColors.backgroundPrimary,
      appBar: AppBar(
        titleSpacing: 16,
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ArcherGuard C6',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: GlossyColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              controller.routerIp,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: GlossyColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Connection pill
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GlossyBadge(
              label: isConnected
                  ? (latency >= 0 ? '${latency}ms' : 'Connected')
                  : (controller.connectionState == RouterConnectionState.connecting
                      ? 'Connecting'
                      : 'Offline'),
              dotColor: isConnected
                  ? _resolveLatencyColor(latency)
                  : GlossyColors.roseCoral,
              onTap: () => controller.refresh(),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: controller.isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(GlossyColors.primaryBlue),
                    ),
                  )
                : const Icon(Icons.refresh, color: GlossyColors.textSecondary, size: 20),
            onPressed: controller.isRefreshing ? null : () => controller.refresh(),
            tooltip: 'Refresh Telemetry',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: GlossyColors.primaryBlue,
        backgroundColor: GlossyColors.backgroundSecondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline State Banner
              if (!isConnected) ...[
                GlossyCard(
                  surfaceColor: GlossyColors.roseCoral.withValues(alpha: 0.08),
                  borderColor: GlossyColors.roseCoral.withValues(alpha: 0.3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: GlossyColors.roseCoral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.wifi_off, color: GlossyColors.roseCoral, size: 20),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cannot Connect to Router',
                                  style: TextStyle(
                                    color: GlossyColors.textPrimary,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Verify your Android device is connected to the router\'s Wi-Fi.',
                                  style: TextStyle(
                                    color: GlossyColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (controller.errorMessage != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          controller.errorMessage!,
                          style: const TextStyle(
                            color: GlossyColors.roseCoral,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GlossyButton(
                              label: 'Retry Connection',
                              icon: Icons.refresh,
                              style: GlossyButtonStyle.primary,
                              isLoading: controller.isRefreshing,
                              onPressed: () => controller.refresh(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GlossyButton(
                              label: 'Edit Settings',
                              icon: Icons.tune,
                              style: GlossyButtonStyle.secondary,
                              onPressed: () {
                                if (onNavigateToTab != null) {
                                  onNavigateToTab!(4);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              if (status != null) ...[
                // Hardware Vitals Section
                GlossyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Flexible(
                            child: Text(
                              'Hardware Vitals',
                              style: TextStyle(
                                color: GlossyColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.3,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: GlossyBadge(
                              label: status.cpu.model.split('@').first.trim(),
                              showDot: false,
                              textColor: GlossyColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          CircularGauge(
                            value: status.cpu.usagePercent,
                            label: 'CPU',
                            subtitle: '${status.cpu.temperatureC.toStringAsFixed(0)}°C',
                          ),
                          CircularGauge(
                            value: status.memory.usagePercent,
                            label: 'RAM',
                            subtitle: status.memory.formattedUsedMb,
                          ),
                          CircularGauge(
                            value: status.storage.usagePercent,
                            label: 'Flash',
                            subtitle: status.storage.formattedUsedMb,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: GlossyColors.glassDivider),
                      const SizedBox(height: 12),
                      // 2x2 Graphical Hardware Vitals Grid
                      Row(
                        children: [
                          Expanded(
                            child: UptimeStabilityTile(
                              formattedUptime: status.cpu.formattedUptime,
                              uptimeSeconds: status.cpu.uptimeSeconds,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: LoadAverageTile(
                              loadAvgString: status.cpu.loadAvg,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: CpuCoresDieTile(
                              cores: status.cpu.cores,
                              threads: status.cpu.threads,
                              cpuUsagePercent: status.cpu.usagePercent,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ClockFrequencyTile(
                              frequencyMhz: status.cpu.frequencyMhz,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Internet / WAN Traffic Card with Live Speed
                GlossyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.public, color: GlossyColors.primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    'Internet (WAN)',
                                    style: TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GlossyColors.emeraldMint.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.fiber_manual_record, size: 6, color: GlossyColors.emeraldMint),
                                      SizedBox(width: 3),
                                      Text(
                                        'LIVE',
                                        style: TextStyle(
                                          color: GlossyColors.emeraldMint,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlossyBadge(
                            label: status.traffic.wanIp,
                            dotColor: GlossyColors.emeraldMint,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Live Speed Dual Meters (Download & Upload)
                      Row(
                        children: [
                          // Live Download Meter
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_downward_rounded, color: GlossyColors.emeraldMint, size: 14),
                                            SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Live Download',
                                                style: TextStyle(
                                                  color: GlossyColors.textSecondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: GlossyColors.emeraldMint,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.formattedDownloadSpeed,
                                    style: const TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TrafficSparkline(
                                    data: controller.downloadSpeedHistory,
                                    color: GlossyColors.emeraldMint,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // Live Upload Meter
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: GlossyColors.lightBlue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Expanded(
                                        child: Row(
                                          children: [
                                            Icon(Icons.arrow_upward_rounded, color: GlossyColors.lightBlue, size: 14),
                                            SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Live Upload',
                                                style: TextStyle(
                                                  color: GlossyColors.textSecondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 5,
                                        height: 5,
                                        decoration: const BoxDecoration(
                                          color: GlossyColors.lightBlue,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    controller.formattedUploadSpeed,
                                    style: const TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  TrafficSparkline(
                                    data: controller.uploadSpeedHistory,
                                    color: GlossyColors.lightBlue,
                                    height: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Cumulative Total Rx and Tx Footer
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.02),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: GlossyColors.glassBorderDark),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Total Rx: ',
                                    style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                  ),
                                  Flexible(
                                    child: Text(
                                      status.traffic.formattedRx,
                                      style: const TextStyle(
                                        color: GlossyColors.textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(width: 1, height: 12, color: GlossyColors.glassDivider),
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Total Tx: ',
                                    style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                  ),
                                  Flexible(
                                    child: Text(
                                      status.traffic.formattedTx,
                                      style: const TextStyle(
                                        color: GlossyColors.textPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (status.network.gateway.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                'Gateway: ${status.network.gateway}',
                                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                'Protocol: ${status.network.protocol}',
                                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Wi-Fi Radios Card
                GlossyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.wifi, color: GlossyColors.primaryBlue, size: 18),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Wireless Radios',
                                    style: TextStyle(
                                      color: GlossyColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          GlossyBadge(
                            label: '${status.wireless.totalConnectedClients} Clients',
                            dotColor: GlossyColors.emeraldMint,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _buildRadioTile(
                              band: '2.4 GHz',
                              ssid: status.wireless.radio2g.ssid,
                              channel: status.wireless.radio2g.channel,
                              powerDbm: status.wireless.radio2g.txpowerDbm,
                              clients: status.wireless.radio2g.connectedClients,
                              enabled: status.wireless.radio2g.enabled,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildRadioTile(
                              band: '5.0 GHz',
                              ssid: status.wireless.radio5g.ssid,
                              channel: status.wireless.radio5g.channel,
                              powerDbm: status.wireless.radio5g.txpowerDbm,
                              clients: status.wireless.radio5g.connectedClients,
                              enabled: status.wireless.radio5g.enabled,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Connected Clients Summary Card
                GlossyCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.devices, color: GlossyColors.primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                'Connected Devices (${status.clients.length})',
                                style: const TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (status.clients.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No active client devices detected.',
                            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: status.clients.length > 5 ? 5 : status.clients.length,
                          separatorBuilder: (_, _) => const Divider(color: GlossyColors.glassDivider),
                          itemBuilder: (ctx, idx) {
                            final client = status.clients[idx];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      client.connectionType.contains('5GHz')
                                          ? Icons.wifi_sharp
                                          : Icons.phone_android,
                                      size: 18,
                                      color: GlossyColors.lightBlue,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          client.hostname,
                                          style: const TextStyle(
                                            color: GlossyColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '${client.ip} • ${client.connectionType}',
                                          style: const TextStyle(
                                            color: GlossyColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${client.signalDbm} dBm',
                                    style: TextStyle(
                                      color: client.signalDbm > -65
                                          ? GlossyColors.emeraldMint
                                          : GlossyColors.amberWarm,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      if (onNavigateToTab != null) ...[
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => onNavigateToTab!(1),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Manage All ${status.clients.length} Devices',
                                  style: const TextStyle(
                                    color: GlossyColors.lightBlue,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded, size: 14, color: GlossyColors.lightBlue),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadioTile({
    required String band,
    required String ssid,
    required int channel,
    required int powerDbm,
    required int clients,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                band,
                style: const TextStyle(
                  color: GlossyColors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: enabled ? GlossyColors.emeraldMint : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ssid,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            'Ch $channel • $powerDbm dBm • $clients dev',
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
