import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_card.dart';

class SystemLogsCard extends StatefulWidget {
  final RouterController controller;

  const SystemLogsCard({super.key, required this.controller});

  @override
  State<SystemLogsCard> createState() => _SystemLogsCardState();
}

class _SystemLogsCardState extends State<SystemLogsCard> {
  bool _isBackingUp = false;
  bool _isLoadingLogs = false;
  String _selectedLogType = 'dmesg';
  String? _logOutput;

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoadingLogs = true;
      _logOutput = null;
    });

    try {
      final cmd = _selectedLogType == 'dmesg' ? 'dmesg' : 'logread';
      final res = await widget.controller.executeAction('raw_cmd', {'value': cmd});
      final output = res['simulatedOutput'] as String? ??
          res['output'] as String? ??
          'No log buffer returned by router.';
      if (mounted) setState(() => _logOutput = output);
    } catch (e) {
      if (mounted) setState(() => _logOutput = 'Failed to fetch logs: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLogs = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final res = await widget.controller.executeAction('backup_config');
      final msg = res['message'] as String? ??
          'Configuration archive /tmp/backup-OpenWrt-c6.tar.gz generated successfully.';
      if (mounted) AppFeedback.showSuccess(context, msg);
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Backup failed: $e');
    } finally {
      if (mounted) setState(() => _isBackingUp = false);
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
              Icon(Icons.terminal_rounded, color: GlossyColors.amberWarm, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Diagnostics & Logs',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GlossyBadge(label: 'OpenWrt', showDot: false, textColor: GlossyColors.amberWarm),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Inspect kernel ring buffer, system logs, or generate router configuration archive.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildLogTypeSelector('dmesg', 'Kernel (dmesg)', Icons.developer_board_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLogTypeSelector('logread', 'System (logread)', Icons.receipt_long_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GlossyButton(
                  label: 'Inspect Logs',
                  icon: Icons.terminal_rounded,
                  style: GlossyButtonStyle.secondary,
                  isLoading: _isLoadingLogs,
                  onPressed: _fetchLogs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GlossyButton(
                  label: 'Backup Config',
                  icon: Icons.archive_outlined,
                  style: GlossyButtonStyle.secondary,
                  isLoading: _isBackingUp,
                  onPressed: _createBackup,
                ),
              ),
            ],
          ),
          if (_logOutput != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 280),
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
                      Text(
                        '$_selectedLogType Output',
                        style: const TextStyle(
                          color: GlossyColors.textMuted,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.copy_rounded, color: GlossyColors.textSecondary, size: 16),
                            onPressed: () => ClipboardHelper.copy(context, _logOutput!, '$_selectedLogType log'),
                            tooltip: 'Copy log',
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(Icons.close_rounded, color: GlossyColors.textMuted, size: 16),
                            onPressed: () => setState(() => _logOutput = null),
                            tooltip: 'Clear view',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: SingleChildScrollView(
                      child: SelectableText(
                        _logOutput!,
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontFamily: 'monospace',
                          fontSize: 11,
                          height: 1.35,
                        ),
                      ),
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

  Widget _buildLogTypeSelector(String value, String label, IconData icon) {
    final isSelected = _selectedLogType == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _selectedLogType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? GlossyColors.amberWarm.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? GlossyColors.amberWarm.withValues(alpha: 0.4) : GlossyColors.glassBorderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? GlossyColors.amberWarm : GlossyColors.textMuted),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? GlossyColors.textPrimary : GlossyColors.textSecondary,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
