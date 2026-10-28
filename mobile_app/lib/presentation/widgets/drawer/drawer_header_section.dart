import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';
import '../../controllers/router_controller.dart';
import '../glossy_badge.dart';

class DrawerHeaderSection extends StatelessWidget {
  final RouterController controller;

  const DrawerHeaderSection({super.key, required this.controller});

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
    final uptime = status?.cpu.formattedUptime ?? '0m';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [GlossyColors.primaryBlue, GlossyColors.lightBlue],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: GlossyColors.primaryBlue.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.router_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ArcherGuard C6',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.routerIp,
                      style: const TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, color: GlossyColors.textMuted, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Close Menu',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GlossyBadge(
                label: isConnected
                    ? (latency >= 0 ? '${latency}ms Ping' : 'Online')
                    : 'Offline',
                dotColor: isConnected
                    ? _resolveLatencyColor(latency)
                    : GlossyColors.roseCoral,
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GlossyColors.glassBorderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 11, color: GlossyColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Up $uptime',
                      style: const TextStyle(
                        color: GlossyColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
