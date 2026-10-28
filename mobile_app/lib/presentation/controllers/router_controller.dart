import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/services/github_update_service.dart';
import '../../core/services/preferences_service.dart';
import '../../core/services/router_api_service.dart';
import '../../models/app_update_info.dart';
import '../../models/router_status_model.dart';
import 'firewall_controller_mixin.dart';
import 'network_controller_mixin.dart';
import 'security_controller_mixin.dart';
import 'speed_tracker.dart';
import 'wireless_controller_mixin.dart';

enum RouterConnectionState { initial, connecting, connected, error, offline }

class RouterController extends ChangeNotifier
    with
        WirelessControllerMixin,
        NetworkControllerMixin,
        SecurityControllerMixin,
        FirewallControllerMixin {
  final PreferencesService _prefs;
  late final RouterApiService _apiService;
  late final GithubUpdateService _updateService;
  final SpeedTracker _speedTracker = SpeedTracker();

  RouterStatusModel? _status;
  RouterConnectionState _connectionState = RouterConnectionState.initial;
  int _latencyMs = -1;
  String? _errorMessage;
  bool _isRefreshing = false;
  DateTime? _lastUpdated;
  Timer? _pollingTimer;
  bool _isBusy = false;
  bool _isDisposed = false;
  bool _isPollingPaused = false;
  int _consecutiveFailures = 0;

  AppUpdateInfo? _availableUpdate;
  bool _isCheckingUpdate = false;

  RouterController(this._prefs, {RouterApiService? apiService, GithubUpdateService? updateService}) {
    _apiService = apiService ?? RouterApiService(_prefs);
    _updateService = updateService ?? GithubUpdateService(_prefs);
  }

  GithubUpdateService get updateService => _updateService;
  PreferencesService get prefs => _prefs;
  AppUpdateInfo? get availableUpdate => _availableUpdate;
  bool get isCheckingUpdate => _isCheckingUpdate;

  @override
  RouterStatusModel? get status => _status;

  @override
  set status(RouterStatusModel? val) {
    _status = val;
  }

  RouterConnectionState get connectionState => _connectionState;
  int get latencyMs => _latencyMs;
  String? get errorMessage => _errorMessage;
  bool get isRefreshing => _isRefreshing;
  DateTime? get lastUpdated => _lastUpdated;
  String get routerIp => _prefs.routerIp;
  int get routerPort => _prefs.routerPort;
  String get routerSecret => _prefs.routerSecret;
  bool get autoRefresh => _prefs.autoRefresh;
  bool get isConnected => _connectionState == RouterConnectionState.connected;
  bool get isPollingPaused => _isPollingPaused;

  double get liveDownloadSpeedBps => _speedTracker.liveDownloadSpeedBps;
  double get liveUploadSpeedBps => _speedTracker.liveUploadSpeedBps;
  String get formattedDownloadSpeed => _speedTracker.formattedDownloadSpeed;
  String get formattedUploadSpeed => _speedTracker.formattedUploadSpeed;
  List<double> get downloadSpeedHistory => _speedTracker.downloadSpeedHistory;
  List<double> get uploadSpeedHistory => _speedTracker.uploadSpeedHistory;

  double getClientDownloadSpeedBps(String mac) => _speedTracker.getClientDownloadSpeedBps(mac);
  double getClientUploadSpeedBps(String mac) => _speedTracker.getClientUploadSpeedBps(mac);
  String getClientDownloadSpeed(String mac) => _speedTracker.getClientDownloadSpeed(mac);
  String getClientUploadSpeed(String mac) => _speedTracker.getClientUploadSpeed(mac);
  String getClientTotalSpeed(String mac) => _speedTracker.getClientTotalSpeed(mac);

  @visibleForTesting
  void setStatusForTesting(RouterStatusModel status) {
    _status = status;
    _connectionState = RouterConnectionState.connected;
    notifyListeners();
  }

  Future<void> init() async {
    _connectionState = RouterConnectionState.connecting;
    notifyListeners();
    await refresh(background: false);
    _startPolling();

    if (_prefs.autoCheckUpdates) {
      Future.delayed(const Duration(seconds: 3), () {
        if (!_isDisposed) {
          checkForUpdate(silent: true, force: false);
        }
      });
    }
  }

  Future<AppUpdateInfo?> checkForUpdate({bool silent = false, bool force = false}) async {
    if (_isCheckingUpdate) return _availableUpdate;
    _isCheckingUpdate = true;
    notifyListeners();
    try {
      final info = await _updateService.checkForUpdate(force: force);
      if (info != null && info.hasUpdate) {
        _availableUpdate = info;
      } else {
        _availableUpdate = null;
      }
      return info;
    } finally {
      _isCheckingUpdate = false;
      notifyListeners();
    }
  }

  void pausePolling() {
    _isPollingPaused = true;
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resumePolling() {
    if (!_isPollingPaused) return;
    _isPollingPaused = false;
    _consecutiveFailures = 0;
    if (_prefs.autoRefresh) {
      if (!_isBusy) refresh(background: true);
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    if (_isPollingPaused || !_prefs.autoRefresh) return;

    final int interval = isConnected
        ? 5
        : ((_consecutiveFailures >= 3) ? 60 : ((_consecutiveFailures >= 2) ? 30 : 15));

    _pollingTimer = Timer(Duration(seconds: interval), () async {
      if (!_isBusy && !_isPollingPaused) {
        await refresh(background: true);
      }
      if (!_isPollingPaused && _prefs.autoRefresh) {
        _startPolling();
      }
    });
  }

  @override
  Future<void> refresh({bool background = false}) async {
    if (_isBusy) return;
    _isBusy = true;

    if (!background) {
      _isRefreshing = true;
      notifyListeners();
    }

    try {
      final stopwatch = Stopwatch()..start();
      final statusData = await _apiService.fetchStatus();
      stopwatch.stop();

      _status = statusData;
      _connectionState = RouterConnectionState.connected;
      _errorMessage = null;
      _latencyMs = stopwatch.elapsedMilliseconds;
      _consecutiveFailures = 0;

      _speedTracker.updateSpeeds(statusData);
      _lastUpdated = DateTime.now();
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
      if (!_isDisposed) notifyListeners();
    }
  }

  Future<PingResult> testConnection({required String ip, required int port}) async {
    return await _apiService.pingRouter(targetIp: ip, targetPort: port);
  }

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

  @override
  Future<Map<String, dynamic>> executeAction(
    String command, [
    Map<String, dynamic>? params,
  ]) async {
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
          newClient = (newName != null && newName.isNotEmpty)
              ? oldClient.copyWith(customName: newName)
              : oldClient.copyWith(resetCustomName: true);
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
      await Future.delayed(const Duration(milliseconds: 600));
      await refresh(background: true);
      return res;
    } catch (e) {
      if (previousClients != null && _status != null) {
        _status = _status!.copyWith(clients: previousClients);
        notifyListeners();
      }
      rethrow;
    }
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
