import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import 'tools/widgets/hardware_specs_card.dart';
import 'tools/widgets/memory_storage_card.dart';
import 'tools/widgets/ping_diagnostic_card.dart';
import 'tools/widgets/system_logs_card.dart';

class ToolsScreen extends StatefulWidget {
  final RouterController controller;

  const ToolsScreen({super.key, required this.controller});

  @override
  State<ToolsScreen> createState() => _ToolsScreenState();
}

class _ToolsScreenState extends State<ToolsScreen> {
  @override
  Widget build(BuildContext context) {
    final status = widget.controller.status;

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
              HardwareSpecsCard(cpu: status?.cpu),
              const SizedBox(height: 16),
              MemoryStorageCard(mem: status?.memory, storage: status?.storage),
              const SizedBox(height: 16),
              PingDiagnosticCard(controller: widget.controller),
              const SizedBox(height: 16),
              SystemLogsCard(controller: widget.controller),
            ],
          ),
        ),
      ),
    );
  }
}
