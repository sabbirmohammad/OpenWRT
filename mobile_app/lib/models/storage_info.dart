import 'model_helpers.dart';

class StorageInfo {
  final int totalKb;
  final int usedKb;
  final int availableKb;
  final String device;
  final double usagePercent;

  StorageInfo({
    required this.totalKb,
    required this.usedKb,
    required this.availableKb,
    required this.device,
    required this.usagePercent,
  });

  factory StorageInfo.fromJson(Map<String, dynamic> json) {
    return StorageInfo(
      totalKb: ModelHelpers.toInt(json['total_kb'], 1),
      usedKb: ModelHelpers.toInt(json['used_kb'], 0),
      availableKb: ModelHelpers.toInt(json['available_kb'], 0),
      device: json['device'] as String? ?? '16MB SPI NOR Flash',
      usagePercent: ModelHelpers.toDouble(json['usage_percent'], 0.0),
    );
  }

  String get formattedUsedMb => '${(usedKb / 1024).toStringAsFixed(1)} MB';
  String get formattedTotalMb => '${(totalKb / 1024).toStringAsFixed(1)} MB';
}
