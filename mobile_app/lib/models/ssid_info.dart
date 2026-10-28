import '../core/utils/formatters.dart';
import 'model_helpers.dart';

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
      channel: ModelHelpers.toInt(json['channel'], is5g ? 149 : 6),
      connectedClients: ModelHelpers.toInt(json['connected_clients'], 0),
      isGuest: json['is_guest'] == true,
      isHidden: json['hidden'] == true || json['hidden'] == '1' || json['is_hidden'] == true,
      isIsolated: json['isolate'] == true || json['isolate'] == '1' || json['isolated'] == true,
      password: json['key'] as String? ?? json['password'] as String?,
      rxBytes: ModelHelpers.toInt(json['rx_bytes'], 0),
      txBytes: ModelHelpers.toInt(json['tx_bytes'], 0),
      txpowerDbm: ModelHelpers.toInt(json['txpower_dbm'], defaultTx),
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

  String get formattedDownload => Formatters.formatBytes(rxBytes);
  String get formattedUpload => Formatters.formatBytes(txBytes);
  String get formattedTotalData => Formatters.formatBytes(totalBytes);

  String get estimatedIndoorRange => is5GHz ? '~25 meters (80 ft)' : '~45-50 meters (150 ft)';
  String get estimatedOutdoorRange => is5GHz ? '~50-60 meters (180 ft)' : '~90-100 meters (300 ft)';
  String get wallPenetration => is5GHz ? 'Moderate (1-2 walls / High speed)' : 'High (2-3 solid walls / Long range)';
  String get coverageType => is5GHz ? 'High Throughput (Direct LOS)' : 'Broad Coverage (Long-Range)';
}
