import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../../models/router_status_model.dart';
import 'preferences_service.dart';

class PingResult {
  final bool isOnline;
  final int latencyMs;
  final String? error;

  PingResult({required this.isOnline, required this.latencyMs, this.error});
}

class RouterApiService {
  final http.Client _client;
  final PreferencesService _prefs;

  RouterApiService(this._prefs, {http.Client? client}) : _client = client ?? http.Client();

  String get _currentBaseUrl {
    final ip = _prefs.routerIp;
    final port = _prefs.routerPort;
    if (port == 80) {
      return 'http://$ip${ApiConstants.apiPath}';
    }
    return 'http://$ip:$port${ApiConstants.apiPath}';
  }

  /// Direct local network ping test to measure latency in milliseconds
  Future<PingResult> pingRouter({String? targetIp, int? targetPort}) async {
    final ip = targetIp ?? _prefs.routerIp;
    final port = targetPort ?? _prefs.routerPort;
    final url = port == 80
        ? 'http://$ip${ApiConstants.apiPath}?action=speed'
        : 'http://$ip:$port${ApiConstants.apiPath}?action=speed';

    final stopwatch = Stopwatch()..start();
    try {
      final response = await _client.get(
        Uri.parse(url),
      ).timeout(ApiConstants.timeout);

      stopwatch.stop();

      if (response.statusCode == 200) {
        return PingResult(
          isOnline: true,
          latencyMs: stopwatch.elapsedMilliseconds,
        );
      } else {
        return PingResult(
          isOnline: false,
          latencyMs: stopwatch.elapsedMilliseconds,
          error: 'HTTP ${response.statusCode}',
        );
      }
    } on SocketException catch (e) {
      stopwatch.stop();
      return PingResult(
        isOnline: false,
        latencyMs: -1,
        error: 'Network unreachable: Make sure you are connected to the router Wi-Fi (${e.message})',
      );
    } on TimeoutException {
      stopwatch.stop();
      return PingResult(
        isOnline: false,
        latencyMs: -1,
        error: 'Connection timed out. Check router IP.',
      );
    } catch (e) {
      stopwatch.stop();
      return PingResult(
        isOnline: false,
        latencyMs: -1,
        error: e.toString(),
      );
    }
  }

  /// Fetches complete router telemetry from local OpenWrt API
  Future<RouterStatusModel> fetchStatus() async {
    final uri = Uri.parse('$_currentBaseUrl?action=status');

    try {
      final response = await _client.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Cache-Control': 'no-cache',
          if (_prefs.routerSecret.isNotEmpty) ...{
            'X-Router-Secret': _prefs.routerSecret,
            'Authorization': 'Bearer ${_prefs.routerSecret}',
          },
        },
      ).timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return RouterStatusModel.fromJson(decoded);
      } else {
        throw HttpException('Router returned HTTP ${response.statusCode}: ${response.body}');
      }
    } on SocketException {
      throw const SocketException('Local router unreachable. Ensure device is on Router Wi-Fi.');
    }
  }

  /// Executes atomic router actions (reboot, drop_caches, led_stealth, etc.)
  Future<Map<String, dynamic>> executeAction({
    required String command,
    Map<String, dynamic>? params,
  }) async {
    final uri = Uri.parse('$_currentBaseUrl?action=control');
    final secret = _prefs.routerSecret;

    final bodyPayload = {
      'command': command,
      'cmd': command,
      'secret': secret,
      ...?params,
    };

    try {
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'X-Router-Secret': secret,
          if (secret.isNotEmpty) 'Authorization': 'Bearer $secret',
        },
        body: jsonEncode(bodyPayload),
      ).timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        final err = decoded['error'] ?? decoded['message'] ?? 'Router HTTP ${response.statusCode}';
        throw Exception(err);
      }
      if (decoded['status'] == 'error' || decoded['success'] == false) {
        throw Exception(decoded['message'] ?? decoded['error'] ?? 'Router action failed');
      }
      return decoded;
    } catch (e) {
      throw Exception('Failed to execute $command: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
