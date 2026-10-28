import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';
import '../../../core/utils/app_feedback.dart';
import '../../controllers/router_controller.dart';

class DrawerQuickActions extends StatelessWidget {
  final RouterController controller;

  const DrawerQuickActions({super.key, required this.controller});

  void _confirmReboot(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlossyColors.backgroundSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: GlossyColors.glassBorderLight),
        ),
        title: const Text(
          'Reboot Router?',
          style: TextStyle(color: GlossyColors.textPrimary, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will restart your TP-Link Archer C6 router. Network connection will briefly disconnect for ~60 seconds.',
          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: GlossyColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GlossyColors.roseCoral,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.executeAction('reboot');
              AppFeedback.showSnackBar(
                context,
                message: 'Reboot command dispatched to router.',
                customColor: GlossyColors.primaryBlue,
                icon: Icons.restart_alt_rounded,
              );
            },
            child: const Text('Reboot Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _flushMemory(BuildContext context) async {
    try {
      await controller.executeAction('drop_caches');
      if (context.mounted) {
        AppFeedback.showSuccess(context, 'RAM buffers & cache cleared successfully.');
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Flush failed: $e');
      }
    }
  }

  Future<void> _toggleStealth(BuildContext context) async {
    final current = controller.status?.stealthLeds ?? false;
    try {
      await controller.executeAction('led_stealth', {
        'value': !current ? 'on' : 'off',
        'enabled': !current,
      });
      if (context.mounted) {
        AppFeedback.showSnackBar(
          context,
          message: !current ? 'Stealth LED Mode ON' : 'Stealth LED Mode OFF',
          customColor: GlossyColors.lightBlue,
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppFeedback.showError(context, 'Stealth toggle failed: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isStealth = controller.status?.stealthLeds ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Text(
            'QUICK ACTIONS',
            style: TextStyle(
              color: GlossyColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GlossyColors.glassBorderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isStealth ? GlossyColors.primaryBlue : Colors.white).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isStealth ? Icons.nightlight_round : Icons.lightbulb_outline,
                  color: isStealth ? GlossyColors.lightBlue : GlossyColors.amberWarm,
                  size: 19,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Stealth LED Mode', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Front lights toggle', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Switch.adaptive(
                value: isStealth,
                activeThumbColor: GlossyColors.lightBlue,
                activeTrackColor: GlossyColors.lightBlue.withValues(alpha: 0.3),
                onChanged: (_) => _toggleStealth(context),
              ),
            ],
          ),
        ),
        _buildActionTile(
          context: context,
          icon: Icons.cleaning_services_rounded,
          iconColor: GlossyColors.emeraldMint,
          title: 'Flush Memory',
          subtitle: 'Clear RAM drop_caches',
          onTap: () => _flushMemory(context),
        ),
        _buildActionTile(
          context: context,
          icon: Icons.restart_alt_rounded,
          iconColor: GlossyColors.roseCoral,
          title: 'Reboot Router',
          subtitle: 'Safe 60s cold restart',
          isDanger: true,
          onTap: () => _confirmReboot(context),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isDanger ? GlossyColors.roseCoral.withValues(alpha: 0.04) : Colors.white.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDanger ? GlossyColors.roseCoral.withValues(alpha: 0.25) : GlossyColors.glassBorderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: isDanger ? GlossyColors.roseCoral : GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: isDanger ? GlossyColors.roseCoral : GlossyColors.textMuted, size: 13),
            ],
          ),
        ),
      ),
    );
  }
}
