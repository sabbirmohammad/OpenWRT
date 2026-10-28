import 'package:flutter/material.dart';
import '../../../core/theme/glossy_colors.dart';

/// Graphical tile displaying Processor Clock Frequency with a dynamic speedometer meter.
class ClockFrequencyTile extends StatelessWidget {
  final int frequencyMhz;
  final int maxFrequencyMhz;

  const ClockFrequencyTile({
    super.key,
    required this.frequencyMhz,
    this.maxFrequencyMhz = 880,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = (frequencyMhz / maxFrequencyMhz).clamp(0.0, 1.0);

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.bolt_rounded, size: 14, color: GlossyColors.skyBlue),
                    SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'CLOCK SPEED',
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
              SizedBox(width: 4),
              Text(
                'MAX 880',
                style: TextStyle(
                  color: GlossyColors.skyBlue,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  '$frequencyMhz MHz',
                  style: const TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'Peak Turbo',
                style: TextStyle(
                  color: GlossyColors.skyBlue,
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
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
                    gradient: const LinearGradient(
                      colors: [GlossyColors.primaryBlue, GlossyColors.skyBlue],
                    ),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: [
                      BoxShadow(
                        color: GlossyColors.skyBlue.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0 MHz',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Flexible(
                child: Text(
                  '${(ratio * 100).toInt()}% Capacity',
                  style: const TextStyle(
                    color: GlossyColors.textSecondary,
                    fontSize: 7.5,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$maxFrequencyMhz MHz',
                style: TextStyle(
                  color: GlossyColors.textMuted.withValues(alpha: 0.7),
                  fontSize: 7.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
