import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';
import '../../../widgets/glossy_badge.dart';

class SsidCardBadgesRow extends StatelessWidget {
  final SsidInfo ssid;
  final bool is5g;
  final bool isTopTraffic;
  final bool isGuestOrIsolated;
  final bool isToggling;
  final ValueChanged<bool> onToggle;

  const SsidCardBadgesRow({
    super.key,
    required this.ssid,
    required this.is5g,
    required this.isTopTraffic,
    required this.isGuestOrIsolated,
    required this.isToggling,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: (is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue).withValues(alpha: 0.3)),
          ),
          child: Text(
            ssid.band,
            style: TextStyle(color: is5g ? GlossyColors.lightBlue : GlossyColors.skyBlue, fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(width: 8),
        if (isTopTraffic) ...[
          const GlossyBadge(label: 'Top Traffic', dotColor: GlossyColors.amberWarm),
          const SizedBox(width: 8),
        ],
        if (isGuestOrIsolated) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: GlossyColors.isolatedAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GlossyColors.isolatedAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.shield_outlined, color: GlossyColors.isolatedLight, size: 12),
                SizedBox(width: 4),
                Text('Isolated Guest', style: TextStyle(color: GlossyColors.isolatedLight, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (ssid.isHidden) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: GlossyColors.glassBorderLight),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.visibility_off_outlined, color: GlossyColors.textMuted, size: 12),
                SizedBox(width: 4),
                Text('Hidden', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
        const Spacer(),
        GlossyBadge(
          label: ssid.enabled ? 'Active' : 'Inactive',
          dotColor: ssid.enabled ? GlossyColors.emeraldMint : GlossyColors.textMuted,
        ),
        const SizedBox(width: 8),
        if (isToggling)
          const SizedBox(
            width: 36,
            height: 24,
            child: Center(
              child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: GlossyColors.primaryBlue)),
            ),
          )
        else
          Switch.adaptive(
            value: ssid.enabled,
            activeThumbColor: GlossyColors.emeraldMint,
            activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
            onChanged: onToggle,
          ),
      ],
    );
  }
}
