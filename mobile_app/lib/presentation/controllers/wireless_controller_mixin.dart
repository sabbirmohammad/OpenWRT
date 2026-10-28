import 'package:flutter/foundation.dart';

mixin WirelessControllerMixin on ChangeNotifier {
  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]);

  /// Toggle an SSID active or inactive
  Future<void> toggleSsid(String ifaceId, bool enabled) async {
    if (ifaceId == 'guest') {
      await executeAction('guest_wifi_toggle', {'value': enabled ? 'on' : 'off'});
    } else {
      await executeAction('toggle_wifi_ssid', {
        'target': ifaceId,
        'value': enabled ? 'on' : 'off',
      });
    }
  }

  /// Update SSID configuration (name, key, hidden, isolate)
  Future<void> updateSsidConfig({
    required String ifaceId,
    required String newSsid,
    String? key,
    bool? hidden,
    bool? isolate,
  }) async {
    final extra = <String, dynamic>{};
    if (key != null && key.isNotEmpty) extra['key'] = key;
    if (hidden != null) extra['hidden'] = hidden ? '1' : '0';
    if (isolate != null) extra['isolate'] = isolate ? '1' : '0';

    await executeAction('set_wifi_ssid', {
      'target': ifaceId,
      'value': newSsid,
      'extra': extra,
      'key': key,
      'hidden': hidden == true ? '1' : '0',
      'isolate': isolate == true ? '1' : '0',
    });
  }

  /// Add a new virtual SSID on radio0 (2.4GHz) or radio1 (5GHz)
  Future<void> addSsid({
    required String ssid,
    required String radio,
    String? key,
    String? encryption,
    bool isolate = false,
  }) async {
    await executeAction('add_wifi_ssid', {
      'target': radio,
      'value': ssid,
      'key': key ?? '',
      'encryption': encryption ?? 'psk2',
      'isolate': isolate ? '1' : '0',
    });
  }

  /// Delete a virtual SSID
  Future<void> deleteSsid(String ifaceId) async {
    await executeAction('del_wifi_ssid', {
      'target': ifaceId,
    });
  }
}
