import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/memory_info.dart';
import '../../../../models/storage_info.dart';
import '../../../widgets/glossy_card.dart';

class MemoryStorageCard extends StatelessWidget {
  final MemoryInfo? mem;
  final StorageInfo? storage;

  const MemoryStorageCard({super.key, this.mem, this.storage});

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.pie_chart_outline_rounded, color: GlossyColors.emeraldMint, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Memory & Storage Allocation',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'RAM Capacity (DDR3)',
                  style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${mem?.formattedUsedMb ?? "52.2 MB"} / ${mem?.formattedTotalMb ?? "128 MB"} (${(mem?.usagePercent ?? 43.0).toStringAsFixed(0)}%)',
                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ((mem?.usagePercent ?? 43.0) / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(GlossyColors.emeraldMint),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'Free: ${(((mem?.freeKb ?? 45644)) / 1024).toStringAsFixed(1)} MB',
                  style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Cached: ${(((mem?.cachedKb ?? 20928)) / 1024).toStringAsFixed(1)} MB',
                  style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Available: ${(((mem?.availableKb ?? 32200)) / 1024).toStringAsFixed(1)} MB',
                  style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const Divider(color: GlossyColors.glassBorderDark, height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  storage?.device ?? '16MB SPI NOR Flash',
                  style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${storage?.formattedUsedMb ?? "2.4 MB"} / ${storage?.formattedTotalMb ?? "16 MB"} (${(storage?.usagePercent ?? 30.0).toStringAsFixed(0)}%)',
                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ((storage?.usagePercent ?? 30.0) / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: const AlwaysStoppedAnimation<Color>(GlossyColors.lightBlue),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Available Overlay: ${(((storage?.availableKb ?? 5408)) / 1024).toStringAsFixed(1)} MB',
            style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
