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

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: GlossyColors.backgroundSecondary.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: GlossyColors.lightBlue.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: GlossyColors.lightBlue.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Stack(
                  children: [
                    // Top hairline specular highlight
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              GlossyColors.lightBlue.withValues(alpha: 0.6),
                              Colors.white.withValues(alpha: 0.4),
                              GlossyColors.lightBlue.withValues(alpha: 0.6),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
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
                  ],
                ),
              ),
            ),
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
        borderRadius: BorderRadius.circular(18),
        splashColor: GlossyColors.lightBlue.withValues(alpha: 0.25),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected
                ? GlossyColors.lightBlue.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected
                  ? GlossyColors.lightBlue.withValues(alpha: 0.32)
                  : Colors.transparent,
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 28,
                height: 28,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.12 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutBack,
                      child: Icon(
                        isSelected ? (item.activeIcon ?? item.icon) : item.icon,
                        size: 22,
                        color: isSelected
                            ? GlossyColors.lightBlue
                            : GlossyColors.textMuted,
                      ),
                    ),
                    if (item.badgeCount != null && item.badgeCount! > 0)
                      Positioned(
                        top: -4,
                        right: -10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                GlossyColors.emeraldMint,
                                GlossyColors.emeraldSoft,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: GlossyColors.backgroundSecondary,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: GlossyColors.emeraldMint.withValues(alpha: 0.5),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Text(
                            item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isSelected
                      ? GlossyColors.textPrimary
                      : GlossyColors.textMuted,
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: -0.2,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                height: 2.5,
                width: isSelected ? 14 : 0,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      GlossyColors.lightBlue,
                      GlossyColors.skyBlue,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
