import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import '../widgets/glossy_button.dart';
import '../widgets/glossy_card.dart';
import '../widgets/glossy_input.dart';

class NetworkScreen extends StatefulWidget {
  final RouterController controller;

  const NetworkScreen({super.key, required this.controller});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  bool _isActionPending = false;

  Future<void> _runAction(String name, Future<void> Function() action) async {
    if (_isActionPending) return;
    setState(() => _isActionPending = true);

    try {
      await action();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name updated successfully.'),
            backgroundColor: GlossyColors.emeraldMint,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $name: $e'),
            backgroundColor: GlossyColors.roseCoral,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionPending = false);
      }
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label ($text) copied to clipboard.'),
        backgroundColor: GlossyColors.primaryBlue,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSqmTuneModal(BuildContext context) {
    final network = widget.controller.status?.network;
    double dlMbps = network != null ? network.sqmDownloadMbps : 95.0;
    double ulMbps = network != null ? network.sqmUploadMbps : 20.0;
    String qdisc = network?.sqmQdisc ?? 'cake';

    showModalBottomSheet(
      context: context,
      backgroundColor: GlossyColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, color: GlossyColors.lightBlue, size: 22),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Tune CAKE SQM Bandwidth',
                          style: TextStyle(
                            color: GlossyColors.textPrimary,
                            fontSize: 16,
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
                  const SizedBox(height: 6),
                  const Text(
                    'Set strict ingress and egress limits below your line speed to eliminate bufferbloat and latency spikes.',
                    style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.35),
                  ),
                  const SizedBox(height: 20),

                  // Download Limit Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Download Limit', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${dlMbps.toStringAsFixed(1)} Mbps', style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: GlossyColors.emeraldMint,
                      thumbColor: GlossyColors.emeraldMint,
                      inactiveTrackColor: Colors.white12,
                    ),
                    child: Slider(
                      value: dlMbps.clamp(5.0, 300.0),
                      min: 5.0,
                      max: 300.0,
                      divisions: 59,
                      onChanged: (val) => setModalState(() => dlMbps = val),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Upload Limit Slider
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Upload Limit', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${ulMbps.toStringAsFixed(1)} Mbps', style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 14, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  SliderTheme(
                    data: SliderTheme.of(ctx).copyWith(
                      activeTrackColor: GlossyColors.lightBlue,
                      thumbColor: GlossyColors.lightBlue,
                      inactiveTrackColor: Colors.white12,
                    ),
                    child: Slider(
                      value: ulMbps.clamp(2.0, 100.0),
                      min: 2.0,
                      max: 100.0,
                      divisions: 49,
                      onChanged: (val) => setModalState(() => ulMbps = val),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Queue Discipline Selector
                  const Text('Queuing Algorithm', style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('CAKE (Modern)')),
                          selected: qdisc == 'cake',
                          selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
                          onSelected: (sel) => setModalState(() => qdisc = 'cake'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('FQ_CoDel')),
                          selected: qdisc == 'fq_codel',
                          selectedColor: GlossyColors.primaryBlue.withValues(alpha: 0.3),
                          onSelected: (sel) => setModalState(() => qdisc = 'fq_codel'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  GlossyButton(
                    label: 'Apply SQM Tuning',
                    icon: Icons.check_circle_outline,
                    onPressed: () {
                      Navigator.pop(ctx);
                      _runAction(
                        'SQM Tuning',
                        () => widget.controller.updateSqmConfig(
                          enabled: true,
                          qdisc: qdisc,
                          downloadKbit: (dlMbps * 1000).toInt(),
                          uploadKbit: (ulMbps * 1000).toInt(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDnsConfigModal(BuildContext context) {
    final network = widget.controller.status?.network;
    final currentDns = network?.dns ?? '1.1.1.1, 8.8.8.8';

    final presets = [
      {
        'id': 'cloudflare',
        'name': 'Cloudflare DNS',
        'primary': '1.1.1.1',
        'secondary': '1.0.0.1',
        'desc': 'Ultra-fast response time, zero-logging privacy',
        'icon': Icons.bolt_rounded,
        'color': GlossyColors.amberWarm,
      },
      {
        'id': 'adguard',
        'name': 'AdGuard Ad-Block',
        'primary': '94.140.14.14',
        'secondary': '94.140.15.15',
        'desc': 'Blocks ads, trackers & phishing router-wide',
        'icon': Icons.shield_rounded,
        'color': GlossyColors.emeraldMint,
      },
      {
        'id': 'google',
        'name': 'Google Public DNS',
        'primary': '8.8.8.8',
        'secondary': '8.8.4.4',
        'desc': 'High reliability, worldwide Anycast routing',
        'icon': Icons.public,
        'color': GlossyColors.lightBlue,
      },
      {
        'id': 'quad9',
        'name': 'Quad9 Security',
        'primary': '9.9.9.9',
        'secondary': '149.112.112.112',
        'desc': 'Blocks malware, spyware & infected hosts',
        'icon': Icons.security_rounded,
        'color': GlossyColors.roseCoral,
      },
      {
        'id': 'auto',
        'name': 'ISP Automatic (DHCP / PPPoE)',
        'primary': 'auto',
        'secondary': '',
        'desc': 'Dynamic DNS assigned by your ISP gateway',
        'icon': Icons.sync_rounded,
        'color': GlossyColors.textSecondary,
      },
      {
        'id': 'custom',
        'name': 'Custom Manual DNS',
        'primary': '',
        'secondary': '',
        'desc': 'Specify your own custom IPv4 DNS servers',
        'icon': Icons.edit_note_rounded,
        'color': GlossyColors.primaryBlue,
      },
    ];

    String selectedId = 'custom';
    for (final p in presets) {
      if (p['id'] == 'auto' && (currentDns.isEmpty || currentDns.toLowerCase().contains('auto'))) {
        selectedId = 'auto';
        break;
      }
      final pPri = p['primary'] as String;
      if (pPri.isNotEmpty && pPri != 'auto' && currentDns.contains(pPri)) {
        selectedId = p['id'] as String;
        break;
      }
    }

    final initialPri = selectedId == 'auto'
        ? 'auto'
        : (network?.primaryDns.isNotEmpty == true ? network!.primaryDns : '1.1.1.1');
    final initialSec = selectedId == 'auto'
        ? ''
        : (network?.secondaryDns ?? '1.0.0.1');

    final primaryCtrl = TextEditingController(text: initialPri);
    final secondaryCtrl = TextEditingController(text: initialSec);

    showModalBottomSheet(
      context: context,
      backgroundColor: GlossyColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
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

                      // Live Active DNS on Router Banner
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GlossyColors.emeraldMint.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: GlossyColors.emeraldMint.withValues(alpha: 0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: GlossyColors.emeraldMint,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    'ACTIVE ROUTER DNS RESOLVER',
                                    style: TextStyle(
                                      color: GlossyColors.emeraldMint,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.6,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: GlossyColors.emeraldMint.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    network?.dnsProviderName ?? 'Cloudflare DNS',
                                    style: const TextStyle(
                                      color: GlossyColors.emeraldMint,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: GlossyColors.glassBorderLight),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'PRIMARY DNS',
                                          style: TextStyle(color: GlossyColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          network?.primaryDns ?? '1.1.1.1',
                                          style: const TextStyle(
                                            color: GlossyColors.textPrimary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.03),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: GlossyColors.glassBorderLight),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'SECONDARY DNS',
                                          style: TextStyle(color: GlossyColors.textMuted, fontSize: 9, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          network?.secondaryDns.isNotEmpty == true ? network!.secondaryDns : 'None (Auto)',
                                          style: TextStyle(
                                            color: network?.secondaryDns.isNotEmpty == true ? GlossyColors.textPrimary : GlossyColors.textMuted,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.edit_note_rounded, size: 16, color: GlossyColors.primaryBlue),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Configure Upstream DNS (Editable)',
                              style: TextStyle(
                                color: GlossyColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (selectedId != 'custom')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: GlossyColors.primaryBlue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                presets.firstWhere((p) => p['id'] == selectedId)['name'] as String,
                                style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 10, fontWeight: FontWeight.w500),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      GlossyInput(
                        controller: primaryCtrl,
                        label: 'Primary DNS Server IPv4',
                        hint: 'e.g. 1.1.1.1 or auto',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.dns_outlined,
                        onChanged: (val) {
                          setModalState(() {
                            selectedId = 'custom';
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      GlossyInput(
                        controller: secondaryCtrl,
                        label: 'Secondary DNS Server IPv4 (Optional)',
                        hint: 'e.g. 1.0.0.1',
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.dns_outlined,
                        onChanged: (val) {
                          setModalState(() {
                            selectedId = 'custom';
                          });
                        },
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Select DNS Provider Preset',
                        style: TextStyle(
                          color: GlossyColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Presets
                      ...presets.map((preset) {
                        final isSelected = selectedId == preset['id'];
                        final pri = preset['primary'] as String;
                        final isLiveActive = (pri.isNotEmpty &&
                                pri != 'auto' &&
                                currentDns.contains(pri)) ||
                            (preset['id'] == 'auto' && (currentDns.isEmpty || currentDns.contains('auto')));

                        final sec = preset['secondary'] as String;
                        final ipText = preset['id'] == 'auto'
                            ? 'ISP Default'
                            : (preset['id'] == 'custom'
                                ? 'Custom IPs'
                                : '$pri${sec.isNotEmpty ? ", $sec" : ""}');

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                selectedId = preset['id'] as String;
                                if (selectedId == 'auto') {
                                  primaryCtrl.text = 'auto';
                                  secondaryCtrl.text = '';
                                } else if (selectedId != 'custom') {
                                  primaryCtrl.text = preset['primary'] as String;
                                  secondaryCtrl.text = preset['secondary'] as String;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? GlossyColors.primaryBlue.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? GlossyColors.primaryBlue
                                      : GlossyColors.glassBorderLight,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    preset['icon'] as IconData,
                                    color: preset['color'] as Color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                preset['name'] as String,
                                                style: const TextStyle(
                                                  color: GlossyColors.textPrimary,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (isLiveActive) ...[
                                              const SizedBox(width: 6),
                                              const GlossyBadge(
                                                label: 'Active',
                                                dotColor: GlossyColors.emeraldMint,
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          ipText,
                                          style: const TextStyle(
                                            color: GlossyColors.lightBlue,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          preset['desc'] as String,
                                          style: const TextStyle(
                                            color: GlossyColors.textMuted,
                                            fontSize: 10,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? GlossyColors.primaryBlue
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: isSelected
                                            ? GlossyColors.primaryBlue
                                            : GlossyColors.textMuted.withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 13,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                      GlossyButton(
                        label: 'Apply & Save to Router',
                        icon: Icons.check_circle_outline,
                        onPressed: () {
                          final p = primaryCtrl.text.trim();
                          final s = secondaryCtrl.text.trim();

                          if (p.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Primary DNS cannot be empty. Enter IPv4 or "auto"'),
                                backgroundColor: GlossyColors.roseCoral,
                              ),
                            );
                            return;
                          }

                          if (p != 'auto') {
                            final ipv4Regex = RegExp(r'^([0-9]{1,3}\.){3}[0-9]{1,3}$');
                            if (!ipv4Regex.hasMatch(p)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid Primary DNS IPv4 format (e.g. 1.1.1.1)'),
                                  backgroundColor: GlossyColors.roseCoral,
                                ),
                              );
                              return;
                            }
                            if (s.isNotEmpty && s != 'auto' && !ipv4Regex.hasMatch(s)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invalid Secondary DNS IPv4 format (e.g. 1.0.0.1)'),
                                  backgroundColor: GlossyColors.roseCoral,
                                ),
                              );
                              return;
                            }
                          }

                          Navigator.pop(ctx);
                          _runAction(
                            'Upstream DNS',
                            () => widget.controller.setCustomDns(
                              primary: p,
                              secondary: p == 'auto' ? '' : s,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final status = widget.controller.status;
        final traffic = status?.traffic;
        final network = status?.network;
        final cpu = status?.cpu;
        final isWanOnline = traffic != null && traffic.wanIp != '0.0.0.0' && traffic.wanIp.isNotEmpty;

        return Scaffold(
          backgroundColor: GlossyColors.backgroundPrimary,
          appBar: AppBar(
            titleSpacing: 16,
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network & Acceleration',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: GlossyColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Routing, NAT Offload & QoS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: GlossyColors.textSecondary,
                  ),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: GlossyBadge(
                  label: isWanOnline ? 'WAN Online' : 'WAN Offline',
                  dotColor: isWanOnline ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                ),
              ),
            ],
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
                  // 1. WAN Gateway Card (WanDetailsCard)
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.public, color: GlossyColors.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'WAN Internet Gateway',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: GlossyBadge(
                                label: _formatProtocol(network?.protocol ?? 'DHCP'),
                                showDot: false,
                                textColor: GlossyColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Metric Tiles Grid: Row 1
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Public WAN IP',
                                value: traffic?.wanIp ?? '0.0.0.0',
                                icon: Icons.language,
                                valueColor: GlossyColors.emeraldMint,
                                trailing: const Icon(Icons.copy_rounded, size: 12, color: GlossyColors.textMuted),
                                onTap: () => _copyToClipboard(traffic?.wanIp ?? '0.0.0.0', 'Public WAN IP'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Gateway IP',
                                value: network?.gateway.isNotEmpty == true ? network!.gateway : '0.0.0.0',
                                icon: Icons.router_outlined,
                                onTap: () => _copyToClipboard(network?.gateway ?? '0.0.0.0', 'Gateway IP'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Metric Tiles Grid: Row 2
                        Row(
                          children: [
                            Expanded(
                              child: _buildMetricTile(
                                label: 'DNS • ${network?.dnsProviderName ?? "Live"}',
                                value: network?.dns.isNotEmpty == true ? network!.dns : '1.1.1.1, 8.8.8.8',
                                icon: Icons.dns_outlined,
                                trailing: const Icon(Icons.tune_rounded, size: 12, color: GlossyColors.lightBlue),
                                onTap: () => _showDnsConfigModal(context),
                                customBody: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: GlossyColors.primaryBlue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text('PRI', style: TextStyle(color: GlossyColors.lightBlue, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                    ),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        network?.primaryDns ?? '1.1.1.1',
                                        style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (network?.secondaryDns.isNotEmpty == true) ...[
                                      const SizedBox(width: 5),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.08),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('SEC', style: TextStyle(color: GlossyColors.textMuted, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          network!.secondaryDns,
                                          style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildMetricTile(
                                label: 'Interface & MTU',
                                value: '${traffic?.interfaceName ?? "eth0.2"} • ${network?.mtu ?? 1492}B',
                                icon: Icons.cable_outlined,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Latency & Jitter Micro-Strip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.02),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: GlossyColors.glassBorderLight),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: GlossyColors.emeraldMint,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Ping: ${network?.latencyMs.toStringAsFixed(1) ?? "8.5"} ms',
                                        style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Jitter: ${network?.jitterMs.toStringAsFixed(1) ?? "0.9"} ms',
                                  style: const TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),
                        const Divider(color: GlossyColors.glassDivider),
                        const SizedBox(height: 10),

                        // 50%/50% Traffic Stats
                        Row(
                          children: [
                            Expanded(
                              child: _buildTrafficStat(
                                'Total Downloaded (Rx)',
                                traffic?.formattedRx ?? '0 MB',
                                Icons.arrow_downward,
                                GlossyColors.emeraldMint,
                              ),
                            ),
                            Container(width: 1, height: 36, color: GlossyColors.glassDivider),
                            Expanded(
                              child: _buildTrafficStat(
                                'Total Uploaded (Tx)',
                                traffic?.formattedTx ?? '0 MB',
                                Icons.arrow_upward,
                                GlossyColors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. Hardware NAT Flow Offloading Card
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.speed, color: GlossyColors.lightBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'MediaTek HW NAT Offload',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlossyBadge(
                              label: network?.hwOffload == true ? 'Accelerated' : 'Kernel',
                              dotColor: network?.hwOffload == true
                                  ? GlossyColors.emeraldMint
                                  : GlossyColors.amberWarm,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bypasses CPU kernel software routing and offloads Gigabit packet flows directly onto the MediaTek MT7621 Packet Processing Engine (PPE). Minimizes CPU usage down to < 5% during full Gigabit line-rate transfers.',
                          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 10),

                        // Silicon PPE Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          decoration: BoxDecoration(
                            color: network?.hwOffload == true
                                ? GlossyColors.emeraldMint.withValues(alpha: 0.08)
                                : GlossyColors.amberWarm.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: network?.hwOffload == true
                                  ? GlossyColors.emeraldMint.withValues(alpha: 0.25)
                                  : GlossyColors.amberWarm.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.memory,
                                size: 13,
                                color: network?.hwOffload == true
                                    ? GlossyColors.emeraldMint
                                    : GlossyColors.amberWarm,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  network?.hwOffload == true
                                      ? 'MT7621 PPE Active • Zero Routing Overhead (CPU: ${cpu?.usagePercent.toStringAsFixed(0) ?? "18"}%)'
                                      : 'Software Kernel Routing (CPU: ${cpu?.usagePercent.toStringAsFixed(0) ?? "18"}%)',
                                  style: TextStyle(
                                    color: network?.hwOffload == true
                                        ? GlossyColors.emeraldMint
                                        : GlossyColors.amberWarm,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Flow Offloading State',
                                style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: network?.hwOffload ?? true,
                              activeThumbColor: GlossyColors.emeraldMint,
                              activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                              onChanged: _isActionPending
                                  ? null
                                  : (val) => _runAction('Hardware NAT Offload', () => widget.controller.toggleHwOffload(val)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. CAKE SQM QoS & Bufferbloat Killer Card
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.tune_rounded, color: GlossyColors.lightBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'CAKE SQM QoS',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlossyBadge(
                              label: network?.sqmEnabled == true ? 'A+ Low Latency' : 'Standby',
                              dotColor: network?.sqmEnabled == true
                                  ? GlossyColors.emeraldMint
                                  : GlossyColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Common Applications Kept Enhanced (CAKE) dynamically manages active queue buffers to guarantee sub-10ms latency for competitive gaming and video calls, preventing bufferbloat during concurrent 4K streaming.',
                          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 12),

                        // Configured Limits Row
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Download Limit', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${network?.sqmDownloadMbps.toStringAsFixed(1) ?? "95.0"} Mbps ↓',
                                      style: const TextStyle(color: GlossyColors.emeraldMint, fontSize: 12, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Upload Limit', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${network?.sqmUploadMbps.toStringAsFixed(1) ?? "20.0"} Mbps ↑',
                                      style: const TextStyle(color: GlossyColors.lightBlue, fontSize: 12, fontWeight: FontWeight.w700),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Switch & Tune Button Row
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Queue Discipline (${network?.sqmQdisc.toUpperCase() ?? "CAKE"})',
                                    style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  GestureDetector(
                                    onTap: () => _showSqmTuneModal(context),
                                    child: const Text(
                                      'Tap to configure bandwidth limits',
                                      style: TextStyle(color: GlossyColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: network?.sqmEnabled ?? false,
                              activeThumbColor: GlossyColors.emeraldMint,
                              activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                              onChanged: _isActionPending
                                  ? null
                                  : (val) => _runAction('CAKE SQM QoS', () => widget.controller.toggleSqm(val)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 4. WireGuard VPN Remote Tunnel Hub Card
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.security, color: GlossyColors.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'WireGuard VPN Tunnel',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlossyBadge(
                              label: network?.wireguardEnabled == true ? 'Connected' : 'Standby',
                              dotColor: network?.wireguardEnabled == true
                                  ? GlossyColors.emeraldMint
                                  : GlossyColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Direct peer-to-peer encrypted tunnel connecting your Android device to the Archer C6 router over interface wg0 with ChaCha20-Poly1305 and zero cloud dependencies.',
                          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 12),

                        // Subnet & Interface Blocks
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Local Gateway', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                                    SizedBox(height: 2),
                                    Text(
                                      '192.168.1.1',
                                      style: TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('WireGuard Endpoint', style: TextStyle(color: GlossyColors.textMuted, fontSize: 10)),
                                    const SizedBox(height: 2),
                                    Text(
                                      network?.wireguardEndpoint ?? '10.14.0.1:51820',
                                      style: const TextStyle(color: GlossyColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // WireGuard Switch Row
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tunnel Interface wg0',
                                    style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'ChaCha20-Poly1305 • Sub-25ms Latency',
                                    style: TextStyle(color: GlossyColors.textMuted, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: network?.wireguardEnabled ?? false,
                              activeThumbColor: GlossyColors.emeraldMint,
                              activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                              onChanged: _isActionPending
                                  ? null
                                  : (val) => _runAction('WireGuard Tunnel', () => widget.controller.toggleWireguard(val)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5. Multi-WAN Failover & Load Balancing Card (Feature 30)
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.alt_route_rounded, color: GlossyColors.lightBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Multi-WAN Failover & Backup',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlossyBadge(
                              label: network?.multiWanEnabled == true ? 'Dual-WAN' : 'Single WAN',
                              dotColor: network?.multiWanEnabled == true
                                  ? GlossyColors.emeraldMint
                                  : GlossyColors.textMuted,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Automated 3-second link health failover using mwan3. Automatically routes traffic to secondary ISP on LAN Port 4 if primary Fiber WAN link drops.',
                          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 12),

                        // Link Status
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.fiber_manual_record, size: 10, color: GlossyColors.emeraldMint),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'WAN 1: Fiber (Online)',
                                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.03),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: GlossyColors.glassBorderLight),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.fiber_manual_record,
                                      size: 10,
                                      color: network?.multiWanEnabled == true ? GlossyColors.amberWarm : GlossyColors.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    const Expanded(
                                      child: Text(
                                        'WAN 2: LAN 4 (Backup)',
                                        style: TextStyle(color: GlossyColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'mwan3 Multi-WAN Engine',
                                style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: network?.multiWanEnabled ?? false,
                              activeThumbColor: GlossyColors.emeraldMint,
                              activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                              onChanged: _isActionPending
                                  ? null
                                  : (val) => _runAction('Multi-WAN Failover', () => widget.controller.toggleMultiWan(val)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. DNS Privacy & Encryption Suite (Feature 25)
                  GlossyCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: GlossyColors.primaryBlue, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'DNS-over-HTTPS (DoH) Privacy',
                                style: TextStyle(
                                  color: GlossyColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GlossyBadge(
                              label: network?.dohEnabled == true ? 'Encrypted' : 'Standard DNS',
                              dotColor: network?.dohEnabled == true
                                  ? GlossyColors.emeraldMint
                                  : GlossyColors.amberWarm,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Encrypts all outbound DNS requests with https-dns-proxy over port 5053, completely preventing upstream ISP snooping and man-in-the-middle DNS manipulation.',
                          style: TextStyle(color: GlossyColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 10),

                        // Resolver Tag
                        InkWell(
                          onTap: () => _showDnsConfigModal(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.02),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: GlossyColors.glassBorderLight),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield_outlined, size: 13, color: GlossyColors.lightBlue),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Resolver: ${network?.dohProvider ?? "Cloudflare (1.1.1.1)"} • Tap to Configure',
                                    style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.tune_rounded, size: 12, color: GlossyColors.lightBlue),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'DoH Encryption Daemon',
                                style: TextStyle(color: GlossyColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Switch.adaptive(
                              value: network?.dohEnabled ?? true,
                              activeThumbColor: GlossyColors.emeraldMint,
                              activeTrackColor: GlossyColors.emeraldMint.withValues(alpha: 0.3),
                              onChanged: _isActionPending
                                  ? null
                                  : (val) => _runAction('DNS-over-HTTPS', () => widget.controller.toggleDoh(val)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static String _formatProtocol(String proto) {
    if (proto.contains('PPPoE')) return 'PPPoE';
    if (proto.contains('DHCP')) return 'DHCP';
    if (proto.contains('Static')) return 'Static IP';
    return proto;
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    VoidCallback? onTap,
    Widget? trailing,
    Widget? customBody,
  }) {
    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GlossyColors.glassBorderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: GlossyColors.textSecondary),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 4),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 4),
          customBody ??
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? GlossyColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                ),
              ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: tile,
      );
    }
    return tile;
  }

  Widget _buildTrafficStat(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(color: GlossyColors.textSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(
              color: GlossyColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
