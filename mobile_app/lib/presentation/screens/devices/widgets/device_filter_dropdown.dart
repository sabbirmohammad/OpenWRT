import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';

class DeviceFilterDropdown extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final List<ClientInfo> allClients;

  const DeviceFilterDropdown({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.allClients,
  });

  @override
  Widget build(BuildContext context) {
    final countAll = allClients.length;
    final count5G = allClients.where((c) => c.connectionType.contains('5GHz')).length;
    final count24G = allClients.where((c) => c.connectionType.contains('2.4GHz')).length;
    final countLan = allClients.where((c) => c.connectionType.contains('LAN')).length;
    final countIsolated = allClients.where((c) => c.isIsolated).length;
    final countBlocked = allClients.where((c) => c.blocked).length;

    int currentFilterCount;
    switch (selectedFilter) {
      case '5.0 GHz': currentFilterCount = count5G; break;
      case '2.4 GHz': currentFilterCount = count24G; break;
      case 'LAN': currentFilterCount = countLan; break;
      case 'Isolated': currentFilterCount = countIsolated; break;
      case 'Blocked': currentFilterCount = countBlocked; break;
      default: currentFilterCount = countAll;
    }

    final isIsolatedFilter = selectedFilter == 'Isolated';
    final isBlockedFilter = selectedFilter == 'Blocked';

    return PopupMenuButton<String>(
      initialValue: selectedFilter,
      tooltip: 'Filter devices',
      color: GlossyColors.backgroundElevated,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: GlossyColors.glassBorderLight),
      ),
      onSelected: onFilterSelected,
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
          color: selectedFilter != 'All'
              ? (isIsolatedFilter
                  ? GlossyColors.isolatedAccent.withValues(alpha: 0.18)
                  : (isBlockedFilter
                      ? GlossyColors.roseCoral.withValues(alpha: 0.18)
                      : GlossyColors.primaryBlue.withValues(alpha: 0.18)))
              : GlossyColors.glassSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedFilter != 'All'
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
              selectedFilter == 'All'
                  ? Icons.tune_rounded
                  : (isBlockedFilter
                      ? Icons.block_rounded
                      : (isIsolatedFilter ? Icons.wifi_lock_rounded : Icons.wifi_rounded)),
              size: 16,
              color: selectedFilter == 'All'
                  ? GlossyColors.textSecondary
                  : (isIsolatedFilter
                      ? GlossyColors.isolatedLight
                      : (isBlockedFilter ? GlossyColors.roseCoral : GlossyColors.lightBlue)),
            ),
            const SizedBox(width: 6),
            Text(
              selectedFilter == 'All' ? 'Filter' : selectedFilter,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selectedFilter != 'All' ? Colors.white : GlossyColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: selectedFilter != 'All'
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
                  color: selectedFilter != 'All' ? Colors.white : GlossyColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: GlossyColors.textSecondary),
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
    final isSelected = selectedFilter == value;
    final itemColor = isDanger
        ? GlossyColors.roseCoral
        : (isIsolated
            ? GlossyColors.isolatedLight
            : (isSelected ? GlossyColors.lightBlue : GlossyColors.textSecondary));

    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 16, color: itemColor),
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
              color: isIsolated ? GlossyColors.isolatedLight : (isDanger ? GlossyColors.roseCoral : GlossyColors.lightBlue),
            ),
          ],
        ],
      ),
    );
  }
}
