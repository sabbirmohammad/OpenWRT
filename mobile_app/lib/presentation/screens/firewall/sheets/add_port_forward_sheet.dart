import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../models/client_info.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';
import '../../../widgets/glossy_modal_sheet.dart';

class AddPortForwardSheet extends StatefulWidget {
  final RouterController controller;
  final List<ClientInfo> clients;

  const AddPortForwardSheet({
    super.key,
    required this.controller,
    required this.clients,
  });

  @override
  State<AddPortForwardSheet> createState() => _AddPortForwardSheetState();
}

class _AddPortForwardSheetState extends State<AddPortForwardSheet> {
  final _nameCtrl = TextEditingController();
  final _extPortCtrl = TextEditingController();
  final _intIpCtrl = TextEditingController(text: '192.168.1.100');
  final _intPortCtrl = TextEditingController();
  String _selectedProto = 'tcp';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _extPortCtrl.dispose();
    _intIpCtrl.dispose();
    _intPortCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleApply() async {
    if (_nameCtrl.text.trim().isEmpty || _extPortCtrl.text.trim().isEmpty || _intIpCtrl.text.trim().isEmpty) {
      AppFeedback.showError(context, 'Please fill in Rule Name, External Port and Destination IP.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.controller.addPortForward(
        name: _nameCtrl.text.trim(),
        proto: _selectedProto,
        extPort: _extPortCtrl.text.trim(),
        intIp: _intIpCtrl.text.trim(),
        intPort: _intPortCtrl.text.trim().isNotEmpty ? _intPortCtrl.text.trim() : _extPortCtrl.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showSuccess(context, 'Port forward rule "${_nameCtrl.text}" applied.');
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Failed to add rule: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlossyModalSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.alt_route_rounded, color: GlossyColors.primaryBlue, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add Port Forwarding Rule',
                  style: TextStyle(
                    color: GlossyColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Forward inbound WAN traffic to a specific local device and port.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GlossyInput(
            controller: _nameCtrl,
            label: 'Rule Name',
            hint: 'e.g. Web Server / Minecraft',
            prefixIcon: Icons.label_outline_rounded,
          ),
          const SizedBox(height: 12),
          const Text(
            'Protocol',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: ['tcp', 'udp', 'tcp+udp'].map((p) {
              final isSelected = _selectedProto == p;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(p.toUpperCase()),
                  selected: isSelected,
                  selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.25),
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  labelStyle: TextStyle(
                    color: isSelected ? GlossyColors.primaryBlue : GlossyColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  onSelected: (_) => setState(() => _selectedProto = p),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GlossyInput(
                  controller: _extPortCtrl,
                  label: 'External Port',
                  hint: 'e.g. 8080',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.input_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlossyInput(
                  controller: _intPortCtrl,
                  label: 'Internal Port',
                  hint: 'e.g. 80',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.output_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GlossyInput(
            controller: _intIpCtrl,
            label: 'Internal Destination IP',
            hint: 'e.g. 192.168.1.101',
            keyboardType: TextInputType.datetime,
            prefixIcon: Icons.computer_rounded,
          ),
          const SizedBox(height: 8),
          if (widget.clients.isNotEmpty) ...[
            const Text(
              'Quick Select Client:',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.clients.take(4).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: const Icon(Icons.devices, size: 14, color: GlossyColors.lightBlue),
                      label: Text(c.hostname, style: const TextStyle(fontSize: 11, color: GlossyColors.textPrimary)),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      onPressed: () => setState(() => _intIpCtrl.text = c.ip),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          GlossyButton(
            label: 'Apply Port Forward Rule',
            icon: Icons.check_rounded,
            isLoading: _isSaving,
            onPressed: _handleApply,
          ),
        ],
      ),
    );
  }
}
