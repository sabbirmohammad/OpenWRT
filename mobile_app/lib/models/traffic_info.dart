import '../core/utils/formatters.dart';
import 'model_helpers.dart';

class TrafficInfo {
  final String interfaceName;
  final int rxBytes;
  final int txBytes;
  final String wanIp;
  final double currentDownloadMbps;
  final double currentUploadMbps;
  final int pingMs;

  TrafficInfo({
    required this.interfaceName,
    required this.rxBytes,
    required this.txBytes,
    required this.wanIp,
    this.currentDownloadMbps = 0.0,
    this.currentUploadMbps = 0.0,
    this.pingMs = -1,
  });

  factory TrafficInfo.fromJson(Map<String, dynamic> json) {
    return TrafficInfo(
      interfaceName: json['interface'] as String? ?? 'wan',
      rxBytes: ModelHelpers.toInt(json['rx_bytes'], 0),
      txBytes: ModelHelpers.toInt(json['tx_bytes'], 0),
      wanIp: json['wan_ip'] as String? ?? '0.0.0.0',
      currentDownloadMbps: ModelHelpers.toDouble(json['current_download_mbps'], 0.0),
      currentUploadMbps: ModelHelpers.toDouble(json['current_upload_mbps'], 0.0),
      pingMs: ModelHelpers.toInt(json['ping_ms'], -1),
    );
  }

  static String formatBytes(int bytes) => Formatters.formatBytes(bytes);

  static String formatSpeed(double bytesPerSec) => Formatters.formatSpeed(bytesPerSec);

  String get formattedRx => formatBytes(rxBytes);
  String get formattedTx => formatBytes(txBytes);
}
