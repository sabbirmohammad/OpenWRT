import 'package:flutter/foundation.dart';

mixin NetworkControllerMixin on ChangeNotifier {
  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]);

  /// Toggle Hardware / Software Flow Offloading
  Future<void> toggleHwOffload(bool enabled) async {
    await executeAction('set_hw_offload', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Toggle CAKE SQM QoS
  Future<void> toggleSqm(bool enabled) async {
    await executeAction('set_sqm', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Configure SQM parameters (rates in kbit, qdisc 'cake' or 'fq_codel')
  Future<void> updateSqmConfig({
    required bool enabled,
    required String qdisc,
    required int downloadKbit,
    required int uploadKbit,
  }) async {
    await executeAction('set_sqm_limits', {
      'value': enabled ? 'on' : 'off',
      'qdisc': qdisc,
      'download': downloadKbit.toString(),
      'upload': uploadKbit.toString(),
    });
  }

  /// Toggle WireGuard VPN Tunnel
  Future<void> toggleWireguard(bool enabled) async {
    await executeAction('set_wireguard', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Toggle Multi-WAN failover
  Future<void> toggleMultiWan(bool enabled) async {
    await executeAction('set_multiwan', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Toggle DNS-over-HTTPS (DoH)
  Future<void> toggleDoh(bool enabled) async {
    await executeAction('set_doh', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Set custom upstream DNS or reset to ISP automatic ('auto')
  Future<void> setCustomDns({required String primary, String? secondary}) async {
    await executeAction('set_dns', {
      'primary': primary,
      'secondary': secondary ?? '',
      'value': primary,
      'target': secondary ?? '',
    });
  }
}
