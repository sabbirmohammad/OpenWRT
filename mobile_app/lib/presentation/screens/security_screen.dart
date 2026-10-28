import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../controllers/router_controller.dart';
import 'security/utils/security_action_handler.dart';
import 'security/utils/security_dialog_helper.dart';
import 'security/utils/security_score_helper.dart';
import 'security/widgets/security_blocklist_card.dart';
import 'security/widgets/security_doh_card.dart';
import 'security/widgets/security_pmf_card.dart';
import 'security/widgets/security_rebind_card.dart';
import 'security/widgets/security_score_card.dart';
import 'security/widgets/security_stealth_card.dart';
import 'security/widgets/security_threat_matrix_card.dart';
import 'security/widgets/security_wan_lock_card.dart';
import 'security/widgets/security_wireguard_card.dart';

class SecurityScreen extends StatefulWidget {
  final RouterController controller;

  const SecurityScreen({super.key, required this.controller});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isTogglingStealth = false;
  bool _isTogglingWireGuard = false;
  bool _isTogglingDoh = false;
  bool _isTogglingPmf = false;
  bool _isTogglingDnsRebind = false;
  bool _isTogglingWanLock = false;
  bool _isBlockingMac = false;
  bool _isAutoHardening = false;
  final TextEditingController _macBlockController = TextEditingController();

  @override
  void dispose() {
    _macBlockController.dispose();
    super.dispose();
  }

  Future<void> _handleTogglePmf() async {
    setState(() => _isTogglingPmf = true);
    await SecurityActionHandler.togglePmf(context, widget.controller);
    if (mounted) setState(() => _isTogglingPmf = false);
  }

  Future<void> _handleToggleDnsRebind() async {
    setState(() => _isTogglingDnsRebind = true);
    await SecurityActionHandler.toggleDnsRebind(context, widget.controller);
    if (mounted) setState(() => _isTogglingDnsRebind = false);
  }

  Future<void> _handleToggleWanLock() async {
    setState(() => _isTogglingWanLock = true);
    await SecurityActionHandler.toggleWanLockdown(context, widget.controller);
    if (mounted) setState(() => _isTogglingWanLock = false);
  }

  Future<void> _handleToggleStealth() async {
    setState(() => _isTogglingStealth = true);
    await SecurityActionHandler.toggleStealth(context, widget.controller);
    if (mounted) setState(() => _isTogglingStealth = false);
  }

  Future<void> _handleToggleWireguard(bool enable) async {
    setState(() => _isTogglingWireGuard = true);
    await SecurityActionHandler.toggleWireguard(context, widget.controller, enable);
    if (mounted) setState(() => _isTogglingWireGuard = false);
  }

  Future<void> _handleToggleDoh(bool enable) async {
    setState(() => _isTogglingDoh = true);
    await SecurityActionHandler.toggleDoh(context, widget.controller, enable);
    if (mounted) setState(() => _isTogglingDoh = false);
  }

  Future<void> _handleBlockCustomMac() async {
    setState(() => _isBlockingMac = true);
    final ok = await SecurityActionHandler.blockCustomMac(context, widget.controller, _macBlockController.text);
    if (ok) _macBlockController.clear();
    if (mounted) setState(() => _isBlockingMac = false);
  }

  Future<void> _handleAutoHarden() async {
    setState(() => _isAutoHardening = true);
    await SecurityActionHandler.autoHardenAll(context, widget.controller);
    if (mounted) setState(() => _isAutoHardening = false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final status = widget.controller.status;
        final score = SecurityScoreHelper.calculateScore(status);
        final scoreColor = SecurityScoreHelper.getScoreColor(score);
        final isStealth = status?.stealthLeds ?? false;
        final isWgActive = status?.network.wireguardEnabled ?? false;
        final isDohActive = status?.network.dohEnabled ?? false;
        final isPmfActive = status?.wireless.pmfProtected ?? false;
        final isRebindActive = status?.network.dnsRebindProtection ?? false;
        final isWanLockActive = status?.network.wanLockdown ?? false;
        final clients = status?.clients ?? [];
        final blockedClients = clients.where((c) => c.blocked).toList();

        return Scaffold(
          backgroundColor: GlossyColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GlossyColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('Security Hub', style: TextStyle(color: GlossyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
            actions: [
              IconButton(icon: const Icon(Icons.refresh_rounded, color: GlossyColors.textSecondary), onPressed: () => widget.controller.refresh()),
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
                  SecurityScoreCard(
                    score: score,
                    scoreRatingText: SecurityScoreHelper.getRatingText(score),
                    scoreColor: scoreColor,
                    isPmfActive: isPmfActive,
                    isRebindActive: isRebindActive,
                    isDohActive: isDohActive,
                    onOpenAudit: () => SecurityDialogHelper.showAuditSheet(
                      context,
                      status: status,
                      isAutoHardening: _isAutoHardening,
                      onAutoHarden: _handleAutoHarden,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SecurityBlocklistCard(
                    clients: clients,
                    blockedClients: blockedClients,
                    macController: _macBlockController,
                    isBlockingMac: _isBlockingMac,
                    onSelectConnectedDevice: () => SecurityDialogHelper.showDevicePicker(
                      context,
                      clients: clients,
                      onKickClient: (mac, host) => SecurityActionHandler.kickClient(context, widget.controller, mac, host),
                      onBlockClient: (mac) => widget.controller.blockClient(mac),
                      onUnblockClient: (mac) => SecurityActionHandler.unblockClient(context, widget.controller, mac),
                    ),
                    onBlockCustomMac: _handleBlockCustomMac,
                    onUnblockClient: (mac) => SecurityActionHandler.unblockClient(context, widget.controller, mac),
                  ),
                  const SizedBox(height: 16),
                  SecurityPmfCard(isPmfActive: isPmfActive, isTogglingPmf: _isTogglingPmf, onToggle: _handleTogglePmf),
                  const SizedBox(height: 16),
                  SecurityRebindCard(isRebindActive: isRebindActive, isTogglingDnsRebind: _isTogglingDnsRebind, onToggle: _handleToggleDnsRebind),
                  const SizedBox(height: 16),
                  SecurityWanLockCard(isWanLockActive: isWanLockActive, isTogglingWanLock: _isTogglingWanLock, onToggle: _handleToggleWanLock),
                  const SizedBox(height: 16),
                  SecurityWireguardCard(isWgActive: isWgActive, isTogglingWireGuard: _isTogglingWireGuard, onToggle: _handleToggleWireguard),
                  const SizedBox(height: 16),
                  SecurityDohCard(isDohActive: isDohActive, isTogglingDoh: _isTogglingDoh, onToggle: _handleToggleDoh),
                  const SizedBox(height: 16),
                  SecurityStealthCard(isStealth: isStealth, isTogglingStealth: _isTogglingStealth, onToggle: _handleToggleStealth),
                  const SizedBox(height: 16),
                  SecurityThreatMatrixCard(isPmfActive: isPmfActive, isRebindActive: isRebindActive, isWanLockActive: isWanLockActive),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
