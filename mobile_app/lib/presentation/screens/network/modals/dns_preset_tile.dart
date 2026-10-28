import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import 'dns_preset_model.dart';

class DnsPresetTile extends StatelessWidget {
  final DnsPreset preset;
  final bool isSelected;
  final bool isLiveActive;
  final VoidCallback onTap;

  const DnsPresetTile({
    super.key,
    required this.preset,
    required this.isSelected,
    required this.isLiveActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pri = preset.primary;
    final sec = preset.secondary;
    final ipText = preset.id == 'auto'
        ? 'ISP Default'
        : (preset.id == 'custom' ? 'Custom IPs' : '$pri${sec.isNotEmpty ? ", $sec" : ""}');

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? GlossyColors.primaryBlue.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? GlossyColors.primaryBlue : GlossyColors.glassBorderLight,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Icon(preset.icon, color: preset.color, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preset.name,
                            style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLiveActive) ...[
                          const SizedBox(width: 6),
                          const GlossyBadge(label: 'Active', dotColor: GlossyColors.emeraldMint),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(ipText, style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 11, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(preset.desc, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? GlossyColors.primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? GlossyColors.primaryBlue : GlossyColors.textMuted.withValues(alpha: 0.5),
                    width: 2,
                  ),
                ),
                child: isSelected ? const Icon(Icons.check, size: 13, color: Colors.white) : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
