import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/router_api_service.dart';
import '../../models/router_status_model.dart';

enum RouterConnectionState { initial, connecting, connected, error, offline }

class RouterController extends ChangeNotifier {
  final PreferencesService _prefs;
  late final RouterApiService _apiService;

  RouterStatusModel? _status;
  RouterConnectionState _connectionState = RouterConnectionState.initial;
  int _latencyMs = -1;
  String? _errorMessage;
  bool _isRefreshing = false;
  DateTime? _lastUpdated;
  Timer? _pollingTimer;

  // Live speed tracking
  int? _prevRxBytes;
  int? _prevTxBytes;
  DateTime? _prevTrafficTime;
  double _liveDownloadSpeedBps = 0.0;
  double _liveUploadSpeedBps = 0.0;
  final List<double> _downloadSpeedHistory = [];
  final List<double> _uploadSpeedHistory = [];

  RouterController(this._prefs, {RouterApiService? apiService}) {
    _apiService = apiService ?? RouterApiService(_prefs);
  }

  // Getters
  RouterStatusModel? get status => _status;
  RouterConnectionState get connectionState => _connectionState;
  int get latencyMs => _latencyMs;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  DateTime? get lastUpdated => _lastUpdated;
  String get routerIp => _prefs.routerIp;
  int get routerPort => _prefs.routerPort;
  String get routerSecret => _prefs.routerSecret;
  bool get autoRefresh => _prefs.autoRefresh;

  double get liveDownloadSpeedBps => _liveDownloadSpeedBps;
  double get liveUploadSpeedBps => _liveUploadSpeedBps;
  String get formattedDownloadSpeed => TrafficInfo.formatSpeed(_liveDownloadSpeedBps);
  String get formattedUploadSpeed => TrafficInfo.formatSpeed(_liveUploadSpeedBps);
  List<double> get downloadSpeedHistory => List.unmodifiable(_downloadSpeedHistory);
  List<double> get uploadSpeedHistory => List.unmodifiable(_uploadSpeedHistory);

  // Per-client live traffic tracking
  final Map<String, _ClientSpeedSnapshot> _clientSpeeds = {};

  double getClientDownloadSpeedBps(String mac) => _clientSpeeds[mac.toLowerCase()]?.downloadBps ?? 0.0;
  double getClientUploadSpeedBps(String mac) => _clientSpeeds[mac.toLowerCase()]?.uploadBps ?? 0.0;
  String getClientDownloadSpeed(String mac) => TrafficInfo.formatSpeed(getClientDownloadSpeedBps(mac));
  String getClientUploadSpeed(String mac) => TrafficInfo.formatSpeed(getClientUploadSpeedBps(mac));
  String getClientTotalSpeed(String mac) => TrafficInfo.formatSpeed(getClientDownloadSpeedBps(mac) + getClientUploadSpeedBps(mac));

  bool get isConnected => _connectionState == RouterConnectionState.connected;

  bool _isBusy = false;

  @visibleForTesting
  void setStatusForTesting(RouterStatusModel status) {
    _status = status;
    _connectionState = RouterConnectionState.connected;
    notifyListeners();
  }

  bool _isDisposed = false;
  bool _isPollingPaused = false;
  int _consecutiveFailures = 0;

  bool get isPollingPaused => _isPollingPaused;

  Future<void> init() async {
    _connectionState = RouterConnectionState.connecting;
    notifyListeners();

    await refresh(background: false);

    _startPolling();
  }

