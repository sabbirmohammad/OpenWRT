class ApiConstants {
  /// Default Gateway IP on local Wi-Fi / LAN
  static const String defaultGatewayIp = '192.168.1.1';

  /// Default port for OpenWrt uhttpd
  static const int defaultPort = 80;

  /// Default secret key for protected commands (from router/lib/common.sh)
  static const String defaultSecret = 'admin_secret_c6';

  /// CGI-bin API endpoint path
  static const String apiPath = '/cgi-bin/api';

  /// Connection timeout in milliseconds (responsive local LAN threshold)
  static const Duration timeout = Duration(milliseconds: 2000);

  /// Auto refresh polling interval (seconds)
  static const int defaultPollInterval = 5;
}
