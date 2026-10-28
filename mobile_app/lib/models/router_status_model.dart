import 'client_info.dart';
import 'cpu_info.dart';
import 'firewall_info.dart';
import 'memory_info.dart';
import 'model_helpers.dart';
import 'network_info.dart';
import 'storage_info.dart';
import 'traffic_info.dart';
import 'wireless_info.dart';

export 'client_info.dart';
export 'cpu_info.dart';
export 'firewall_info.dart';
export 'memory_info.dart';
export 'model_helpers.dart';
export 'network_info.dart';
export 'port_forward_rule.dart';
export 'radio_info.dart';
export 'ssid_info.dart';
export 'storage_info.dart';
export 'traffic_info.dart';
export 'traffic_rule.dart';
export 'wireless_info.dart';

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
      timestamp: ModelHelpers.toInt(json['timestamp']),
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

}

