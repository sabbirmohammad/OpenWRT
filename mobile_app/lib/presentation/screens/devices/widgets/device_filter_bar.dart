import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import 'device_filter_dropdown.dart';

class DeviceFilterBar extends StatelessWidget {
  final String searchQuery;
  final String selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterSelected;
  final List<ClientInfo> allClients;

  const DeviceFilterBar({
    super.key,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterSelected,
    required this.allClients,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
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
                onChanged: onSearchChanged,
                style: const TextStyle(
                  color: GlossyColors.textPrimary,
                  fontSize: 13,
                ),
                decoration: InputDecoration(
                  hintText: 'Search device, IP, MAC...',
                  hintStyle: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                  prefixIcon: const Icon(Icons.search, color: GlossyColors.textSecondary, size: 18),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: GlossyColors.textMuted),
                          onPressed: () => onSearchChanged(''),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          DeviceFilterDropdown(
            selectedFilter: selectedFilter,
            onFilterSelected: onFilterSelected,
            allClients: allClients,
          ),
        ],
      ),
    );
  }
}