  /// Lifecycle pause: cancels active timers to prevent background battery drain
  void pausePolling() {
    _isPollingPaused = true;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Lifecycle resume: immediately fetches fresh data and restarts polling
  void resumePolling() {
    if (!_isPollingPaused) return;
    _isPollingPaused = false;
    _consecutiveFailures = 0;
    if (_prefs.autoRefresh) {
      if (!_isBusy) {
        refresh(background: true);
      }
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    if (_isPollingPaused || !_prefs.autoRefresh) return;

    // Adaptive interval: 5s when connected; exponential backoff (15s -> 30s -> 60s) on consecutive failures
    final int interval;
    if (isConnected) {
      interval = 5;
    } else {
      interval = (_consecutiveFailures >= 3)
          ? 60
          : ((_consecutiveFailures >= 2) ? 30 : 15);
    }

    _pollingTimer = Timer(Duration(seconds: interval), () async {
      if (!_isBusy && !_isPollingPaused) {
        await refresh(background: true);
      }
      if (!_isPollingPaused && _prefs.autoRefresh) {
        _startPolling();
      }
    });
  }

  /// Manually or automatically refresh the status and measure latency
  Future<void> refresh({bool background = false}) async {
    if (_isBusy) return;
    _isBusy = true;

    if (!background) {
      _isRefreshing = true;
      notifyListeners();
    }

    try {
      // 1. Single direct telemetry fetch with stopwatch latency timing (halves network & radio energy consumption)
      final stopwatch = Stopwatch()..start();
      final statusData = await _apiService.fetchStatus();
      stopwatch.stop();

      _status = statusData;
      _connectionState = RouterConnectionState.connected;
      _errorMessage = null;
      _latencyMs = stopwatch.elapsedMilliseconds;
      _consecutiveFailures = 0;

      final now = DateTime.now();
      if (_prevTrafficTime != null && _prevRxBytes != null && _prevTxBytes != null) {
        final deltaSeconds = now.difference(_prevTrafficTime!).inMilliseconds / 1000.0;
        if (deltaSeconds >= 0.5) {
          if (statusData.traffic.currentDownloadMbps > 0) {
            _liveDownloadSpeedBps = (statusData.traffic.currentDownloadMbps * 1000 * 1000) / 8;
          } else {
            final rxDiff = statusData.traffic.rxBytes - _prevRxBytes!;
            _liveDownloadSpeedBps = rxDiff >= 0 ? (rxDiff / deltaSeconds) : 0.0;
          }

          if (statusData.traffic.currentUploadMbps > 0) {
            _liveUploadSpeedBps = (statusData.traffic.currentUploadMbps * 1000 * 1000) / 8;
          } else {
            final txDiff = statusData.traffic.txBytes - _prevTxBytes!;
            _liveUploadSpeedBps = txDiff >= 0 ? (txDiff / deltaSeconds) : 0.0;
          }

          _downloadSpeedHistory.add(_liveDownloadSpeedBps);
          if (_downloadSpeedHistory.length > 10) _downloadSpeedHistory.removeAt(0);

          _uploadSpeedHistory.add(_liveUploadSpeedBps);
          if (_uploadSpeedHistory.length > 10) _uploadSpeedHistory.removeAt(0);
        }
      } else if (statusData.traffic.currentDownloadMbps > 0 || statusData.traffic.currentUploadMbps > 0) {
        _liveDownloadSpeedBps = (statusData.traffic.currentDownloadMbps * 1000 * 1000) / 8;
        _liveUploadSpeedBps = (statusData.traffic.currentUploadMbps * 1000 * 1000) / 8;
        _downloadSpeedHistory.add(_liveDownloadSpeedBps);
        _uploadSpeedHistory.add(_liveUploadSpeedBps);
      }

      // Track individual client traffic speeds
      final deltaSec = (_prevTrafficTime != null)
          ? now.difference(_prevTrafficTime!).inMilliseconds / 1000.0
          : 0.0;
      for (final client in statusData.clients) {
        final mac = client.mac.toLowerCase();
        final prev = _clientSpeeds[mac];
        if (prev != null && deltaSec >= 0.5) {
          final rxDiff = client.rxBytes - prev.lastRx;
          final txDiff = client.txBytes - prev.lastTx;
          final dlSpeed = rxDiff >= 0 ? (rxDiff / deltaSec) : 0.0;
          final ulSpeed = txDiff >= 0 ? (txDiff / deltaSec) : 0.0;
          _clientSpeeds[mac] = _ClientSpeedSnapshot(
            lastRx: client.rxBytes,
            lastTx: client.txBytes,
            downloadBps: dlSpeed,
            uploadBps: ulSpeed,
          );
        } else {
          _clientSpeeds[mac] = _ClientSpeedSnapshot(
            lastRx: client.rxBytes,
            lastTx: client.txBytes,
            downloadBps: prev?.downloadBps ?? 0.0,
            uploadBps: prev?.uploadBps ?? 0.0,
          );
        }
      }

      // Clean up disconnected clients from snapshot map to prevent memory retention
      final activeMacs = statusData.clients.map((c) => c.mac.toLowerCase()).toSet();
      _clientSpeeds.removeWhere((mac, _) => !activeMacs.contains(mac));

      _prevRxBytes = statusData.traffic.rxBytes;
      _prevTxBytes = statusData.traffic.txBytes;
      _prevTrafficTime = now;
      _lastUpdated = now;
    } catch (e) {
      _consecutiveFailures++;
      _latencyMs = -1;
      if (e is SocketException || e is TimeoutException) {
        _connectionState = RouterConnectionState.offline;
        _errorMessage = 'Router is offline or unreachable.';
      } else {
        _connectionState = RouterConnectionState.error;
        _errorMessage = e.toString();
      }
    } finally {
      _isRefreshing = false;
      _isBusy = false;
      if (!_isDisposed) {
        notifyListeners();
      }
    }
  }

  /// Test connection directly for Settings Modal before saving
  Future<PingResult> testConnection({required String ip, required int port}) async {
    return await _apiService.pingRouter(targetIp: ip, targetPort: port);
  }

  /// Update and persist router gateway configuration
  Future<void> updateSettings({
    required String ip,
    required int port,
    required String secret,
    required bool autoRefresh,
  }) async {
    await _prefs.setRouterIp(ip);
    await _prefs.setRouterPort(port);
    await _prefs.setRouterSecret(secret);
    await _prefs.setAutoRefresh(autoRefresh);

    _startPolling();
    await refresh(background: false);
  }

  /// Execute protected control action (e.g. drop_caches, reboot, led_stealth, block_client)
  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]) async {
    // 1. Optimistic client state mutation for instant UI feedback
    final targetMac = (params?['target'] ?? params?['mac'])?.toString().toLowerCase();
    List<ClientInfo>? previousClients;
    if (targetMac != null && _status != null) {
      final idx = _status!.clients.indexWhere((c) => c.mac.toLowerCase() == targetMac);
      if (idx != -1) {
        previousClients = List<ClientInfo>.from(_status!.clients);
        final oldClient = _status!.clients[idx];
        ClientInfo? newClient;
        if (command == 'block_client') {
          newClient = oldClient.copyWith(blocked: true);
        } else if (command == 'unblock_client') {
          newClient = oldClient.copyWith(blocked: false);
        } else if (command == 'nds_auth') {
          newClient = oldClient.copyWith(ndsAuthenticated: true);
        } else if (command == 'nds_deauth' || command == 'deauth') {
          newClient = oldClient.copyWith(ndsAuthenticated: false);
        } else if (command == 'disconnect_client' || command == 'kick_client') {
          newClient = oldClient.copyWith(connectedSeconds: 0);
        } else if (command == 'rename_client' || command == 'set_alias') {
          final newName = (params?['name'] ?? params?['value'] ?? params?['val'] ?? params?['alias'])?.toString().trim();
          if (newName != null && newName.isNotEmpty) {
            newClient = oldClient.copyWith(customName: newName);
          } else {
            newClient = oldClient.copyWith(resetCustomName: true);
          }
        }
        if (newClient != null) {
          final updated = List<ClientInfo>.from(_status!.clients);
          updated[idx] = newClient;
          _status = _status!.copyWith(clients: updated);
          notifyListeners();
        }
      }
    }

    try {
      final res = await _apiService.executeAction(command: command, params: params);
      // Wait a fraction of a second and refresh status to reflect changes
      await Future.delayed(const Duration(milliseconds: 600));
      await refresh(background: true);
      return res;
    } catch (e) {
      // Revert optimistic mutation if action failed
      if (previousClients != null && _status != null) {
        _status = _status!.copyWith(clients: previousClients);
        notifyListeners();
      }
      rethrow;
    }
  }

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

