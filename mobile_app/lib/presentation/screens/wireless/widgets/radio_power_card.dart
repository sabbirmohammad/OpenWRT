import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';

class RadioPowerCard extends StatelessWidget {
  final String band;
  final String chipset;
  final String ssid;
  final int channel;
  final String channelWidth;
  final int clients;
  final bool enabled;
  final double txPower;
  final ValueChanged<double> onTxPowerChanged;
  final VoidCallback onSaveTxPower;
  final bool isUpdatingTx;

  const RadioPowerCard({
    super.key,
    required this.band,
    required this.chipset,
    required this.ssid,
    required this.channel,
    required this.channelWidth,
    required this.clients,
    required this.enabled,
    required this.txPower,
    required this.onTxPowerChanged,
    required this.onSaveTxPower,
    this.isUpdatingTx = false,
  });

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    band,
                    style: const TextStyle(
                      color: GlossyColors.lightBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    chipset,
                    style: const TextStyle(
                      color: GlossyColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              GlossyBadge(
                label: enabled ? '$clients Connected' : 'Radio Off',
                dotColor: enabled ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _buildInfoItem('SSID', ssid)),
              Expanded(child: _buildInfoItem('Channel', 'Ch $channel ($channelWidth)')),
              Expanded(child: _buildInfoItem('Tx Power', '${txPower.round()} dBm')),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: GlossyColors.glassDivider),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Transmit Power (TX Power)',
                style: TextStyle(
                  color: GlossyColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${txPower.round()} dBm (~${(txPower > 20 ? 100 : 70)}mW)',
                style: const TextStyle(
                  color: GlossyColors.lightBlue,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GlossyColors.lightBlue,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: GlossyColors.primaryBlue,
              overlayColor: GlossyColors.primaryBlue.withValues(alpha: 0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: txPower.clamp(10.0, 24.0),
              min: 10.0,
              max: 24.0,
              divisions: 14,
              onChanged: onTxPowerChanged,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GlossyButton(
              label: 'Apply ${txPower.round()} dBm',
              icon: Icons.check_circle_outline,
              style: GlossyButtonStyle.secondary,
              height: 36,
              isLoading: isUpdatingTx,
              onPressed: onSaveTxPower,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: GlossyColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: GlossyColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
