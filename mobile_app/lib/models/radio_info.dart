import 'model_helpers.dart';

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
      channel: ModelHelpers.toInt(json['channel'], 0),
      txpowerDbm: ModelHelpers.toInt(json['txpower_dbm'], 20),
      connectedClients: ModelHelpers.toInt(json['connected_clients'], 0),
      isolated: json['isolated'] == true,
    );
  }
}
