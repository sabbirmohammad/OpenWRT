import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_card.dart';

class SecurityStealthCard extends StatelessWidget {
  final bool isStealth;
  final bool isTogglingStealth;
  final VoidCallback onToggle;

  const SecurityStealthCard({
    super.key,
    required this.isStealth,
    required this.isTogglingStealth,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isStealth ? GlossyColors.primaryBlue : Colors.white).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: (isStealth ? GlossyColors.lightBlue : GlossyColors.glassBorderLight),
              ),
            ),
            child: Icon(
              isStealth ? Icons.nightlight_round : Icons.lightbulb_outline,
              color: isStealth ? GlossyColors.lightBlue : GlossyColors.amberWarm,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stealth LED Night Mode',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isStealth ? 'Front LEDs turned OFF for physical stealth' : 'Normal LED activity lights ON',
                  style: TextStyle(
                    color: isStealth ? GlossyColors.lightBlue : GlossyColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isStealth,
            activeThumbColor: GlossyColors.lightBlue,
            activeTrackColor: GlossyColors.lightBlue.withValues(alpha: 0.3),
            onChanged: isTogglingStealth ? null : (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}
