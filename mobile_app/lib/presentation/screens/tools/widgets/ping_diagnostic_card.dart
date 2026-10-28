import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';
import '../../../widgets/glossy_input.dart';

class PingDiagnosticCard extends StatefulWidget {
  final RouterController controller;

  const PingDiagnosticCard({super.key, required this.controller});

  @override
  State<PingDiagnosticCard> createState() => _PingDiagnosticCardState();
}

class _PingDiagnosticCardState extends State<PingDiagnosticCard> {
  late final TextEditingController _pingTargetController;
  bool _isPinging = false;
  String? _pingOutput;

  @override
  void initState() {
    super.initState();
    _pingTargetController = TextEditingController(text: '1.1.1.1');
  }

  @override
  void dispose() {
    _pingTargetController.dispose();
    super.dispose();
  }

  Future<void> _runPing() async {
    final target = _pingTargetController.text.trim();
    if (target.isEmpty) return;

    if (!InputValidators.isSafeHost(target)) {
      AppFeedback.showError(context, 'Invalid hostname or IP address format.');
      return;
    }

    setState(() {
      _isPinging = true;
      _pingOutput = null;
    });

    try {
      final res = await widget.controller.executeAction('raw_cmd', {
        'value': 'ping -c 4 $target',
      });
      final output = res['simulatedOutput'] as String? ??
          res['output'] as String? ??
          res['message'] as String? ??
          'Ping completed successfully for $target.';
      if (mounted) setState(() => _pingOutput = output);
    } catch (e) {
      if (mounted) setState(() => _pingOutput = 'Ping failed: $e');
    } finally {
      if (mounted) setState(() => _isPinging = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.speed_rounded, color: GlossyColors.lightBlue, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Network Ping Diagnostic',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(
                label: 'ICMP Utility',
                showDot: false,
                textColor: GlossyColors.lightBlue,
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Test ICMP round-trip latency and packet loss to any IP or domain.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _buildPresetChip('1.1.1.1 (Cloudflare)', '1.1.1.1'),
              _buildPresetChip('8.8.8.8 (Google)', '8.8.8.8'),
              _buildPresetChip(widget.controller.routerIp, widget.controller.routerIp),
            ],
          ),
          const SizedBox(height: 12),
          GlossyInput(
            controller: _pingTargetController,
            label: 'Target Host / IP',
            hint: '1.1.1.1',
            prefixIcon: Icons.dns_outlined,
            suffixIcon: _pingTargetController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: GlossyColors.textMuted, size: 18),
                    onPressed: () => setState(() => _pingTargetController.clear()),
                  )
                : null,
          ),
          const SizedBox(height: 14),
          GlossyButton(
            label: 'Run Ping Diagnostic',
            icon: Icons.play_arrow_rounded,
            style: GlossyButtonStyle.primary,
            isLoading: _isPinging,
            onPressed: _runPing,
          ),
          if (_pingOutput != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'ICMP Console Output',
                        style: TextStyle(
                          color: GlossyColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.copy_rounded, color: GlossyColors.textSecondary, size: 16),
                        onPressed: () => ClipboardHelper.copy(context, _pingOutput!, 'Ping output'),
                        tooltip: 'Copy output',
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    _pingOutput!,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontFamily: 'monospace',
                      fontSize: 11.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetChip(String label, String host) {
    final isSelected = _pingTargetController.text == host;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => setState(() => _pingTargetController.text = host),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? GlossyColors.primaryBlue.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? GlossyColors.lightBlue.withValues(alpha: 0.5) : GlossyColors.glassBorderLight,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? GlossyColors.lightBlue : GlossyColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
