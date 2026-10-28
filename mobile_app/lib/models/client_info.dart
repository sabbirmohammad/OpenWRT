import '../core/utils/formatters.dart';
import 'model_helpers.dart';

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
      signalDbm: ModelHelpers.toInt(json['signal_dbm'], -60),
      rxBytes: ModelHelpers.toInt(json['rx_bytes'], 0),
      txBytes: ModelHelpers.toInt(json['tx_bytes'], 0),
      connectedSeconds: ModelHelpers.toInt(json['connected_seconds'], 0),
      blocked: json['blocked'] == true,
      ndsAuthenticated: json['nds_authenticated'] == true,
      customName: json['custom_name'] as String?,
      vendor: json['vendor'] as String?,
      isStatic: json['is_static'] == true,
      downloadLimitKbps: ModelHelpers.toInt(json['download_limit_kbps'], 0),
      uploadLimitKbps: ModelHelpers.toInt(json['upload_limit_kbps'], 0),
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

  String get formattedTotalTraffic => Formatters.formatBytes(rxBytes + txBytes);
  String get formattedRx => Formatters.formatBytes(rxBytes);
  String get formattedTx => Formatters.formatBytes(txBytes);
  String get formattedUptime => Formatters.formatUptime(connectedSeconds);
  String get formattedConnectedSince => Formatters.formatConnectedSince(connectedSeconds);

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
