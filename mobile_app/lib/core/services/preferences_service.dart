import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class PreferencesService {
  static const String _keyRouterIp = 'pref_router_ip';
  static const String _keyRouterPort = 'pref_router_port';
  static const String _keyRouterSecret = 'pref_router_secret';
  static const String _keyAutoRefresh = 'pref_auto_refresh';

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

  Future<void> resetToDefaults() async {
    await _prefs.remove(_keyRouterIp);
    await _prefs.remove(_keyRouterPort);
    await _prefs.remove(_keyRouterSecret);
    await _prefs.remove(_keyAutoRefresh);
  }
}
