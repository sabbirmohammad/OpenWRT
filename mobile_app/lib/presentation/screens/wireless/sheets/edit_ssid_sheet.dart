import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';

class EditSsidSheet extends StatefulWidget {
  final RouterController controller;
  final SsidInfo ssid;

  const EditSsidSheet({super.key, required this.controller, required this.ssid});

  @override
  State<EditSsidSheet> createState() => _EditSsidSheetState();
}

class _EditSsidSheetState extends State<EditSsidSheet> {
  late final TextEditingController _ssidController;
  late final TextEditingController _keyController;
  late bool _isHidden;
  late bool _isIsolated;
  bool _obscureKey = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController(text: widget.ssid.ssid);
    _keyController = TextEditingController(text: widget.ssid.password ?? '');
    _isHidden = widget.ssid.isHidden;
    _isIsolated = widget.ssid.isIsolated;
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final newName = _ssidController.text.trim();
    if (newName.isEmpty) {
      AppFeedback.showError(context, 'SSID name cannot be empty.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.controller.updateSsidConfig(
        ifaceId: widget.ssid.id,
        newSsid: newName,
        key: _keyController.text.isNotEmpty ? _keyController.text : null,
        hidden: _isHidden,
        isolate: _isIsolated,
      );
      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSuccess(context, 'SSID "${widget.ssid.id}" settings saved.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to update SSID: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: GlossyColors.backgroundElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: GlossyColors.glassBorderLight)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit SSID Configuration',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Interface: ${widget.ssid.id} (${widget.ssid.band})',
                      style: const TextStyle(color: GlossyColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                GlossyBadge(
                  label: widget.ssid.band,
                  dotColor: GlossyColors.primaryBlue,
                  showDot: false,
                ),
              ],
            ),
            const SizedBox(height: 20),
            GlossyInput(
              controller: _ssidController,
              label: 'SSID Name (Broadcast Name)',
              hint: 'e.g. MyWiFi_5G',
              prefixIcon: Icons.wifi,
            ),
            const SizedBox(height: 16),
            GlossyInput(
              controller: _keyController,
              label: 'WPA2/WPA3 Password',
              hint: 'Leave blank to retain current key',
              prefixIcon: Icons.lock_outline,
              obscureText: _obscureKey,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: GlossyColors.textSecondary,
                  size: 18,
                ),
                onPressed: () => setState(() => _obscureKey = !_obscureKey),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hide SSID Broadcast', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Do not broadcast beacon (Stealth)', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isHidden,
                        activeThumbColor: GlossyColors.primaryBlue,
                        onChanged: (val) => setState(() => _isHidden = val),
                      ),
                    ],
                  ),
                  const Divider(color: GlossyColors.glassDivider, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Client Isolation', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                          Text('Prevent devices on this SSID from talking', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isIsolated,
                        activeThumbColor: GlossyColors.isolatedAccent,
                        onChanged: (val) => setState(() => _isIsolated = val),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            GlossyButton(
              label: 'Save Configuration',
              icon: Icons.check,
              isLoading: _isLoading,
              onPressed: _saveChanges,
            ),
          ],
        ),
      ),
    );
  }
}
