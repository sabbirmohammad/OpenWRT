import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../core/utils/clipboard_helper.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/network_info.dart';
import '../../../../models/traffic_info.dart';
import '../../../widgets/glossy_badge.dart';
import '../../../widgets/glossy_card.dart';
import 'wan_metric_tile.dart';
import 'wan_traffic_stat.dart';

class WanGatewayCard extends StatelessWidget {
  final NetworkInfo? network;
  final TrafficInfo? traffic;
  final VoidCallback onOpenDnsModal;

  const WanGatewayCard({
    super.key,
    required this.network,
    required this.traffic,
    required this.onOpenDnsModal,
  });

  String _formatProtocol(String proto) {
    if (proto.contains('PPPoE')) return 'PPPoE (Fiber)';
    if (proto.contains('DHCP')) return 'DHCP Client';
    if (proto.contains('Static')) return 'Static IP';
    return proto;
  }

  @override
  Widget build(BuildContext context) {
    return GlossyCard(
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
          Row(
            children: [
              Expanded(
                child: WanMetricTile(
                  label: 'Public WAN IP',
                  value: traffic?.wanIp ?? '0.0.0.0',
                  icon: Icons.language,
                  valueColor: GlossyColors.emeraldMint,
                  trailing: const Icon(Icons.copy_rounded, size: 12, color: GlossyColors.textMuted),
                  onTap: () => ClipboardHelper.copy(context, traffic?.wanIp ?? '0.0.0.0', 'Public WAN IP'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WanMetricTile(
                  label: 'Gateway IP',
                  value: network?.gateway.isNotEmpty == true ? network!.gateway : '0.0.0.0',
                  icon: Icons.router_outlined,
                  onTap: () => ClipboardHelper.copy(context, network?.gateway ?? '0.0.0.0', 'Gateway IP'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: WanMetricTile(
                  label: 'DNS • ${network?.dnsProviderName ?? "Live"}',
                  value: network?.dns.isNotEmpty == true ? network!.dns : '1.1.1.1, 8.8.8.8',
                  icon: Icons.dns_outlined,
                  trailing: const Icon(Icons.tune_rounded, size: 12, color: GlossyColors.lightBlue),
                  onTap: onOpenDnsModal,
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
                child: WanMetricTile(
                  label: 'Interface & MTU',
                  value: '${traffic?.interfaceName ?? "eth0.2"} • ${network?.mtu ?? 1492}B',
                  icon: Icons.cable_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
              Expanded(
                child: WanTrafficStat(
                  label: 'WAN Ingress (DL)',
                  value: Formatters.formatBytes(traffic?.rxBytes ?? 0),
                  icon: Icons.arrow_downward_rounded,
                  color: GlossyColors.emeraldMint,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: WanTrafficStat(
                  label: 'WAN Egress (UL)',
                  value: Formatters.formatBytes(traffic?.txBytes ?? 0),
                  icon: Icons.arrow_upward_rounded,
                  color: GlossyColors.lightBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
