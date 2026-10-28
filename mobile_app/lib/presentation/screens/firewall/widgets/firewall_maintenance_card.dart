import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';

class FirewallMaintenanceCard extends StatelessWidget {
  final bool isReloading;
  final bool isRestarting;
  final bool isFlushing;
  final bool isResetting;
  final VoidCallback onReload;
  final VoidCallback onRestart;
  final VoidCallback onFlush;
  final VoidCallback onReset;

  const FirewallMaintenanceCard({
    super.key,
    required this.isReloading,
    required this.isRestarting,
    required this.isFlushing,
    required this.isResetting,
    required this.onReload,
    required this.onRestart,
    required this.onFlush,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Firewall Maintenance & Control',
            style: TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Apply updated nftables rules, restart the packet engine, or restore factory defaults without rebooting the router OS.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Reload Rules',
                  icon: Icons.refresh_rounded,
                  style: GlossyButtonStyle.secondary,
                  isLoading: isReloading,
                  onPressed: onReload,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Restart Subsystem',
                  icon: Icons.restart_alt_rounded,
                  style: GlossyButtonStyle.primary,
                  isLoading: isRestarting,
                  onPressed: onRestart,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Flush Conntrack',
                  icon: Icons.cleaning_services_rounded,
                  style: GlossyButtonStyle.secondary,
                  isLoading: isFlushing,
                  onPressed: onFlush,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Factory Defaults',
                  icon: Icons.restore_rounded,
                  style: GlossyButtonStyle.danger,
                  isLoading: isResetting,
                  onPressed: onReset,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
