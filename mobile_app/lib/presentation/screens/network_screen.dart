import 'package:flutter/material.dart';
import '../../core/theme/glossy_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../controllers/router_controller.dart';
import '../widgets/glossy_badge.dart';
import 'network/modals/dns_config_modal.dart';
import 'network/modals/sqm_tune_modal.dart';
import 'network/widgets/doh_privacy_card.dart';
import 'network/widgets/hw_offload_card.dart';
import 'network/widgets/multi_wan_card.dart';
import 'network/widgets/network_wireguard_card.dart';
import 'network/widgets/sqm_qos_card.dart';
import 'network/widgets/wan_gateway_card.dart';

class NetworkScreen extends StatefulWidget {
  final RouterController controller;

  const NetworkScreen({super.key, required this.controller});

  @override
  State<NetworkScreen> createState() => _NetworkScreenState();
}

class _NetworkScreenState extends State<NetworkScreen> {
  Future<void> _runAction(String name, Future<void> Function() action) async {
    try {
      await action();
      if (mounted) {
        AppFeedback.showSuccess(context, '$name updated successfully.');
      }
    } catch (e) {
      if (mounted) {
        AppFeedback.showError(context, '$name update failed: $e');
      }
    }
  }

  void _showSqmTuneModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlossyColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SqmTuneModal(
        network: widget.controller.status?.network,
        onApply: ({required qdisc, required downloadKbit, required uploadKbit}) {
          _runAction(
            'SQM Tuning',
            () => widget.controller.updateSqmConfig(
              enabled: true,
              qdisc: qdisc,
              downloadKbit: downloadKbit,
              uploadKbit: uploadKbit,
            ),
          );
        },
      ),
    );
  }

  void _showDnsConfigModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: GlossyColors.backgroundSecondary,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DnsConfigModal(
        network: widget.controller.status?.network,
        onApply: (primary, secondary) {
          _runAction(
            'Upstream DNS',
            () => widget.controller.setCustomDns(primary: primary, secondary: secondary),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final status = widget.controller.status;
        final network = status?.network;
        final traffic = status?.traffic;
        final isWanConnected = traffic?.wanIp.isNotEmpty == true && traffic?.wanIp != '0.0.0.0';

        return Scaffold(
          backgroundColor: GlossyColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: GlossyColors.textPrimary, size: 20),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text(
              'Network & Acceleration',
              style: TextStyle(color: GlossyColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: GlossyBadge(
                    label: isWanConnected ? 'WAN Online' : 'WAN Offline',
                    dotColor: isWanConnected ? GlossyColors.emeraldMint : GlossyColors.roseCoral,
                  ),
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
                  WanGatewayCard(
                    network: network,
                    traffic: traffic,
                    onOpenDnsModal: () => _showDnsConfigModal(context),
                  ),
                  const SizedBox(height: 16),
                  HwOffloadCard(
                    network: network,
                    onToggle: (val) => _runAction('Hardware Offload', () => widget.controller.toggleHwOffload(val)),
                  ),
                  const SizedBox(height: 16),
                  SqmQosCard(
                    network: network,
                    onToggle: (val) => _runAction('SQM QoS', () => widget.controller.toggleSqm(val)),
                    onOpenTuneModal: () => _showSqmTuneModal(context),
                  ),
                  const SizedBox(height: 16),
                  NetworkWireguardCard(
                    network: network,
                    onToggle: (val) => _runAction('WireGuard VPN', () => widget.controller.toggleWireguard(val)),
                  ),
                  const SizedBox(height: 16),
                  MultiWanCard(
                    network: network,
                    onToggle: (val) => _runAction('Multi-WAN Failover', () => widget.controller.toggleMultiWan(val)),
                  ),
                  const SizedBox(height: 16),
                  DohPrivacyCard(
                    network: network,
                    onToggle: (val) => _runAction('DNS-over-HTTPS', () => widget.controller.toggleDoh(val)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
