import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';

class SecurityWanLockCard extends StatelessWidget {
  final bool isWanLockActive;
  final bool isTogglingWanLock;
  final VoidCallback onToggle;

  const SecurityWanLockCard({
    super.key,
    required this.isWanLockActive,
    required this.isTogglingWanLock,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: (isWanLockActive ? GlossyColors.emeraldMint : Colors.white).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.lock_person_rounded,
                  color: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Remote WAN Access Lockdown',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              GlossyBadge(
                label: isWanLockActive ? 'Locked' : 'Exposed',
                dotColor: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Blocks public WAN connections to router LuCI web UI (80/443) and SSH console (22). Management strictly confined to private LAN.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  isWanLockActive ? 'WAN Port 80/443/22 Dropped' : 'WAN management ports open',
                  style: TextStyle(
                    color: isWanLockActive ? GlossyColors.emeraldMint : GlossyColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: isWanLockActive,
                activeThumbColor: GlossyColors.emeraldMint,
                activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                onChanged: isTogglingWanLock ? null : (_) => onToggle(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
