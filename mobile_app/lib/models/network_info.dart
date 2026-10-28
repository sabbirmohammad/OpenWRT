import '../core/utils/formatters.dart';

class NetworkInfo {
  final bool hwOffload;
  final bool flowOffloadingHw;
  final bool sqmEnabled;
  final String sqmQdisc;
  final int sqmDownloadKbit;
  final int sqmUploadKbit;
  final String gateway;
  final String dns;
  final String protocol;
  final int mtu;
  final double latencyMs;
  final double jitterMs;
  final bool wireguardEnabled;
  final String wireguardInterface;
  final String wireguardEndpoint;
  final String wireguardStatus;
  final String wireguardLatestHandshake;
  final int wireguardTransferRx;
  final int wireguardTransferTx;
  final bool multiWanEnabled;
  final String multiWanMode;
  final String multiWanWan1;
  final String multiWanWan2;
  final bool dohEnabled;
  final String dohProvider;
  final bool dnsRebindProtection;
  final bool wanLockdown;

  NetworkInfo({
    required this.hwOffload,
    this.flowOffloadingHw = true,
    required this.sqmEnabled,
    this.sqmQdisc = 'cake',
    this.sqmDownloadKbit = 95000,
    this.sqmUploadKbit = 20000,
    required this.gateway,
    required this.dns,
    required this.protocol,
    this.mtu = 1492,
    this.latencyMs = 8.5,
    this.jitterMs = 0.9,
    this.wireguardEnabled = false,
    this.wireguardInterface = 'wg0',
    this.wireguardEndpoint = '10.14.0.1:51820',
    this.wireguardStatus = 'standby',
    this.wireguardLatestHandshake = 'Never',
    this.wireguardTransferRx = 0,
    this.wireguardTransferTx = 0,
    this.multiWanEnabled = false,
    this.multiWanMode = 'failover',
    this.multiWanWan1 = 'online',
    this.multiWanWan2 = 'standby',
    this.dohEnabled = true,
    this.dohProvider = 'Cloudflare (1.1.1.1)',
    this.dnsRebindProtection = true,
    this.wanLockdown = true,
  });

  double get sqmDownloadMbps => sqmDownloadKbit / 1000.0;
  double get sqmUploadMbps => sqmUploadKbit / 1000.0;
  String get formattedWireguardRx => Formatters.formatBytes(wireguardTransferRx);
  String get formattedWireguardTx => Formatters.formatBytes(wireguardTransferTx);

  String get dnsProviderName {
    final clean = dns.replaceAll(' ', '');
    if (clean.contains('1.1.1.1') || clean.contains('1.0.0.1')) return 'Cloudflare DNS';
    if (clean.contains('8.8.8.8') || clean.contains('8.8.4.4')) return 'Google DNS';
    if (clean.contains('94.140.14.14') || clean.contains('94.140.15.15')) return 'AdGuard DNS';
    if (clean.contains('9.9.9.9') || clean.contains('149.112.112.112')) return 'Quad9 DNS';
    if (clean.isEmpty || clean == 'auto') return 'ISP Default (Auto)';
    return 'Custom DNS';
  }

  List<String> get dnsList {
    if (dns.isEmpty || dns.toLowerCase().contains('auto')) return [];
    return dns
        .split(RegExp(r'[, ]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s != 'auto')
        .toList();
  }

  String get primaryDns {
    final list = dnsList;
    if (list.isNotEmpty) return list.first;
    if (dns.toLowerCase().contains('auto') || dns.isEmpty) return 'Auto (ISP)';
    return '1.1.1.1';
  }

  String get secondaryDns {
    final list = dnsList;
    return list.length > 1 ? list[1] : '';
  }

  factory NetworkInfo.fromJson(Map<String, dynamic> json) {
    final hw = json['hw_offload'] as Map<String, dynamic>? ?? {};
    final sqm = json['sqm'] as Map<String, dynamic>? ?? {};
    final wan = json['wan_details'] as Map<String, dynamic>? ?? {};
    final wg = json['wireguard'] as Map<String, dynamic>? ?? {};
    final mwan = json['multi_wan'] as Map<String, dynamic>? ?? {};
    final doh = json['doh'] as Map<String, dynamic>? ?? {};

    return NetworkInfo(
      hwOffload: hw['enabled'] == true,
      flowOffloadingHw: hw['flow_offloading_hw'] != false,
      sqmEnabled: sqm['enabled'] == true,
      sqmQdisc: sqm['qdisc'] as String? ?? 'cake',
      sqmDownloadKbit: (sqm['download_kbit'] as num?)?.toInt() ?? 95000,
      sqmUploadKbit: (sqm['upload_kbit'] as num?)?.toInt() ?? 20000,
      gateway: wan['gateway'] as String? ?? '',
      dns: wan['dns'] as String? ?? '',
      protocol: wan['protocol'] as String? ?? 'DHCP',
      mtu: (wan['mtu'] as num?)?.toInt() ?? 1492,
      latencyMs: (wan['latency_ms'] as num?)?.toDouble() ?? 8.5,
      jitterMs: (wan['jitter_ms'] as num?)?.toDouble() ?? 0.9,
      wireguardEnabled: wg['enabled'] == true,
      wireguardInterface: wg['interface'] as String? ?? 'wg0',
      wireguardEndpoint: wg['endpoint'] as String? ?? '10.14.0.1:51820',
      wireguardStatus: wg['status'] as String? ?? 'standby',
      wireguardLatestHandshake: wg['latest_handshake'] as String? ?? 'Never',
      wireguardTransferRx: (wg['transfer_rx'] as num?)?.toInt() ?? 0,
      wireguardTransferTx: (wg['transfer_tx'] as num?)?.toInt() ?? 0,
      multiWanEnabled: mwan['enabled'] == true,
      multiWanMode: mwan['mode'] as String? ?? 'failover',
      multiWanWan1: mwan['wan1'] as String? ?? 'online',
      multiWanWan2: mwan['wan2'] as String? ?? 'standby',
      dohEnabled: doh['enabled'] == true,
      dohProvider: doh['provider'] as String? ?? 'Cloudflare (1.1.1.1)',
      dnsRebindProtection: (json['dns_rebind_protection'] ?? json['rebind_protection']) != false,
      wanLockdown: (json['wan_lockdown'] ?? json['wan_block']) != false,
    );
  }
}
