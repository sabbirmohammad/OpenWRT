import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_input.dart';
import '../widgets/glossy_badge.dart';

class SettingsModal extends StatefulWidget {
  final RouterController controller;

  const SettingsModal({super.key, required this.controller});

  static void show(BuildContext context, RouterController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsModal(controller: controller),
    );
  }

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  late final TextEditingController _secretController;
  late bool _autoRefresh;

  bool _isTesting = false;
  String? _testMessage;
  Color _testColor = GlossyColors.textSecondary;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.controller.routerIp);
    _portController = TextEditingController(text: widget.controller.routerPort.toString());
    _secretController = TextEditingController(text: widget.controller.routerSecret);
    _autoRefresh = widget.controller.autoRefresh;
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    _secretController.dispose();
    super.dispose();
  }

  Future<void> _runTest() async {
    setState(() {
      _isTesting = true;
      _testMessage = null;
    });

    final port = int.tryParse(_portController.text.trim()) ?? 80;
    final res = await widget.controller.testConnection(
      ip: _ipController.text.trim(),
      port: port,
    );

    setState(() {
      _isTesting = false;
      if (res.isOnline) {
        _testMessage = 'Direct Connection OK (${res.latencyMs}ms latency)';
        _testColor = GlossyColors.emeraldMint;
      } else {
        _testMessage = res.error ?? 'Connection failed. Check Wi-Fi.';
        _testColor = GlossyColors.roseCoral;
      }
    });
  }

  Future<void> _saveAndClose() async {
    final port = int.tryParse(_portController.text.trim()) ?? 80;
    await widget.controller.updateSettings(
      ip: _ipController.text.trim(),
      port: port,
      secret: _secretController.text.trim(),
      autoRefresh: _autoRefresh,
    );
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            decoration: BoxDecoration(
              color: GlossyColors.backgroundSecondary.withValues(alpha: 0.92),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(
                color: GlossyColors.glassBorderLight,
                width: 1.0,
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle pill
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gateway Settings',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GlossyBadge(
                        label: 'Local Only',
                        icon: Icons.wifi,
                        dotColor: GlossyColors.primaryBlue,
                        showDot: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Direct communication with router over Wi-Fi/LAN.',
                    style: TextStyle(
                      color: GlossyColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Inputs
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: GlossyInput(
                          controller: _ipController,
                          label: 'Router IP / Gateway',
                          hint: '192.168.1.1',
                          prefixIcon: Icons.router_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1,
                        child: GlossyInput(
                          controller: _portController,
                          label: 'Port',
                          hint: '80',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  GlossyInput(
                    controller: _secretController,
                    label: 'Admin Secret Key',
                    hint: 'admin_secret_c6',
                    prefixIcon: Icons.key_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(height: 14),

                  // Auto Refresh Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Real-Time Polling',
                            style: TextStyle(
                              color: GlossyColors.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Auto refresh metrics every 5 seconds',
                            style: TextStyle(
                              color: GlossyColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: _autoRefresh,
                        activeThumbColor: GlossyColors.primaryBlue,
                        onChanged: (val) => setState(() => _autoRefresh = val),
                      ),
                    ],
                  ),

                  // Connection Test Result
                  if (_testMessage != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _testColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _testColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _testColor == GlossyColors.emeraldMint
                                ? Icons.check_circle_outline
                                : Icons.error_outline,
                            color: _testColor,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _testMessage!,
                              style: TextStyle(
                                color: _testColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 22),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GlossyButton(
                          label: 'Test Ping',
                          icon: Icons.speed,
                          style: GlossyButtonStyle.secondary,
                          isLoading: _isTesting,
                          onPressed: _runTest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlossyButton(
                          label: 'Save & Apply',
                          icon: Icons.check,
                          style: GlossyButtonStyle.primary,
                          onPressed: _saveAndClose,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
