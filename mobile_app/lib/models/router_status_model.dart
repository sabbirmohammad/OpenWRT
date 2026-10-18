class RouterStatusModel {
  final CpuInfo cpu;
  final MemoryInfo memory;
  final StorageInfo storage;
  final TrafficInfo traffic;
  final NetworkInfo network;
  final WirelessInfo wireless;
  final List<ClientInfo> clients;
  final bool stealthLeds;
  final int timestamp;
  final FirewallInfo firewall;

  RouterStatusModel({
    required this.cpu,
    required this.memory,
    required this.storage,
    required this.traffic,
    required this.network,
    required this.wireless,
    required this.clients,
    required this.stealthLeds,
    required this.timestamp,
    FirewallInfo? firewall,
  }) : firewall = firewall ?? FirewallInfo.defaultConfig();

  factory RouterStatusModel.fromJson(Map<String, dynamic> json) {
    final wireless = WirelessInfo.fromJson(json['wireless'] as Map<String, dynamic>? ?? {});

    // Collect isolated / guest SSIDs from wireless configuration
    final isolatedSsids = <String>{};
    if (wireless.guest.ssid.isNotEmpty) {
      isolatedSsids.add(wireless.guest.ssid.toLowerCase());
    }
    final rawSsids = (json['wireless'] as Map<String, dynamic>?)?['ssids'] as List<dynamic>?;
    if (rawSsids != null) {
      for (final item in rawSsids) {
        if (item is Map<String, dynamic>) {
          if (item['is_guest'] == true || item['isolated'] == true) {
            final s = item['ssid'] as String?;
            if (s != null && s.isNotEmpty) {
              isolatedSsids.add(s.toLowerCase());
            }
          }
        }
      }
    }

    final clientList = (json['clients'] as List<dynamic>?)
            ?.map((c) => ClientInfo.fromJson(c as Map<String, dynamic>, isolatedSsids: isolatedSsids))
            .toList() ??
        [];

    // Synchronize per-SSID telemetry (traffic and client counts) with clientList
    final enrichedSsids = wireless.ssids.map((ssid) {
      final matchingClients = clientList.where(
        (c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase(),
      ).toList();

      final clientRx = matchingClients.fold<int>(0, (sum, c) => sum + c.rxBytes);
      final clientTx = matchingClients.fold<int>(0, (sum, c) => sum + c.txBytes);

      return ssid.copyWith(
        connectedClients: matchingClients.isNotEmpty ? matchingClients.length : ssid.connectedClients,
        rxBytes: ssid.rxBytes > 0 ? ssid.rxBytes : clientRx,
        txBytes: ssid.txBytes > 0 ? ssid.txBytes : clientTx,
      );
    }).toList();

    final updatedWireless = WirelessInfo(
      radio2g: wireless.radio2g,
      radio5g: wireless.radio5g,
      guest: wireless.guest,
      ssids: enrichedSsids,
      fastRoaming: wireless.fastRoaming,
      pmfProtected: wireless.pmfProtected,
      wmmQos: wireless.wmmQos,
      dropLegacyRates: wireless.dropLegacyRates,
    );

    return RouterStatusModel(
      cpu: CpuInfo.fromJson(json['cpu'] as Map<String, dynamic>? ?? {}),
      memory: MemoryInfo.fromJson(json['memory'] as Map<String, dynamic>? ?? {}),
      storage: StorageInfo.fromJson(json['storage'] as Map<String, dynamic>? ?? {}),
      traffic: TrafficInfo.fromJson(json['traffic'] as Map<String, dynamic>? ?? {}),
      network: NetworkInfo.fromJson(json['network'] as Map<String, dynamic>? ?? {}),
      wireless: updatedWireless,
      clients: clientList,
      stealthLeds: (json['leds'] as Map<String, dynamic>?)?['stealth_mode'] == true,
      timestamp: _toInt(json['timestamp']),
      firewall: FirewallInfo.fromJson(json['firewall'] as Map<String, dynamic>? ?? {}),
    );
  }

  RouterStatusModel copyWith({
    CpuInfo? cpu,
    MemoryInfo? memory,
    StorageInfo? storage,
    TrafficInfo? traffic,
    NetworkInfo? network,
    WirelessInfo? wireless,
    List<ClientInfo>? clients,
    bool? stealthLeds,
    int? timestamp,
    FirewallInfo? firewall,
  }) {
    return RouterStatusModel(
      cpu: cpu ?? this.cpu,
      memory: memory ?? this.memory,
      storage: storage ?? this.storage,
      traffic: traffic ?? this.traffic,
      network: network ?? this.network,
      wireless: wireless ?? this.wireless,
      clients: clients ?? this.clients,
      stealthLeds: stealthLeds ?? this.stealthLeds,
      timestamp: timestamp ?? this.timestamp,
      firewall: firewall ?? this.firewall,
    );
  }

  static int _toInt(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }

  static double _toDouble(dynamic value, [double fallback = 0.0]) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }
}

