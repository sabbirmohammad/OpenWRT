import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';

/// Graphical tile displaying Load Average with 3 distinct horizontal capacity bars.
class LoadAverageTile extends StatelessWidget {
  final String loadAvgString;

  const LoadAverageTile({
    super.key,
    required this.loadAvgString,
  });

  List<double> _parseLoads() {
    final parts = loadAvgString.split(',').map((s) => double.tryParse(s.trim()) ?? 0.0).toList();
    while (parts.length < 3) {
      parts.add(parts.isNotEmpty ? parts.last : 0.0);
    }
    return parts.take(3).toList();
  }

  Color _colorForLoad(double load) {
    if (load < 1.0) return GlossyColors.emeraldMint;
    if (load < 2.0) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  @override
  Widget build(BuildContext context) {
    final loads = _parseLoads();
    final primaryLoad = loads[0];
    final color = _colorForLoad(primaryLoad);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.speed_rounded, size: 14, color: color),
                    const SizedBox(width: 4),
                    const Flexible(
                      child: Text(
                        'LOAD AVG',
                        style: TextStyle(
                          color: GlossyColors.textMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'MAX 2.0',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.8),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildLoadBar(label: '1m', load: loads[0]),
          const SizedBox(height: 5),
          _buildLoadBar(label: '5m', load: loads[1]),
          const SizedBox(height: 5),
          _buildLoadBar(label: '15m', load: loads[2]),
        ],
      ),
    );
  }

  Widget _buildLoadBar({required String label, required double load}) {
    final color = _colorForLoad(load);
    final ratio = (load / 2.0).clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 22,
          child: Text(
            label,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 28,
          child: Text(
            load.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: TextStyle(
              color: color,
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ],
    );
  }
}
