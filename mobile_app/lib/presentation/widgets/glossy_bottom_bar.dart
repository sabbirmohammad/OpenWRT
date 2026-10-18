import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';

class GlossyBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final int? badgeCount;

  const GlossyBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badgeCount,
  });
}

class GlossyBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int clientCount;

  const GlossyBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.clientCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      const GlossyBottomBarItem(
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard_rounded,
        label: 'Dashboard',
      ),
      GlossyBottomBarItem(
        icon: Icons.devices_outlined,
        activeIcon: Icons.devices_rounded,
        label: 'Devices',
        badgeCount: clientCount > 0 ? clientCount : null,
      ),
      const GlossyBottomBarItem(
        icon: Icons.wifi_outlined,
        activeIcon: Icons.wifi_rounded,
        label: 'Wireless',
      ),
      const GlossyBottomBarItem(
        icon: Icons.hub_outlined,
        activeIcon: Icons.hub_rounded,
        label: 'Network',
      ),
      const GlossyBottomBarItem(
        icon: Icons.menu_rounded,
        activeIcon: Icons.menu_open_rounded,
        label: 'Menu',
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: GlossyColors.backgroundSecondary.withValues(alpha: 0.88),
        border: const Border(
          top: BorderSide(
            color: GlossyColors.glassBorderLight,
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _BottomBarButton(
                  item: item,
                  isSelected: isSelected,
                  onTap: () {
                    if (!isSelected) {
                      HapticFeedback.selectionClick();
                      onTap(index);
                    }
                  },
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomBarButton extends StatelessWidget {
  final GlossyBottomBarItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomBarButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: GlossyColors.primaryBlue.withValues(alpha: 0.2),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? GlossyColors.primaryBlue.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? GlossyColors.lightBlue.withValues(alpha: 0.35)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                    size: 22,
                    color: isSelected
                        ? GlossyColors.lightBlue
                        : GlossyColors.textMuted,
                  ),
                  if (item.badgeCount != null)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? GlossyColors.lightBlue
                              : GlossyColors.emeraldMint,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: (isSelected
                                      ? GlossyColors.lightBlue
                                      : GlossyColors.emeraldMint)
                                  .withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected
                      ? GlossyColors.textPrimary
                      : GlossyColors.textMuted,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