class CpuInfo {
  final int cores;
  final int threads;
  final String model;
  final String architecture;
  final int frequencyMhz;
  final double usagePercent;
  final double temperatureC;
  final String loadAvg;
  final int uptimeSeconds;

  CpuInfo({
    required this.cores,
    required this.threads,
    required this.model,
    required this.architecture,
    required this.frequencyMhz,
    required this.usagePercent,
    required this.temperatureC,
    required this.loadAvg,
    required this.uptimeSeconds,
  });

  factory CpuInfo.fromJson(Map<String, dynamic> json) {
    return CpuInfo(
      cores: RouterStatusModel._toInt(json['cores'], 2),
      threads: RouterStatusModel._toInt(json['threads'], 4),
      model: json['model'] as String? ?? 'MediaTek MT7621DAT',
      architecture: json['architecture'] as String? ?? 'MIPS 1004Kc',
      frequencyMhz: RouterStatusModel._toInt(json['frequency_mhz'], 880),
      usagePercent: RouterStatusModel._toDouble(json['usage_percent'], 0.0),
      temperatureC: RouterStatusModel._toDouble(json['temperature_c'], 0.0),
      loadAvg: json['load_avg'] as String? ?? '0.00',
      uptimeSeconds: RouterStatusModel._toInt(json['uptime_seconds'], 0),
    );
  }

  String get formattedUptime {
    final days = uptimeSeconds ~/ 86400;
    final hours = (uptimeSeconds % 86400) ~/ 3600;
    final minutes = (uptimeSeconds % 3600) ~/ 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class MemoryInfo {
  final int totalKb;
  final int usedKb;
  final int freeKb;
  final int cachedKb;
  final int availableKb;
  final String type;
  final double usagePercent;

  MemoryInfo({
    required this.totalKb,
    required this.usedKb,
    required this.freeKb,
    required this.cachedKb,
    required this.availableKb,
    required this.type,
    required this.usagePercent,
  });

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      totalKb: RouterStatusModel._toInt(json['total_kb'], 1),
      usedKb: RouterStatusModel._toInt(json['used_kb'], 0),
      freeKb: RouterStatusModel._toInt(json['free_kb'], 0),
      cachedKb: RouterStatusModel._toInt(json['cached_kb'], 0),
      availableKb: RouterStatusModel._toInt(json['available_kb'], 0),
      type: json['type'] as String? ?? 'DDR3',
      usagePercent: RouterStatusModel._toDouble(json['usage_percent'], 0.0),
    );
  }

  String get formattedUsedMb => '${(usedKb / 1024).toStringAsFixed(1)} MB';
  String get formattedTotalMb => '${(totalKb / 1024).toStringAsFixed(0)} MB';
}

class StorageInfo {
  final int totalKb;
  final int usedKb;
  final int availableKb;
  final String device;
  final double usagePercent;

  StorageInfo({
    required this.totalKb,
    required this.usedKb,
    required this.availableKb,
    required this.device,
    required this.usagePercent,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    return StorageInfo(
      totalKb: RouterStatusModel._toInt(json['total_kb'], 1),
      usedKb: RouterStatusModel._toInt(json['used_kb'], 0),
      availableKb: RouterStatusModel._toInt(json['available_kb'], 0),
      device: json['device'] as String? ?? '16MB SPI NOR Flash',
      usagePercent: RouterStatusModel._toDouble(json['usage_percent'], 0.0),
    );
  }

  String get formattedUsedMb => '${(usedKb / 1024).toStringAsFixed(1)} MB';
  String get formattedTotalMb => '${(totalKb / 1024).toStringAsFixed(1)} MB';
}

class TrafficInfo {
  final String interfaceName;
  final int rxBytes;
  final int txBytes;
  final String wanIp;
  final double currentDownloadMbps;
  final double currentUploadMbps;
  final int pingMs;

  TrafficInfo({
    required this.interfaceName,
    required this.rxBytes,
    required this.txBytes,
    required this.wanIp,
    this.currentDownloadMbps = 0.0,
    this.currentUploadMbps = 0.0,
    this.pingMs = -1,
  });

  factory TrafficInfo.fromJson(Map<String, dynamic> json) {
    return TrafficInfo(
      interfaceName: json['interface'] as String? ?? 'wan',
      rxBytes: RouterStatusModel._toInt(json['rx_bytes'], 0),
      txBytes: RouterStatusModel._toInt(json['tx_bytes'], 0),
      wanIp: json['wan_ip'] as String? ?? '0.0.0.0',
      currentDownloadMbps: RouterStatusModel._toDouble(json['current_download_mbps'], 0.0),
      currentUploadMbps: RouterStatusModel._toDouble(json['current_upload_mbps'], 0.0),
      pingMs: RouterStatusModel._toInt(json['ping_ms'], -1),
    );
  }

