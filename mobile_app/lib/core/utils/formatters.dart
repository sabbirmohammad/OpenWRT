class Formatters {
  /// Formats byte counts into human-readable strings (e.g. 1.2 MB, 4.5 GB)
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  /// Formats speed from bytes/sec to human-readable strings (e.g. 500 B/s, 50.0 KB/s, 12.4 Mbps)
  static String formatSpeed(double bytesPerSec) {
    if (bytesPerSec <= 0) return '0.0 KB/s';
    final bitsPerSec = bytesPerSec * 8;
    if (bitsPerSec >= 1000 * 1000) {
      return '${(bitsPerSec / (1000 * 1000)).toStringAsFixed(1)} Mbps';
    }
    if (bytesPerSec >= 1024) {
      return '${(bytesPerSec / 1024).toStringAsFixed(1)} KB/s';
    }
    return '${bytesPerSec.toStringAsFixed(0)} B/s';
  }

  /// Formats uptime in seconds into a friendly human-readable format
  static String formatUptime(int seconds) {
    if (seconds <= 0) return '0m';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }

  /// Formats uptime in seconds with seconds included (e.g. 1d 2h 30m 45s)
  static String formatUptimeWithSeconds(int seconds) {
    if (seconds <= 0) return '0s';
    final days = seconds ~/ 86400;
    final hours = (seconds % 86400) ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m ${secs}s';
    if (hours > 0) return '${hours}h ${minutes}m ${secs}s';
    if (minutes > 0) return '${minutes}m ${secs}s';
    return '${secs}s';
  }

  /// Formats KB into MB strings
  static String formatKbToMb(int kb, {int fractionDigits = 1}) {
    return '${(kb / 1024).toStringAsFixed(fractionDigits)} MB';
  }

  /// Formats connected-since relative time string
  static String formatConnectedSince(int secondsAgo) {
    if (secondsAgo < 60) return '$secondsAgo seconds ago';
    final minutes = secondsAgo ~/ 60;
    if (minutes < 60) return '$minutes mins ago';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '${hours}h ${remainingMinutes}m ago';
  }
}
