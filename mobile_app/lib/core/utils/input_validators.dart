class InputValidators {
  static final RegExp _ipv4Regex = RegExp(
    r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
  );

  static final RegExp _macRegex = RegExp(
    r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
  );

  static final RegExp _safeHostRegex = RegExp(
    r'^[a-zA-Z0-9.-]+$',
  );

  /// Validates standard IPv4 address
  static bool isValidIpv4(String ip) {
    final trimmed = ip.trim();
    return _ipv4Regex.hasMatch(trimmed);
  }

  /// Validates MAC address format
  static bool isValidMac(String mac) {
    final trimmed = mac.trim();
    return _macRegex.hasMatch(trimmed);
  }

  /// Validates safe hostname or IP for shell diagnostics (prevents command injection)
  static bool isSafeHost(String host) {
    final trimmed = host.trim();
    if (trimmed.isEmpty || trimmed.length > 253) return false;
    return _safeHostRegex.hasMatch(trimmed);
  }

  /// Validates network port (1-65535)
  static bool isValidPort(dynamic port) {
    final intVal = port is int ? port : int.tryParse(port.toString().trim());
    if (intVal == null) return false;
    return intVal >= 1 && intVal <= 65535;
  }
}