  /// Toggle TCP SYN Flood defense
  Future<void> toggleSynFlood(bool enabled) async {
    await executeAction('set_syn_flood', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(synFlood: enabled));
      notifyListeners();
    }
  }

  /// Toggle dropping invalid conntrack packets
  Future<void> toggleDropInvalid(bool enabled) async {
    await executeAction('set_drop_invalid', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(dropInvalid: enabled));
      notifyListeners();
    }
  }

  /// Toggle WAN ICMP Echo (Ping) Response / Stealth
  Future<void> toggleWanPing(bool enabled) async {
    await executeAction('set_wan_ping', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(wanPing: enabled));
      notifyListeners();
    }
  }

  /// Toggle TCP MSS Clamping on WAN
  Future<void> toggleMssClamping(bool enabled) async {
    await executeAction('set_mss_clamping', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(mssClamping: enabled));
      notifyListeners();
    }
  }

  /// Toggle Anti-Spoofing / Reverse Path Filter (rp_filter)
  Future<void> toggleAntiSpoofing(bool enabled) async {
    await executeAction('set_anti_spoofing', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(antiSpoofing: enabled));
      notifyListeners();
    }
  }

  /// Toggle IPv6 Inbound Firewall Protection
  Future<void> toggleIpv6Firewall(bool enabled) async {
    await executeAction('set_ipv6_firewall', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(ipv6Firewall: enabled));
      notifyListeners();
    }
  }

  /// Toggle Stealth Port Drop Protection
  Future<void> toggleStealthMode(bool enabled) async {
    await executeAction('set_stealth_mode', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(stealthMode: enabled));
      notifyListeners();
    }
  }

  /// Toggle Guest to LAN Inter-Zone Isolation
  Future<void> toggleGuestIsolation(bool enabled) async {
    await executeAction('set_guest_isolation', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(guestIsolation: enabled));
      notifyListeners();
    }
  }

  /// Toggle MediaTek Hardware PPE Flow Offload
  Future<void> toggleHwFlowOffload(bool enabled) async {
    await executeAction('set_flow_offload_hw', {'value': enabled ? 'on' : 'off'});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(flowOffloadHw: enabled));
      notifyListeners();
    }
  }

  /// Toggle Demilitarized Zone (DMZ)
  Future<void> toggleDmz({required bool enabled, String? ip}) async {
    await executeAction('set_dmz', {
      'value': enabled ? 'on' : 'off',
      'enabled': enabled,
      if (ip != null && ip.isNotEmpty) 'ip': ip,
    });
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(
        dmzEnabled: enabled,
        dmzIp: ip ?? _status!.firewall.dmzIp,
      ));
      notifyListeners();
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
    if (_status != null) {
      final updatedList = _status!.firewall.portForwards.where((p) => p.id != id).toList();
      _status = _statusWithFirewall(_status!.firewall.copyWith(portForwards: updatedList));
      notifyListeners();
    }
  }

  /// Toggle Port Forwarding rule enabled/disabled
  Future<void> togglePortForward(String id, bool enabled) async {
    await executeAction('toggle_port_forward', {
      'id': id,
      'target': id,
      'value': enabled ? 'on' : 'off',
    });
    if (_status != null) {
      final updatedList = _status!.firewall.portForwards.map((p) {
        if (p.id == id) return p.copyWith(enabled: enabled);
        return p;
      }).toList();
      _status = _statusWithFirewall(_status!.firewall.copyWith(portForwards: updatedList));
      notifyListeners();
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
    if (_status != null) {
      final updatedList = _status!.firewall.trafficRules.where((t) => t.id != id).toList();
      _status = _statusWithFirewall(_status!.firewall.copyWith(trafficRules: updatedList));
      notifyListeners();
    }
  }

  /// Toggle Traffic Filter Rule
  Future<void> toggleTrafficRule(String id, bool enabled) async {
    await executeAction('toggle_traffic_rule', {
      'id': id,
      'target': id,
      'value': enabled ? 'on' : 'off',
    });
    if (_status != null) {
      final updatedList = _status!.firewall.trafficRules.map((t) {
        if (t.id == id) return t.copyWith(enabled: enabled);
        return t;
      }).toList();
      _status = _statusWithFirewall(_status!.firewall.copyWith(trafficRules: updatedList));
      notifyListeners();
    }
  }

  /// Flush Connection Tracking (Conntrack) Table
  Future<void> flushConntrack() async {
    await executeAction('flush_conntrack', {});
    if (_status != null) {
      _status = _statusWithFirewall(_status!.firewall.copyWith(conntrackCount: 18));
      notifyListeners();
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

  RouterStatusModel _statusWithFirewall(FirewallInfo updatedFw) {
    final s = _status!;
    return RouterStatusModel(
      cpu: s.cpu,
      memory: s.memory,
      storage: s.storage,
      traffic: s.traffic,
      network: s.network,
      wireless: s.wireless,
      clients: s.clients,
      stealthLeds: s.stealthLeds,
      timestamp: s.timestamp,
      firewall: updatedFw,
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _apiService.dispose();
    super.dispose();
  }
}

class _ClientSpeedSnapshot {
  final int lastRx;
  final int lastTx;
  final double downloadBps;
  final double uploadBps;

  _ClientSpeedSnapshot({
    required this.lastRx,
    required this.lastTx,
    required this.downloadBps,
    required this.uploadBps,
  });
}

