import 'client_info.dart';
import 'radio_info.dart';
import 'ssid_info.dart';

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