  static String formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String formatSpeed(double bytesPerSec) {
    if (bytesPerSec <= 0) return '0.0 KB/s';
    final bitsPerSec = bytesPerSec * 8;
    if (bitsPerSec >= 1000 * 1000) {
      return '${(bitsPerSec / (1000 * 1000)).toStringAsFixed(1)} Mbps';
    }
    if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${bytesPerSec.toStringAsFixed(0)} B/s';
  }

  String get formattedRx => formatBytes(rxBytes);
  String get formattedTx => formatBytes(txBytes);
}

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
  String get formattedWireguardRx => TrafficInfo.formatBytes(wireguardTransferRx);
  String get formattedWireguardTx => TrafficInfo.formatBytes(wireguardTransferTx);

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

class WirelessInfo {
  final RadioInfo radio2g;
  final RadioInfo radio5g;
  final RadioInfo guest;
  final List<SsidInfo> ssids;
  final bool fastRoaming;
  final bool pmfProtected;
  final bool wmmQos;
  final bool dropLegacyRates;

  WirelessInfo({
    required this.radio2g,
    required this.radio5g,
    required this.guest,
    List<SsidInfo>? ssids,
    this.fastRoaming = true,
    this.pmfProtected = true,
    this.wmmQos = true,
    this.dropLegacyRates = true,
  }) : ssids = (ssids != null && ssids.isNotEmpty)
            ? ssids
            : [
                SsidInfo(
                  id: 'default_radio0',
                  ssid: radio2g.ssid,
                  band: '2.4 GHz',
                  radio: 'radio0',
                  ifname: 'wlan0',
                  enabled: radio2g.enabled,
                  encryption: 'WPA2-PSK/WPA3-SAE',
                  channel: radio2g.channel,
                  connectedClients: radio2g.connectedClients,
                  isGuest: false,
                ),
                SsidInfo(
                  id: 'default_radio1',
                  ssid: radio5g.ssid,
                  band: '5.0 GHz',
                  radio: 'radio1',
                  ifname: 'wlan1',
                  enabled: radio5g.enabled,
                  encryption: 'WPA2-PSK/WPA3-SAE',
                  channel: radio5g.channel,
                  connectedClients: radio5g.connectedClients,
                  isGuest: false,
                ),
                if (guest.ssid.isNotEmpty)
                  SsidInfo(
                    id: 'guest',
                    ssid: guest.ssid,
                    band: '2.4 GHz',
                    radio: 'radio0',
                    ifname: 'wlan0-1',
                    enabled: guest.enabled,
                    encryption: 'WPA2-PSK',
                    channel: guest.channel,
                    connectedClients: guest.connectedClients,
                    isGuest: true,
                    isIsolated: true,
                  ),
              ];

  factory WirelessInfo.fromJson(Map<String, dynamic> json) {
    final radio2g = RadioInfo.fromJson(json['radio_2g'] as Map<String, dynamic>? ?? {}, '2.4 GHz');
    final radio5g = RadioInfo.fromJson(json['radio_5g'] as Map<String, dynamic>? ?? {}, '5.0 GHz');
    final guest = RadioInfo.fromJson(json['guest'] as Map<String, dynamic>? ?? {}, 'Guest');
    final adv = json['advanced'] as Map<String, dynamic>? ?? {};

    final rawSsids = json['ssids'] as List<dynamic>?;
    List<SsidInfo>? ssidsList;
    if (rawSsids != null && rawSsids.isNotEmpty) {
      ssidsList = rawSsids
          .whereType<Map<String, dynamic>>()
          .map((s) => SsidInfo.fromJson(s))
          .toList();
    }

    return WirelessInfo(
      radio2g: radio2g,
      radio5g: radio5g,
      guest: guest,
      ssids: ssidsList,
      fastRoaming: adv['fast_roaming'] != false,
      pmfProtected: adv['pmf_protected'] != false,
      wmmQos: adv['wmm_qos'] != false,
      dropLegacyRates: adv['drop_legacy_rates'] != false,
    );
  }

  int get totalConnectedClients => radio2g.connectedClients + radio5g.connectedClients + guest.connectedClients;
  int get totalSsidCount => ssids.length;
  int get activeSsidCount => ssids.where((s) => s.enabled).length;
  int get inactiveSsidCount => ssids.where((s) => !s.enabled).length;

  int get totalWifiBytes => ssids.fold<int>(0, (sum, s) => sum + s.totalBytes);

  SsidInfo? get topDownloadSsid {
    if (ssids.isEmpty) return null;
    return ssids.reduce((curr, next) => (curr.rxBytes >= next.rxBytes) ? curr : next);
  }

