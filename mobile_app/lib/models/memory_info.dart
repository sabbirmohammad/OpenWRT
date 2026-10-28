import 'model_helpers.dart';

class MemoryInfo {
  final int totalKb;
  final int usedKb;
  final int freeKb;
  final int cachedKb;
  final int availableKb;
  final String type;
  final double usagePercent;

  MemoryInfo({
    required this.totalKb,
    required this.usedKb,
    required this.freeKb,
    required this.cachedKb,
    required this.availableKb,
    required this.type,
    required this.usagePercent,
  });

  factory MemoryInfo.fromJson(Map<String, dynamic> json) {
    return MemoryInfo(
      totalKb: ModelHelpers.toInt(json['total_kb'], 1),
      usedKb: ModelHelpers.toInt(json['used_kb'], 0),
      freeKb: ModelHelpers.toInt(json['free_kb'], 0),
      cachedKb: ModelHelpers.toInt(json['cached_kb'], 0),
      availableKb: ModelHelpers.toInt(json['available_kb'], 0),
      type: json['type'] as String? ?? 'DDR3',
      usagePercent: ModelHelpers.toDouble(json['usage_percent'], 0.0),
    );
  }

  String get formattedUsedMb => '${(usedKb / 1024).toStringAsFixed(1)} MB';
  String get formattedTotalMb => '${(totalKb / 1024).toStringAsFixed(0)} MB';
}
