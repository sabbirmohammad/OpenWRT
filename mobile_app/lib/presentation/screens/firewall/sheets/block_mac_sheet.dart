import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../models/client_info.dart';
import '../../../controllers/router_controller.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';
import '../../../widgets/glossy_modal_sheet.dart';

class BlockMacSheet extends StatefulWidget {
  final RouterController controller;
  final List<ClientInfo> clients;

  const BlockMacSheet({
    super.key,
    required this.controller,
    required this.clients,
  });

  @override
  State<BlockMacSheet> createState() => _BlockMacSheetState();
}

class _BlockMacSheetState extends State<BlockMacSheet> {
  final _macCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _macCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleBlock() async {
    final mac = _macCtrl.text.trim().toLowerCase();
    if (!InputValidators.isValidMac(mac)) {
      AppFeedback.showError(context, 'Please enter a valid MAC address (XX:XX:XX:XX:XX:XX)');
      return;
    }
    setState(() => _isSaving = true);
    try {
      await widget.controller.blockClient(mac);
      if (mounted) {
        Navigator.of(context).pop();
        AppFeedback.showError(context, 'Client $mac blocked at firewall forward chain.');
      }
    } catch (e) {
      if (mounted) AppFeedback.showError(context, 'Failed to block MAC: $e');
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
              Icon(Icons.block_rounded, color: GlossyColors.roseCoral, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Block Client at Firewall Forward Chain',
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
            'Drops all internet and forwarding packets for the target MAC at the Linux kernel firewall level.',
            style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          GlossyInput(
            controller: _macCtrl,
            label: 'Client Hardware MAC Address',
            hint: 'XX:XX:XX:XX:XX:XX',
            prefixIcon: Icons.fingerprint_rounded,
          ),
          const SizedBox(height: 12),
          if (widget.clients.isNotEmpty) ...[
            const Text(
              'Connected Devices:',
              style: TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
            ),
            const SizedBox(height: 4),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: widget.clients.where((c) => !c.blocked).take(5).map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ActionChip(
                      avatar: const Icon(Icons.device_unknown, size: 14, color: GlossyColors.roseCoral),
                      label: Text(c.hostname, style: const TextStyle(fontSize: 11, color: GlossyColors.textPrimary)),
                      backgroundColor: Colors.white.withValues(alpha: 0.06),
                      onPressed: () => setState(() => _macCtrl.text = c.mac),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
          const SizedBox(height: 20),
          GlossyButton(
            label: 'Enforce Firewall Drop Rule',
            icon: Icons.shield_rounded,
            style: GlossyButtonStyle.danger,
            isLoading: _isSaving,
            onPressed: _handleBlock,
          ),
        ],
      ),
    );
  }
}
