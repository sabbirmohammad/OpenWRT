import '../core/utils/formatters.dart';
import 'model_helpers.dart';

class CpuInfo {
  final int cores;
  final int threads;
  final String model;
  final String architecture;
  final int frequencyMhz;
  final double usagePercent;
  final double temperatureC;
  final String loadAvg;
  final int uptimeSeconds;

  CpuInfo({
    required this.cores,
    required this.threads,
    required this.model,
    required this.architecture,
    required this.frequencyMhz,
    required this.usagePercent,
    required this.temperatureC,
    required this.loadAvg,
    required this.uptimeSeconds,
  });

  factory CpuInfo.fromJson(Map<String, dynamic> json) {
    return CpuInfo(
      cores: ModelHelpers.toInt(json['cores'], 2),
      threads: ModelHelpers.toInt(json['threads'], 4),
      model: json['model'] as String? ?? 'MediaTek MT7621DAT',
      architecture: json['architecture'] as String? ?? 'MIPS 1004Kc',
      frequencyMhz: ModelHelpers.toInt(json['frequency_mhz'], 880),
      usagePercent: ModelHelpers.toDouble(json['usage_percent'], 0.0),
      temperatureC: ModelHelpers.toDouble(json['temperature_c'], 0.0),
      loadAvg: json['load_avg'] as String? ?? '0.00',
      uptimeSeconds: ModelHelpers.toInt(json['uptime_seconds'], 0),
    );
  }

  String get formattedUptime => Formatters.formatUptime(uptimeSeconds);
}
