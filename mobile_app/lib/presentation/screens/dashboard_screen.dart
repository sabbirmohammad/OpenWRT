import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import 'dashboard/widgets/connected_devices_summary_card.dart';
import 'dashboard/widgets/hardware_vitals_card.dart';
import 'dashboard/widgets/internet_wan_card.dart';
import 'dashboard/widgets/offline_banner_card.dart';
import 'dashboard/widgets/wireless_overview_card.dart';

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
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GlossyBadge(
              label: isConnected
                  ? (latency >= 0 ? '${latency}ms' : 'Connected')
                  : (controller.connectionState == RouterConnectionState.connecting
                      ? 'Connecting'
                      : 'Offline'),
              dotColor: isConnected ? _resolveLatencyColor(latency) : GlossyColors.roseCoral,
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
              if (!isConnected) ...[
                OfflineBannerCard(
                  controller: controller,
                  onNavigateToTab: onNavigateToTab,
                ),
                const SizedBox(height: 16),
              ],
              if (status != null) ...[
                HardwareVitalsCard(status: status),
                const SizedBox(height: 14),
                InternetWanCard(status: status, controller: controller),
                const SizedBox(height: 14),
                WirelessOverviewCard(status: status),
                const SizedBox(height: 14),
                ConnectedDevicesSummaryCard(
                  clients: status.clients,
                  onNavigateToTab: onNavigateToTab,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
