import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';
import '../../../widgets/glossy_modal_sheet.dart';

class AddTrafficRuleSheet extends StatefulWidget {
  final RouterController controller;

  const AddTrafficRuleSheet({super.key, required this.controller});

  @override
  State<AddTrafficRuleSheet> createState() => _AddTrafficRuleSheetState();
}

class _AddTrafficRuleSheetState extends State<AddTrafficRuleSheet> {
  final _nameCtrl = TextEditingController();
  String _selectedSrc = 'lan';
  String _selectedDest = 'wan';
  String _selectedProto = 'tcp';
  String _selectedTarget = 'DROP';
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_nameCtrl.text.trim().isEmpty) {
      AppFeedback.showError(context, 'Please enter a rule name.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.controller.addTrafficRule(
        name: _nameCtrl.text.trim(),
        proto: _selectedProto,
        src: _selectedSrc,
        dest: _selectedDest,
        target: _selectedTarget,
      );
      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showSuccess(context, 'Traffic filter "${_nameCtrl.text}" applied successfully.');
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Failed to add traffic rule: $e');
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
              Icon(Icons.filter_list_rounded, color: GlossyColors.emeraldMint, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Add Traffic Filter Rule',
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
            'Define packet filtering policies between router network zones.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GlossyInput(
            controller: _nameCtrl,
            label: 'Rule Name',
            hint: 'e.g. Block DoH Bypass / Drop Guest Admin',
            prefixIcon: Icons.label_outline_rounded,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Source Zone', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSrc,
                      isExpanded: true,
                      dropdownColor: GlossyColors.backgroundSecondary,
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GlossyColors.glassBorderLight)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'lan', child: Text('LAN (Private)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'wan', child: Text('WAN (Internet)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'guest', child: Text('Guest Zone', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) => setState(() => _selectedSrc = val ?? 'lan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Destination Zone', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedDest,
                      isExpanded: true,
                      dropdownColor: GlossyColors.backgroundSecondary,
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GlossyColors.glassBorderLight)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'router', child: Text('Router', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'wan', child: Text('WAN (Internet)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'lan', child: Text('LAN (Private)', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) => setState(() => _selectedDest = val ?? 'wan'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Protocol', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProto,
                      isExpanded: true,
                      dropdownColor: GlossyColors.backgroundSecondary,
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GlossyColors.glassBorderLight)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'tcp', child: Text('TCP', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'udp', child: Text('UDP', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'icmp', child: Text('ICMP (Ping)', overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'all', child: Text('ALL Protocols', overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) => setState(() => _selectedProto = val ?? 'tcp'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Action Target', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedTarget,
                      isExpanded: true,
                      dropdownColor: GlossyColors.backgroundSecondary,
                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: GlossyColors.glassBorderLight)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'ACCEPT', child: Text('ACCEPT', style: TextStyle(color: GlossyColors.emeraldMint, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'DROP', child: Text('DROP', style: TextStyle(color: GlossyColors.roseCoral, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                        DropdownMenuItem(value: 'REJECT', child: Text('REJECT', style: TextStyle(color: GlossyColors.amberWarm, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                      ],
                      onChanged: (val) => setState(() => _selectedTarget = val ?? 'DROP'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GlossyButton(
            label: 'Save Traffic Filter Rule',
            icon: Icons.check_rounded,
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
