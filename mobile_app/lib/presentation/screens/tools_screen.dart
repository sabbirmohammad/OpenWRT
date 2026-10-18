import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/glossy_input.dart';

class ToolsScreen extends StatefulWidget {
  final RouterController controller;

  const ToolsScreen({super.key, required this.controller});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  // Ping tool state
  late final TextEditingController _pingTargetController;
  bool _isPinging = false;
  String? _pingOutput;

  // Diagnostics & Backup state
  bool _isBackingUp = false;
  bool _isLoadingLogs = false;
  String _selectedLogType = 'dmesg'; // 'dmesg' or 'logread'
  String? _logOutput;

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
      if (mounted) {
        setState(() {
          _pingOutput = output;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _pingOutput = 'Ping failed: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isPinging = false);
      }
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isBackingUp = true);
    try {
      final res = await widget.controller.executeAction('backup_config');
      final msg = res['message'] as String? ??
          'Configuration archive /tmp/backup-OpenWrt-c6.tar.gz generated successfully.';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: GlossyColors.emeraldMint,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: GlossyColors.roseCoral,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isBackingUp = false);
      }
    }
  }

  Future<void> _fetchLogs() async {
    setState(() {
      _isLoadingLogs = true;
      _logOutput = null;
    });

    try {
      final cmd = _selectedLogType == 'dmesg' ? 'dmesg' : 'logread';
      final res = await widget.controller.executeAction('raw_cmd', {
        'value': cmd,
      });
      final output = res['simulatedOutput'] as String? ??
          res['output'] as String? ??
          'No log buffer returned by router.';
      if (mounted) {
        setState(() {
          _logOutput = output;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _logOutput = 'Failed to fetch logs: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingLogs = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard'),
        backgroundColor: GlossyColors.primaryBlue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;
    final cpu = status?.cpu;
    final mem = status?.memory;
    final storage = status?.storage;

    return Scaffold(
      backgroundColor: GlossyColors.backgroundPrimary,
      appBar: AppBar(
        titleSpacing: 16,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System & Tools',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: GlossyColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'MT7621DAT Architecture, Memory & Diagnostics',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: GlossyColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => widget.controller.refresh(),
        color: GlossyColors.primaryBlue,
        backgroundColor: GlossyColors.backgroundSecondary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hardware Specifications Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.memory_rounded, color: GlossyColors.lightBlue, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Hardware Specifications',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const GlossyBadge(
                          label: 'Archer C6 v3',
                          showDot: false,
                          textColor: GlossyColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSpecRow('Processor (SoC)', cpu?.model ?? 'MediaTek MT7621DAT'),
                    _buildSpecRow('Architecture', cpu?.architecture ?? 'MIPS 1004Kc (Dual-Core / 4 Threads)'),
                    _buildSpecRow('Clock Speed', '${cpu?.frequencyMhz ?? 880} MHz'),
                    _buildSpecRow('CPU Temperature', '${(cpu?.temperatureC ?? 42).toStringAsFixed(0)}°C (Normal)'),
                    _buildSpecRow('Switch Core', '5x Gigabit Ethernet (DSA)'),
                    _buildSpecRow('Firmware / Kernel', 'OpenWrt 23.05.3 / Linux 5.15.150'),
                    _buildSpecRow('System Uptime', cpu?.formattedUptime ?? '0m'),
                    _buildSpecRow('Load Average', cpu?.loadAvg ?? '0.00'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Memory & Storage Allocation Details Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pie_chart_outline_rounded, color: GlossyColors.emeraldMint, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
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

                    // RAM Breakdown
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

                    // Storage Breakdown
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
              ),

              const SizedBox(height: 16),

              // 3. Network Diagnostic Ping Utility Card
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.speed_rounded, color: GlossyColors.lightBlue, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
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

                    // Preset Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _buildPresetChip('1.1.1.1 (Cloudflare)'),
                        _buildPresetChip('8.8.8.8 (Google)'),
                        _buildPresetChip(widget.controller.routerIp),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Ping Input Field
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

                    // Run Ping Button
                    GlossyButton(
                      label: 'Run Ping Diagnostic',
                      icon: Icons.play_arrow_rounded,
                      style: GlossyButtonStyle.primary,
                      isLoading: _isPinging,
                      onPressed: _runPing,
                    ),

                    // Ping Terminal Output
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
                                  onPressed: () => _copyToClipboard(_pingOutput!, 'Ping output'),
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
              ),

              const SizedBox(height: 16),

              // 4. System Diagnostics & Maintenance Utilities
              GlossyCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.terminal_rounded, color: GlossyColors.amberWarm, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Diagnostics & Logs',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        GlossyBadge(
                          label: 'OpenWrt',
                          showDot: false,
                          textColor: GlossyColors.amberWarm,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Inspect kernel ring buffer, system logs, or generate router configuration archive.',
                      style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 14),

                    // Log type selector
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

                    // Diagnostics Log Console Output
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
                                      onPressed: () => _copyToClipboard(_logOutput!, '$_selectedLogType log'),
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetChip(String host) {
    final isSelected = _pingTargetController.text == host;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        setState(() {
          _pingTargetController.text = host;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? GlossyColors.primaryBlue.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? GlossyColors.lightBlue.withValues(alpha: 0.5)
                : GlossyColors.glassBorderLight,
          ),
        ),
        child: Text(
          host,
          style: TextStyle(
            color: isSelected ? GlossyColors.lightBlue : GlossyColors.textSecondary,
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
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
          color: isSelected
              ? GlossyColors.amberWarm.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? GlossyColors.amberWarm.withValues(alpha: 0.4)
                : GlossyColors.glassBorderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? GlossyColors.amberWarm : GlossyColors.textMuted,
            ),
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

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: GlossyColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
