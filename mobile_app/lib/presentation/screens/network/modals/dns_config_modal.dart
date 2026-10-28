import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../../models/network_info.dart';
import '../../../widgets/glossy_button.dart';
import '../../../widgets/glossy_input.dart';
import 'dns_active_banner.dart';
import 'dns_preset_model.dart';
import 'dns_preset_tile.dart';

class DnsConfigModal extends StatefulWidget {
  final NetworkInfo? network;
  final Function(String primary, String secondary) onApply;

  const DnsConfigModal({
    super.key,
    required this.network,
    required this.onApply,
  });

  @override
  State<DnsConfigModal> createState() => _DnsConfigModalState();
}

class _DnsConfigModalState extends State<DnsConfigModal> {
  late String _selectedId;
  late TextEditingController _primaryCtrl;
  late TextEditingController _secondaryCtrl;

  @override
  void initState() {
    super.initState();
    final currentDns = widget.network?.dns ?? '1.1.1.1, 8.8.8.8';
    _selectedId = 'custom';
    for (final p in DnsPreset.presets) {
      if (p.id == 'auto' && (currentDns.isEmpty || currentDns.toLowerCase().contains('auto'))) {
        _selectedId = 'auto';
        break;
      }
      if (p.primary.isNotEmpty && p.primary != 'auto' && currentDns.contains(p.primary)) {
        _selectedId = p.id;
        break;
      }
    }

    final initialPri = _selectedId == 'auto'
        ? 'auto'
        : (widget.network?.primaryDns.isNotEmpty == true ? widget.network!.primaryDns : '1.1.1.1');
    final initialSec = _selectedId == 'auto'
        ? ''
        : (widget.network?.secondaryDns ?? '1.0.0.1');

    _primaryCtrl = TextEditingController(text: initialPri);
    _secondaryCtrl = TextEditingController(text: initialSec);
  }

  @override
  void dispose() {
    _primaryCtrl.dispose();
    _secondaryCtrl.dispose();
    super.dispose();
  }

  void _handleApply() {
    final p = _primaryCtrl.text.trim();
    final s = _secondaryCtrl.text.trim();

    if (p.isEmpty) {
      AppFeedback.showError(context, 'Primary DNS cannot be empty. Enter IPv4 or "auto"');
      return;
    }

    if (p != 'auto') {
      if (!InputValidators.isValidIpv4(p)) {
        AppFeedback.showError(context, 'Invalid Primary DNS IPv4 format (e.g. 1.1.1.1)');
        return;
      }
      if (s.isNotEmpty && s != 'auto' && !InputValidators.isValidIpv4(s)) {
        AppFeedback.showError(context, 'Invalid Secondary DNS IPv4 format (e.g. 1.0.0.1)');
        return;
      }
    }

    Navigator.pop(context);
    widget.onApply(p, p == 'auto' ? '' : s);
  }

  @override
  Widget build(BuildContext context) {
    final currentDns = widget.network?.dns ?? '1.1.1.1, 8.8.8.8';

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (ctx, scrollController) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.dns_rounded, color: GlossyColors.primaryBlue, size: 22),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Upstream DNS Resolver',
                      style: TextStyle(
                        color: GlossyColors.textPrimary,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: GlossyColors.textSecondary, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'Upstream DNS resolves domain names (like google.com) to IP addresses. Choose a privacy or ad-blocking DNS, or enter custom servers.',
                style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
              ),
              const SizedBox(height: 16),
              DnsActiveBanner(network: widget.network),
              const SizedBox(height: 18),
              Row(
                children: [
                  const Icon(Icons.edit_note_rounded, size: 16, color: GlossyColors.primaryBlue),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Configure Upstream DNS (Editable)',
                      style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (_selectedId != 'custom')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GlossyColors.primaryBlue.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DnsPreset.presets.firstWhere((p) => p.id == _selectedId).name,
                        style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 10, fontWeight: FontWeight.w500),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GlossyInput(
                controller: _primaryCtrl,
                label: 'Primary DNS Server IPv4',
                hint: 'e.g. 1.1.1.1 or auto',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.dns_outlined,
                onChanged: (val) => setState(() => _selectedId = 'custom'),
              ),
              const SizedBox(height: 10),
              GlossyInput(
                controller: _secondaryCtrl,
                label: 'Secondary DNS Server IPv4 (Optional)',
                hint: 'e.g. 1.0.0.1',
                keyboardType: TextInputType.text,
                prefixIcon: Icons.dns_outlined,
                onChanged: (val) => setState(() => _selectedId = 'custom'),
              ),
              const SizedBox(height: 18),
              const Text(
                'Select DNS Provider Preset',
                style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ...DnsPreset.presets.map((preset) {
                final isSelected = _selectedId == preset.id;
                final pri = preset.primary;
                final isLiveActive = (pri.isNotEmpty && pri != 'auto' && currentDns.contains(pri)) ||
                    (preset.id == 'auto' && (currentDns.isEmpty || currentDns.contains('auto')));

                return DnsPresetTile(
                  preset: preset,
                  isSelected: isSelected,
                  isLiveActive: isLiveActive,
                  onTap: () {
                    setState(() {
                      _selectedId = preset.id;
                      if (_selectedId == 'auto') {
                        _primaryCtrl.text = 'auto';
                        _secondaryCtrl.text = '';
                      } else if (_selectedId != 'custom') {
                        _primaryCtrl.text = preset.primary;
                        _secondaryCtrl.text = preset.secondary;
                      }
                    });
                  },
                );
              }),
              const SizedBox(height: 20),
              GlossyButton(
                label: 'Apply & Save to Router',
                icon: Icons.check_circle_outline,
                onPressed: _handleApply,
              ),
            ],
          ),
        );
      },
    );
  }
}