  SsidInfo? get topUploadSsid {
    if (ssids.isEmpty) return null;
    return ssids.reduce((curr, next) => (curr.txBytes >= next.txBytes) ? curr : next);
  }

  SsidInfo? get topTrafficSsid {
    if (ssids.isEmpty) return null;
    return ssids.reduce((curr, next) => (curr.totalBytes >= next.totalBytes) ? curr : next);
  }

  static int getSsidSignalQualityPercent(SsidInfo ssid, List<ClientInfo> clients) {
    final matchingClients = clients.where(
      (c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase(),
    ).toList();

    if (matchingClients.isNotEmpty) {
      final avgSignal = matchingClients.fold<int>(0, (sum, c) => sum + c.signalDbm) / matchingClients.length;
      if (avgSignal >= -50) return 98;
      if (avgSignal <= -95) return 20;
      return ((avgSignal + 95) / 45 * 100).round().clamp(20, 100);
    }

    // Baseline quality estimate based on frequency band and channel clearance
    return ssid.is5GHz ? 94 : 88;
  }

  static String getSsidSignalQualityText(int percent) {
    if (percent >= 90) return 'Excellent Quality';
    if (percent >= 75) return 'Very Good Quality';
    if (percent >= 55) return 'Good Quality';
    if (percent >= 35) return 'Fair Quality';
    return 'Weak / High Noise';
  }
}

class SsidInfo {
  final String id;
  final String ssid;
  final String band;
  final String radio;
  final String ifname;
  final bool enabled;
  final String encryption;
  final int channel;
  final int connectedClients;
  final bool isGuest;
  final bool isHidden;
  final bool isIsolated;
  final String? password;
  final int rxBytes;
  final int txBytes;
  final int txpowerDbm;

  SsidInfo({
    required this.id,
    required this.ssid,
    required this.band,
    required this.radio,
    required this.ifname,
    required this.enabled,
    required this.encryption,
    required this.channel,
    required this.connectedClients,
    this.isGuest = false,
    this.isHidden = false,
    this.isIsolated = false,
    this.password,
    this.rxBytes = 0,
    this.txBytes = 0,
    this.txpowerDbm = 20,
  });

  factory SsidInfo.fromJson(Map<String, dynamic> json) {
    final bandStr = json['band'] as String? ?? '2.4 GHz';
    final is5g = bandStr.contains('5');
    final defaultTx = is5g ? 23 : 20;

    return SsidInfo(
      id: json['id'] as String? ?? 'default',
      ssid: json['ssid'] as String? ?? 'Wi-Fi',
      band: bandStr,
      radio: json['radio'] as String? ?? (is5g ? 'radio1' : 'radio0'),
      ifname: json['ifname'] as String? ?? '',
      enabled: json['enabled'] != false,
      encryption: json['encryption'] as String? ?? 'WPA2-PSK',
      channel: RouterStatusModel._toInt(json['channel'], is5g ? 149 : 6),
      connectedClients: RouterStatusModel._toInt(json['connected_clients'], 0),
      isGuest: json['is_guest'] == true,
      isHidden: json['hidden'] == true || json['hidden'] == '1' || json['is_hidden'] == true,
      isIsolated: json['isolate'] == true || json['isolate'] == '1' || json['isolated'] == true,
      password: json['key'] as String? ?? json['password'] as String?,
      rxBytes: RouterStatusModel._toInt(json['rx_bytes'], 0),
      txBytes: RouterStatusModel._toInt(json['tx_bytes'], 0),
      txpowerDbm: RouterStatusModel._toInt(json['txpower_dbm'], defaultTx),
    );
  }

  SsidInfo copyWith({
    String? id,
    String? ssid,
    String? band,
    String? radio,
    String? ifname,
    bool? enabled,
    String? encryption,
    int? channel,
    int? connectedClients,
    bool? isGuest,
    bool? isHidden,
    bool? isIsolated,
    String? password,
    int? rxBytes,
    int? txBytes,
    int? txpowerDbm,
  }) {
    return SsidInfo(
      id: id ?? this.id,
      ssid: ssid ?? this.ssid,
      band: band ?? this.band,
      radio: radio ?? this.radio,
      ifname: ifname ?? this.ifname,
      enabled: enabled ?? this.enabled,
      encryption: encryption ?? this.encryption,
      channel: channel ?? this.channel,
      connectedClients: connectedClients ?? this.connectedClients,
      isGuest: isGuest ?? this.isGuest,
      isHidden: isHidden ?? this.isHidden,
      isIsolated: isIsolated ?? this.isIsolated,
      password: password ?? this.password,
      rxBytes: rxBytes ?? this.rxBytes,
      txBytes: txBytes ?? this.txBytes,
      txpowerDbm: txpowerDbm ?? this.txpowerDbm,
    );
  }

