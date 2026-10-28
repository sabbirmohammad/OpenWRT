import 'package:flutter/foundation.dart';

mixin SecurityControllerMixin on ChangeNotifier {
  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]);

  /// Toggle 802.11w Protected Management Frames (PMF)
  Future<void> togglePmf(bool enabled) async {
    await executeAction('set_wifi_advanced', {
      'target': 'pmf',
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Toggle DNS Rebinding Attack Protection
  Future<void> toggleDnsRebind(bool enabled) async {
    await executeAction('set_dns_rebind', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Toggle Remote WAN Management Lockdown (Port 80/443/22)
  Future<void> toggleWanLockdown(bool enabled) async {
    await executeAction('set_wan_lockdown', {
      'value': enabled ? 'on' : 'off',
    });
  }

  /// Kick/disconnect a client via 802.11 deauthentication
  Future<void> kickClient(String mac) async {
    await executeAction('kick_client', {
      'target': mac,
    });
  }

  /// Block a client MAC at the kernel firewall forward chain
  Future<void> blockClient(String mac) async {
    await executeAction('block_client', {
      'target': mac,
    });
  }

  /// Unblock a client MAC
  Future<void> unblockClient(String mac) async {
    await executeAction('unblock_client', {
      'target': mac,
    });
  }

  /// One-Tap Auto-Harden Router Security
  Future<void> autoHardenSecurity() async {
    await executeAction('harden_security', {});
  }
}
