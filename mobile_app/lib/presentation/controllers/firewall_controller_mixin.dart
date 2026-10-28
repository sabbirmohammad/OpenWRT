import 'package:flutter/foundation.dart';
import '../../models/router_status_model.dart';

mixin FirewallControllerMixin on ChangeNotifier {
  RouterStatusModel? get status;
  set status(RouterStatusModel? val);

  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]);

  Future<void> refresh({bool background = false});

  void updateFirewallState(FirewallInfo updatedFw) {
    if (status != null) {
      status = status!.copyWith(firewall: updatedFw);
      notifyListeners();
    }
  }

  /// Toggle TCP SYN Flood defense
  Future<void> toggleSynFlood(bool enabled) async {
    await executeAction('set_syn_flood', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(synFlood: enabled));
  }

  /// Toggle dropping invalid conntrack packets
  Future<void> toggleDropInvalid(bool enabled) async {
    await executeAction('set_drop_invalid', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(dropInvalid: enabled));
  }

  /// Toggle WAN ICMP Echo (Ping) Response / Stealth
  Future<void> toggleWanPing(bool enabled) async {
    await executeAction('set_wan_ping', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(wanPing: enabled));
  }

  /// Toggle TCP MSS Clamping on WAN
  Future<void> toggleMssClamping(bool enabled) async {
    await executeAction('set_mss_clamping', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(mssClamping: enabled));
  }

  /// Toggle Anti-Spoofing / Reverse Path Filter (rp_filter)
  Future<void> toggleAntiSpoofing(bool enabled) async {
    await executeAction('set_anti_spoofing', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(antiSpoofing: enabled));
  }

  /// Toggle IPv6 Inbound Firewall Protection
  Future<void> toggleIpv6Firewall(bool enabled) async {
    await executeAction('set_ipv6_firewall', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(ipv6Firewall: enabled));
  }

  /// Toggle Stealth Port Drop Protection
  Future<void> toggleStealthMode(bool enabled) async {
    await executeAction('set_stealth_mode', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(stealthMode: enabled));
  }

  /// Toggle Guest to LAN Inter-Zone Isolation
  Future<void> toggleGuestIsolation(bool enabled) async {
    await executeAction('set_guest_isolation', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(guestIsolation: enabled));
  }

  /// Toggle MediaTek Hardware PPE Flow Offload
  Future<void> toggleHwFlowOffload(bool enabled) async {
    await executeAction('set_flow_offload_hw', {'value': enabled ? 'on' : 'off'});
    if (status != null) updateFirewallState(status!.firewall.copyWith(flowOffloadHw: enabled));
  }

  /// Toggle Demilitarized Zone (DMZ)
  Future<void> toggleDmz({required bool enabled, String? ip}) async {
    await executeAction('set_dmz', {
      'value': enabled ? 'on' : 'off',
      'enabled': enabled,
      if (ip != null && ip.isNotEmpty) 'ip': ip,
    });
    if (status != null) {
      updateFirewallState(status!.firewall.copyWith(
        dmzEnabled: enabled,
        dmzIp: ip ?? status!.firewall.dmzIp,
      ));
    }
  }

  /// Add new NAT Port Forwarding rule
  Future<void> addPortForward({
    required String name,
    required String proto,
    required String extPort,
    required String intIp,
    required String intPort,
  }) async {
    await executeAction('add_port_forward', {
      'name': name,
      'proto': proto,
      'extPort': extPort,
      'intIp': intIp,
      'intPort': intPort,
    });
    await refresh(background: true);
  }

  /// Delete a Port Forwarding rule
  Future<void> deletePortForward(String id) async {
    await executeAction('del_port_forward', {'id': id, 'target': id});
    if (status != null) {
      final updatedList = status!.firewall.portForwards.where((p) => p.id != id).toList();
      updateFirewallState(status!.firewall.copyWith(portForwards: updatedList));
    }
  }

  /// Toggle Port Forwarding rule enabled/disabled
  Future<void> togglePortForward(String id, bool enabled) async {
    await executeAction('toggle_port_forward', {
      'id': id,
      'target': id,
      'value': enabled ? 'on' : 'off',
    });
    if (status != null) {
      final updatedList = status!.firewall.portForwards.map((p) {
        if (p.id == id) return p.copyWith(enabled: enabled);
        return p;
      }).toList();
      updateFirewallState(status!.firewall.copyWith(portForwards: updatedList));
    }
  }

  /// Add custom Traffic Filter Rule
  Future<void> addTrafficRule({
    required String name,
    required String proto,
    required String src,
    required String dest,
    required String target,
  }) async {
    await executeAction('add_traffic_rule', {
      'name': name,
      'proto': proto,
      'src': src,
      'dest': dest,
      'target': target,
    });
    await refresh(background: true);
  }

  /// Delete Traffic Filter Rule
  Future<void> deleteTrafficRule(String id) async {
    await executeAction('del_traffic_rule', {'id': id, 'target': id});
    if (status != null) {
      final updatedList = status!.firewall.trafficRules.where((t) => t.id != id).toList();
      updateFirewallState(status!.firewall.copyWith(trafficRules: updatedList));
    }
  }

  /// Toggle Traffic Filter Rule
  Future<void> toggleTrafficRule(String id, bool enabled) async {
    await executeAction('toggle_traffic_rule', {
      'id': id,
      'target': id,
      'value': enabled ? 'on' : 'off',
    });
    if (status != null) {
      final updatedList = status!.firewall.trafficRules.map((t) {
        if (t.id == id) return t.copyWith(enabled: enabled);
        return t;
      }).toList();
      updateFirewallState(status!.firewall.copyWith(trafficRules: updatedList));
    }
  }

  /// Flush Connection Tracking (Conntrack) Table
  Future<void> flushConntrack() async {
    await executeAction('flush_conntrack', {});
    if (status != null) {
      updateFirewallState(status!.firewall.copyWith(conntrackCount: 18));
    }
  }

  /// Reload Firewall rules
  Future<void> reloadFirewall() async {
    await executeAction('reload_firewall', {});
  }

  /// Restart Firewall Subsystem
  Future<void> restartFirewall() async {
    await executeAction('restart_firewall', {});
  }

  /// Reset Firewall to Default factory rules
  Future<void> resetFirewallDefaults() async {
    await executeAction('reset_firewall', {});
    await refresh(background: true);
  }
}