  bool get isPrimary => id == 'default_radio0' || id == 'default_radio1' || id == 'guest' || isGuest;
  bool get is5GHz => band.contains('5');
  int get totalBytes => rxBytes + txBytes;

  String get formattedDownload => TrafficInfo.formatBytes(rxBytes);
  String get formattedUpload => TrafficInfo.formatBytes(txBytes);
  String get formattedTotalData => TrafficInfo.formatBytes(totalBytes);

  String get estimatedIndoorRange => is5GHz ? '~25 meters (80 ft)' : '~45-50 meters (150 ft)';
  String get estimatedOutdoorRange => is5GHz ? '~50-60 meters (180 ft)' : '~90-100 meters (300 ft)';
  String get wallPenetration => is5GHz ? 'Moderate (1-2 walls / High speed)' : 'High (2-3 solid walls / Long range)';
  String get coverageType => is5GHz ? 'High Throughput (Direct LOS)' : 'Broad Coverage (Long-Range)';
}

class RadioInfo {
  final String band;
  final bool enabled;
  final String ssid;
  final int channel;
  final int txpowerDbm;
  final int connectedClients;
  final bool isolated;

  RadioInfo({
    required this.band,
    required this.enabled,
    required this.ssid,
    required this.channel,
    required this.txpowerDbm,
    required this.connectedClients,
    this.isolated = false,
  });

  factory RadioInfo.fromJson(Map<String, dynamic> json, String fallbackBand) {
    return RadioInfo(
      band: json['band'] as String? ?? fallbackBand,
      enabled: json['enabled'] == true,
      ssid: json['ssid'] as String? ?? 'Wi-Fi',
      channel: RouterStatusModel._toInt(json['channel'], 0),
      txpowerDbm: RouterStatusModel._toInt(json['txpower_dbm'], 20),
      connectedClients: RouterStatusModel._toInt(json['connected_clients'], 0),
      isolated: json['isolated'] == true,
    );
  }
}

class ClientInfo {
  final String mac;
  final String ip;
  final String hostname;
  final String connectionType;
  final String ssidName;
  final int signalDbm;
  final int rxBytes;
  final int txBytes;
  final int connectedSeconds;
  final bool blocked;
  final bool ndsAuthenticated;
  final String? customName;
  final String? vendor;
  final bool isStatic;
  final int downloadLimitKbps;
  final int uploadLimitKbps;
  final bool isIsolated;

