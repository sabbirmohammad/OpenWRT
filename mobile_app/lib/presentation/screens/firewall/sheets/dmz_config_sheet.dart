import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';
import '../../../widgets/glossy_modal_sheet.dart';

class DmzConfigSheet extends StatefulWidget {
  final RouterController controller;
  final String currentIp;

  const DmzConfigSheet({
    super.key,
    required this.controller,
    required this.currentIp,
  });

  @override
  State<DmzConfigSheet> createState() => _DmzConfigSheetState();
}

class _DmzConfigSheetState extends State<DmzConfigSheet> {
  late final TextEditingController _ipCtrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _ipCtrl = TextEditingController(text: widget.currentIp);
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final ip = _ipCtrl.text.trim();
    if (ip.isEmpty || !InputValidators.isValidIpv4(ip)) {
      AppFeedback.showError(context, 'Please enter a valid IPv4 address.');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.controller.toggleDmz(enabled: true, ip: ip);
      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showSuccess(context, 'DMZ Host updated to $ip.');
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Failed to update DMZ: $e');
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
              Icon(Icons.shield_outlined, color: GlossyColors.amberWarm, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Configure DMZ Host IP',
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
            'All unmapped incoming WAN packets will be forwarded directly to this local device IP.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GlossyInput(
            controller: _ipCtrl,
            label: 'DMZ Destination IP',
            hint: 'e.g. 192.168.1.150',
            keyboardType: TextInputType.datetime,
            prefixIcon: Icons.dns_rounded,
          ),
          const SizedBox(height: 20),
          GlossyButton(
            label: 'Save & Apply DMZ',
            icon: Icons.check_rounded,
            isLoading: _isSaving,
            onPressed: _handleSave,
          ),
        ],
      ),
    );
  }
}
