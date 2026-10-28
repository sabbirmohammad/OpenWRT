import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';

class AddSsidSheet extends StatefulWidget {
  final RouterController controller;

  const AddSsidSheet({super.key, required this.controller});

  @override
  State<AddSsidSheet> createState() => _AddSsidSheetState();
}

class _AddSsidSheetState extends State<AddSsidSheet> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _keyController = TextEditingController();
  String _selectedRadio = 'radio0';
  final String _encryption = 'psk2';
  bool _isIsolated = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _ssidController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _createSsid() async {
    final ssid = _ssidController.text.trim();
    if (ssid.isEmpty) {
      AppFeedback.showError(context, 'Please enter an SSID name.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await widget.controller.addSsid(
        ssid: ssid,
        radio: _selectedRadio,
        key: _keyController.text.isNotEmpty ? _keyController.text : null,
        encryption: _encryption,
        isolate: _isIsolated,
      );
      if (mounted) {
        Navigator.pop(context);
        AppFeedback.showSuccess(context, 'Virtual SSID "$ssid" created on $_selectedRadio.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, 'Failed to add SSID: $e');
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
            const Text(
              'Add New Virtual SSID',
              style: TextStyle(
                color: GlossyColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Create a secondary broadcast network on 2.4 GHz or 5.0 GHz radio.',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            GlossyInput(
              controller: _ssidController,
              label: 'SSID Name',
              hint: 'e.g. Archer_IoT or Guest_Lounge',
              prefixIcon: Icons.wifi,
            ),
            const SizedBox(height: 14),
            const Text(
              'Radio Band',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: _buildRadioChoice(
                    radioId: 'radio0',
                    label: '2.4 GHz Radio',
                    subtitle: 'MT7603E • Long Range',
                    isSelected: _selectedRadio == 'radio0',
                    onTap: () => setState(() => _selectedRadio = 'radio0'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildRadioChoice(
                    radioId: 'radio1',
                    label: '5.0 GHz Radio',
                    subtitle: 'MT7613BEN • High Speed',
                    isSelected: _selectedRadio == 'radio1',
                    onTap: () => setState(() => _selectedRadio = 'radio1'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GlossyInput(
              controller: _keyController,
              label: 'WPA2 Passphrase',
              hint: 'Minimum 8 characters',
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: GlossyColors.glassBorderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Enforce Client Isolation', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                      Text('Isolated VLAN-like access for guests', style: TextStyle(color: GlossyColors.textMuted, fontSize: 11)),
                    ],
                  ),
                  Switch.adaptive(
                    value: _isIsolated,
                    activeThumbColor: GlossyColors.isolatedAccent,
                    onChanged: (val) => setState(() => _isIsolated = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            GlossyButton(
              label: 'Create SSID',
              icon: Icons.add_circle_outline,
              isLoading: _isLoading,
              onPressed: _createSsid,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioChoice({
    required String radioId,
    required String label,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? GlossyColors.primaryBlue.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? GlossyColors.primaryBlue : GlossyColors.glassBorderLight,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? GlossyColors.lightBlue : GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: GlossyColors.lightBlue, size: 16),
              ],
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