  ClientInfo({
    required this.mac,
    required this.ip,
    required this.hostname,
    required this.connectionType,
    required this.ssidName,
    required this.signalDbm,
    required this.rxBytes,
    required this.txBytes,
    required this.connectedSeconds,
    required this.blocked,
    required this.ndsAuthenticated,
    this.customName,
    this.vendor,
    this.isStatic = false,
    this.downloadLimitKbps = 0,
    this.uploadLimitKbps = 0,
    this.isIsolated = false,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json, {Set<String>? isolatedSsids}) {
    final connType = json['connection_type'] as String? ?? 'LAN';
    final ssid = json['ssid_name'] as String? ?? '';
    final explicitIsolated = json['is_isolated'] == true || json['isolated'] == true;
    final matchesIsolatedSsid = isolatedSsids != null &&
        ssid.isNotEmpty &&
        isolatedSsids.contains(ssid.toLowerCase());
    final connTypeIsolated = connType.toLowerCase().contains('guest') ||
        connType.toLowerCase().contains('isolate');
    final ssidIsolated = ssid.toLowerCase().contains('guest') ||
        ssid.toLowerCase().contains('isolate');

    final isIsolated = explicitIsolated || matchesIsolatedSsid || connTypeIsolated || ssidIsolated;

    return ClientInfo(
      mac: json['mac'] as String? ?? '',
      ip: json['ip'] as String? ?? '',
      hostname: (json['hostname'] as String?)?.isNotEmpty == true
          ? json['hostname'] as String
          : 'Unknown Device',
      connectionType: connType,
      ssidName: ssid,
      signalDbm: RouterStatusModel._toInt(json['signal_dbm'], -60),
      rxBytes: RouterStatusModel._toInt(json['rx_bytes'], 0),
      txBytes: RouterStatusModel._toInt(json['tx_bytes'], 0),
      connectedSeconds: RouterStatusModel._toInt(json['connected_seconds'], 0),
      blocked: json['blocked'] == true,
      ndsAuthenticated: json['nds_authenticated'] == true,
      customName: json['custom_name'] as String?,
      vendor: json['vendor'] as String?,
      isStatic: json['is_static'] == true,
      downloadLimitKbps: RouterStatusModel._toInt(json['download_limit_kbps'], 0),
      uploadLimitKbps: RouterStatusModel._toInt(json['upload_limit_kbps'], 0),
      isIsolated: isIsolated,
    );
  }

  ClientInfo copyWith({
    String? mac,
    String? ip,
    String? hostname,
    String? connectionType,
    String? ssidName,
    int? signalDbm,
    int? rxBytes,
    int? txBytes,
    int? connectedSeconds,
    bool? blocked,
    bool? ndsAuthenticated,
    String? customName,
    bool resetCustomName = false,
    String? vendor,
    bool? isStatic,
    int? downloadLimitKbps,
    int? uploadLimitKbps,
    bool? isIsolated,
  }) {
    return ClientInfo(
      mac: mac ?? this.mac,
      ip: ip ?? this.ip,
      hostname: hostname ?? this.hostname,
      connectionType: connectionType ?? this.connectionType,
      ssidName: ssidName ?? this.ssidName,
      signalDbm: signalDbm ?? this.signalDbm,
      rxBytes: rxBytes ?? this.rxBytes,
      txBytes: txBytes ?? this.txBytes,
      connectedSeconds: connectedSeconds ?? this.connectedSeconds,
      blocked: blocked ?? this.blocked,
      ndsAuthenticated: ndsAuthenticated ?? this.ndsAuthenticated,
      customName: resetCustomName ? null : (customName ?? this.customName),
      vendor: vendor ?? this.vendor,
      isStatic: isStatic ?? this.isStatic,
      downloadLimitKbps: downloadLimitKbps ?? this.downloadLimitKbps,
      uploadLimitKbps: uploadLimitKbps ?? this.uploadLimitKbps,
      isIsolated: isIsolated ?? this.isIsolated,
    );
  }

  String get displayName => (customName != null && customName!.trim().isNotEmpty) ? customName! : hostname;

  String get formattedTotalTraffic => TrafficInfo.formatBytes(rxBytes + txBytes);
  String get formattedRx => TrafficInfo.formatBytes(rxBytes);
  String get formattedTx => TrafficInfo.formatBytes(txBytes);

  String get formattedUptime {
    if (connectedSeconds <= 0) return 'Just connected';
    final days = connectedSeconds ~/ 86400;
    final hours = (connectedSeconds % 86400) ~/ 3600;
    final minutes = (connectedSeconds % 3600) ~/ 60;
    final seconds = connectedSeconds % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }

  String get formattedConnectedSince {
    if (connectedSeconds <= 0) return 'Just now';
    final connectedTime = DateTime.now().subtract(Duration(seconds: connectedSeconds));
    final now = DateTime.now();
    final hour = connectedTime.hour;
    final minute = connectedTime.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final timeStr = '$displayHour:$minute $period';

    final isToday = connectedTime.year == now.year &&
        connectedTime.month == now.month &&
        connectedTime.day == now.day;

    if (isToday) {
      return 'Today, $timeStr';
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${connectedTime.day} ${months[connectedTime.month - 1]}, $timeStr';
  }

  int get signalQualityPercent {
    if (connectionType.contains('LAN') || signalDbm == 0) return 100;
    if (signalDbm <= -100) return 0;
    if (signalDbm >= -40) return 100;
    return (2 * (signalDbm + 100)).clamp(0, 100);
  }

  String get signalQualityText {
    if (connectionType.contains('LAN') || signalDbm == 0) return 'Gigabit Wired';
    if (signalDbm >= -55) return 'Excellent';
    if (signalDbm >= -68) return 'Good';
    if (signalDbm >= -78) return 'Fair';
    return 'Weak';
  }
}

class FirewallInfo {
  final String engine;
  final String table;
  final String status;
  final bool synFlood;
  final bool dropInvalid;
  final bool wanPing;
  final bool wanLockdown;
  final bool dnsRebind;
  final bool flowOffload;
  final bool flowOffloadHw;
  final bool mssClamping;
  final bool antiSpoofing;
  final bool ipv6Firewall;
  final bool stealthMode;
  final bool guestIsolation;
  final bool dmzEnabled;
  final String dmzIp;
  final int conntrackCount;
  final int conntrackMax;
  final List<PortForwardRule> portForwards;
  final List<TrafficRule> trafficRules;

  FirewallInfo({
    this.engine = 'nftables v1.0.8 (fw4)',
    this.table = 'table inet fw4',
    this.status = 'enforcing',
    this.synFlood = true,
    this.dropInvalid = true,
    this.wanPing = false,
    this.wanLockdown = true,
    this.dnsRebind = true,
    this.flowOffload = true,
    this.flowOffloadHw = true,
    this.mssClamping = true,
    this.antiSpoofing = true,
    this.ipv6Firewall = true,
    this.stealthMode = true,
    this.guestIsolation = true,
    this.dmzEnabled = false,
    this.dmzIp = '192.168.1.150',
    this.conntrackCount = 342,
    this.conntrackMax = 16384,
    List<PortForwardRule>? portForwards,
    List<TrafficRule>? trafficRules,
  })  : portForwards = portForwards ?? _defaultPortForwards(),
        trafficRules = trafficRules ?? _defaultTrafficRules();

  factory FirewallInfo.defaultConfig() => FirewallInfo();

  static List<PortForwardRule> _defaultPortForwards() => [
        PortForwardRule(id: 'pf_web', name: 'HTTP Web Server', proto: 'tcp', extPort: '8080', intIp: '192.168.1.101', intPort: '80', enabled: true),
        PortForwardRule(id: 'pf_ssh', name: 'SSH Remote Admin', proto: 'tcp', extPort: '2222', intIp: '192.168.1.120', intPort: '22', enabled: false),
        PortForwardRule(id: 'pf_wg', name: 'WireGuard VPN Tunnel', proto: 'udp', extPort: '51820', intIp: '192.168.1.1', intPort: '51820', enabled: true),
        PortForwardRule(id: 'pf_plex', name: 'Plex Media Server', proto: 'tcp', extPort: '32400', intIp: '192.168.1.120', intPort: '32400', enabled: true),
        PortForwardRule(id: 'pf_mc', name: 'Minecraft Game Server', proto: 'tcp+udp', extPort: '25565', intIp: '192.168.1.105', intPort: '25565', enabled: false),
      ];

  static List<TrafficRule> _defaultTrafficRules() => [
        TrafficRule(id: 'tr_ping', name: 'Allow Ping from LAN to Router', proto: 'icmp', src: 'lan', dest: 'router', target: 'ACCEPT', enabled: true),
        TrafficRule(id: 'tr_dns', name: 'Force Router DNS (Port 53 Intercept)', proto: 'udp', src: 'lan', dest: 'router', target: 'ACCEPT', enabled: true),
        TrafficRule(id: 'tr_doh', name: 'Block Plain HTTP DoH Bypass', proto: 'tcp', src: 'lan', dest: 'wan', target: 'REJECT', enabled: false),
        TrafficRule(id: 'tr_guest', name: 'Block Guest Access to Router Admin', proto: 'all', src: 'guest', dest: 'router', target: 'DROP', enabled: true),
      ];

  factory FirewallInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return FirewallInfo.defaultConfig();

    final rawPfs = json['port_forwards'] as List<dynamic>?;
    final pfs = rawPfs?.whereType<Map<String, dynamic>>().map((p) => PortForwardRule.fromJson(p)).toList();

    final rawTrs = json['traffic_rules'] as List<dynamic>?;
    final trs = rawTrs?.whereType<Map<String, dynamic>>().map((t) => TrafficRule.fromJson(t)).toList();

    return FirewallInfo(
      engine: json['engine'] as String? ?? 'nftables v1.0.8 (fw4)',
      table: json['table'] as String? ?? 'table inet fw4',
      status: json['status'] as String? ?? 'enforcing',
      synFlood: json['syn_flood'] != false,
      dropInvalid: json['drop_invalid'] != false,
      wanPing: json['wan_ping'] == true,
      wanLockdown: (json['wan_lockdown'] ?? json['wan_block']) != false,
      dnsRebind: (json['dns_rebind'] ?? json['rebind_protection']) != false,
      flowOffload: json['flow_offload'] != false,
      flowOffloadHw: json['flow_offload_hw'] != false,
      mssClamping: json['mss_clamping'] != false,
      antiSpoofing: json['anti_spoofing'] != false,
      ipv6Firewall: json['ipv6_firewall'] != false,
      stealthMode: json['stealth_mode'] != false,
      guestIsolation: json['guest_isolation'] != false,
      dmzEnabled: json['dmz_enabled'] == true,
      dmzIp: json['dmz_ip'] as String? ?? '192.168.1.150',
      conntrackCount: RouterStatusModel._toInt(json['conntrack_count'], 342),
      conntrackMax: RouterStatusModel._toInt(json['conntrack_max'], 16384),
      portForwards: pfs,
      trafficRules: trs,
    );
  }

  FirewallInfo copyWith({
    String? engine,
    String? table,
    String? status,
    bool? synFlood,
    bool? dropInvalid,
    bool? wanPing,
    bool? wanLockdown,
    bool? dnsRebind,
    bool? flowOffload,
    bool? flowOffloadHw,
    bool? mssClamping,
    bool? antiSpoofing,
    bool? ipv6Firewall,
    bool? stealthMode,
    bool? guestIsolation,
    bool? dmzEnabled,
    String? dmzIp,
    int? conntrackCount,
    int? conntrackMax,
    List<PortForwardRule>? portForwards,
    List<TrafficRule>? trafficRules,
  }) {
    return FirewallInfo(
      engine: engine ?? this.engine,
      table: table ?? this.table,
      status: status ?? this.status,
      synFlood: synFlood ?? this.synFlood,
      dropInvalid: dropInvalid ?? this.dropInvalid,
      wanPing: wanPing ?? this.wanPing,
      wanLockdown: wanLockdown ?? this.wanLockdown,
      dnsRebind: dnsRebind ?? this.dnsRebind,
      flowOffload: flowOffload ?? this.flowOffload,
      flowOffloadHw: flowOffloadHw ?? this.flowOffloadHw,
      mssClamping: mssClamping ?? this.mssClamping,
      antiSpoofing: antiSpoofing ?? this.antiSpoofing,
      ipv6Firewall: ipv6Firewall ?? this.ipv6Firewall,
      stealthMode: stealthMode ?? this.stealthMode,
      guestIsolation: guestIsolation ?? this.guestIsolation,
      dmzEnabled: dmzEnabled ?? this.dmzEnabled,
      dmzIp: dmzIp ?? this.dmzIp,
      conntrackCount: conntrackCount ?? this.conntrackCount,
      conntrackMax: conntrackMax ?? this.conntrackMax,
      portForwards: portForwards ?? this.portForwards,
      trafficRules: trafficRules ?? this.trafficRules,
    );
  }

  int get activeDefensesCount {
    int count = 0;
    if (synFlood) count++;
    if (dropInvalid) count++;
    if (!wanPing) count++;
    if (wanLockdown) count++;
    if (dnsRebind) count++;
    if (mssClamping) count++;
    if (antiSpoofing) count++;
    if (ipv6Firewall) count++;
    if (stealthMode) count++;
    if (guestIsolation) count++;
    return count;
  }

  int get totalDefensesCount => 10;
  int get activePortForwardsCount => portForwards.where((p) => p.enabled).length;
  int get activeTrafficRulesCount => trafficRules.where((t) => t.enabled).length;
  double get conntrackPercent => (conntrackCount / (conntrackMax > 0 ? conntrackMax : 16384) * 100).clamp(0, 100).toDouble();
}

class PortForwardRule {
  final String id;
  final String name;
  final String proto;
  final String extPort;
  final String intIp;
  final String intPort;
  final bool enabled;

