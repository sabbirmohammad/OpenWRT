import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_button.dart';

class SqmTuneModal extends StatefulWidget {
  final NetworkInfo? network;
  final Function({required String qdisc, required int downloadKbit, required int uploadKbit}) onApply;

  const SqmTuneModal({
    super.key,
    required this.network,
    required this.onApply,
  });

  @override
  State<SqmTuneModal> createState() => _SqmTuneModalState();
}

class _SqmTuneModalState extends State<SqmTuneModal> {
  late double _dlMbps;
  late double _ulMbps;
  late String _qdisc;

  @override
  void initState() {
    super.initState();
    _dlMbps = widget.network != null ? widget.network!.sqmDownloadMbps : 95.0;
    _ulMbps = widget.network != null ? widget.network!.sqmUploadMbps : 20.0;
    _qdisc = widget.network?.sqmQdisc ?? 'cake';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: GlossyColors.lightBlue, size: 22),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Tune CAKE SQM Bandwidth',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: GlossyColors.textSecondary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Set strict ingress and egress limits below your line speed to eliminate bufferbloat and latency spikes.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Download Limit', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${_dlMbps.toStringAsFixed(1)} Mbps', style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GlossyColors.emeraldMint,
              thumbColor: GlossyColors.emeraldMint,
              inactiveTrackColor: Colors.white12,
            ),
            child: Slider(
              value: _dlMbps.clamp(5.0, 300.0),
              min: 5.0,
              max: 300.0,
              divisions: 59,
              onChanged: (val) => setState(() => _dlMbps = val),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Upload Limit', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
              Text('${_ulMbps.toStringAsFixed(1)} Mbps', style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w700)),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: GlossyColors.lightBlue,
              thumbColor: GlossyColors.lightBlue,
              inactiveTrackColor: Colors.white12,
            ),
            child: Slider(
              value: _ulMbps.clamp(2.0, 100.0),
              min: 2.0,
              max: 100.0,
              divisions: 49,
              onChanged: (val) => setState(() => _ulMbps = val),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Queuing Algorithm', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('CAKE (Modern)')),
                  selected: _qdisc == 'cake',
                  selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
                  onSelected: (sel) => setState(() => _qdisc = 'cake'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ChoiceChip(
                  label: const Center(child: Text('FQ_CoDel')),
                  selected: _qdisc == 'fq_codel',
                  selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
                  onSelected: (sel) => setState(() => _qdisc = 'fq_codel'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          GlossyButton(
            label: 'Apply SQM Tuning',
            icon: Icons.check_circle_outline,
            onPressed: () {
              Navigator.pop(context);
              widget.onApply(
                qdisc: _qdisc,
                downloadKbit: (_dlMbps * 1000).toInt(),
                uploadKbit: (_ulMbps * 1000).toInt(),
              );
            },
          ),
        ],
      ),
    );
  }
}
