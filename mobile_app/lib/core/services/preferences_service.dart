import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class PreferencesService {
  static const String _keyRouterIp = 'pref_router_ip';
  static const String _keyRouterPort = 'pref_router_port';
  static const String _keyRouterSecret = 'pref_router_secret';
  static const String _keyAutoRefresh = 'pref_auto_refresh';
  static const String _keyAutoCheckUpdates = 'pref_auto_check_updates';
  static const String _keyGithubRepo = 'pref_github_repo';
  static const String _keyLastCheckTimestamp = 'pref_last_check_timestamp';

  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  static Future<PreferencesService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return PreferencesService(prefs);
  }

  String get routerIp => _prefs.getString(_keyRouterIp) ?? ApiConstants.defaultGatewayIp;

  Future<void> setRouterIp(String ip) async {
    await _prefs.setString(_keyRouterIp, ip.trim());
  }

  int get routerPort => _prefs.getInt(_keyRouterPort) ?? ApiConstants.defaultPort;

  Future<void> setRouterPort(int port) async {
    await _prefs.setInt(_keyRouterPort, port);
  }

  String get routerSecret => _prefs.getString(_keyRouterSecret) ?? ApiConstants.defaultSecret;

  Future<void> setRouterSecret(String secret) async {
    await _prefs.setString(_keyRouterSecret, secret.trim());
  }

  bool get autoRefresh => _prefs.getBool(_keyAutoRefresh) ?? true;

  Future<void> setAutoRefresh(bool enabled) async {
    await _prefs.setBool(_keyAutoRefresh, enabled);
  }

  bool get autoCheckUpdates => _prefs.getBool(_keyAutoCheckUpdates) ?? true;

  Future<void> setAutoCheckUpdates(bool enabled) async {
    await _prefs.setBool(_keyAutoCheckUpdates, enabled);
  }

  String get githubRepo => _prefs.getString(_keyGithubRepo) ?? 'sabbirmohammad/OpenWRT';

  Future<void> setGithubRepo(String repo) async {
    await _prefs.setString(_keyGithubRepo, repo.trim());
  }

  int get lastCheckTimestamp => _prefs.getInt(_keyLastCheckTimestamp) ?? 0;

  Future<void> setLastCheckTimestamp(int timestamp) async {
    await _prefs.setInt(_keyLastCheckTimestamp, timestamp);
  }

  Future<void> resetToDefaults() async {
    await _prefs.remove(_keyRouterIp);
    await _prefs.remove(_keyRouterPort);
    await _prefs.remove(_keyRouterSecret);
    await _prefs.remove(_keyAutoRefresh);
    await _prefs.remove(_keyAutoCheckUpdates);
    await _prefs.remove(_keyGithubRepo);
    await _prefs.remove(_keyLastCheckTimestamp);
  }
}