  PortForwardRule({
    required this.id,
    required this.name,
    required this.proto,
    required this.extPort,
    required this.intIp,
    required this.intPort,
    required this.enabled,
  });

  factory PortForwardRule.fromJson(Map<String, dynamic> json) {
    return PortForwardRule(
      id: json['id'] as String? ?? 'pf_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Port Forward',
      proto: (json['proto'] as String? ?? 'tcp').toLowerCase(),
      extPort: (json['extPort'] ?? json['ext_port'] ?? json['src_dport'] ?? '8080').toString(),
      intIp: (json['intIp'] ?? json['int_ip'] ?? json['dest_ip'] ?? '192.168.1.100').toString(),
      intPort: (json['intPort'] ?? json['int_port'] ?? json['dest_port'] ?? '80').toString(),
      enabled: json['enabled'] != false,
    );
  }

  PortForwardRule copyWith({
    String? id,
    String? name,
    String? proto,
    String? extPort,
    String? intIp,
    String? intPort,
    bool? enabled,
  }) {
    return PortForwardRule(
      id: id ?? this.id,
      name: name ?? this.name,
      proto: proto ?? this.proto,
      extPort: extPort ?? this.extPort,
      intIp: intIp ?? this.intIp,
      intPort: intPort ?? this.intPort,
      enabled: enabled ?? this.enabled,
    );
  }
}

class TrafficRule {
  final String id;
  final String name;
  final String proto;
  final String src;
  final String dest;
  final String target;
  final bool enabled;

  TrafficRule({
    required this.id,
    required this.name,
    required this.proto,
    required this.src,
    required this.dest,
    required this.target,
    required this.enabled,
  });

  factory TrafficRule.fromJson(Map<String, dynamic> json) {
    return TrafficRule(
      id: json['id'] as String? ?? 'tr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Traffic Filter',
      proto: (json['proto'] as String? ?? 'tcp').toLowerCase(),
      src: (json['src'] as String? ?? 'lan').toLowerCase(),
      dest: (json['dest'] as String? ?? 'wan').toLowerCase(),
      target: (json['target'] as String? ?? 'DROP').toUpperCase(),
      enabled: json['enabled'] != false,
    );
  }

  TrafficRule copyWith({
    String? id,
    String? name,
    String? proto,
    String? src,
    String? dest,
    String? target,
    bool? enabled,
  }) {
    return TrafficRule(
      id: id ?? this.id,
      name: name ?? this.name,
      proto: proto ?? this.proto,
      src: src ?? this.src,
      dest: dest ?? this.dest,
      target: target ?? this.target,
      enabled: enabled ?? this.enabled,
    );
  }
}

