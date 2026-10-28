import '../../core/utils/formatters.dart';
import '../../models/router_status_model.dart';

class ClientSpeedSnapshot {
  final int lastRx;
  final int lastTx;
  final double downloadBps;
  final double uploadBps;

  ClientSpeedSnapshot({
    required this.lastRx,
    required this.lastTx,
    required this.downloadBps,
    required this.uploadBps,
  });
}

class SpeedTracker {
  int? _prevRxBytes;
  int? _prevTxBytes;
  DateTime? _prevTrafficTime;
  double _liveDownloadSpeedBps = 0.0;
  double _liveUploadSpeedBps = 0.0;
  final List<double> _downloadSpeedHistory = [];
  final List<double> _uploadSpeedHistory = [];
  final Map<String, ClientSpeedSnapshot> _clientSpeeds = {};

  double get liveDownloadSpeedBps => _liveDownloadSpeedBps;
  double get liveUploadSpeedBps => _liveUploadSpeedBps;
  String get formattedDownloadSpeed => Formatters.formatSpeed(_liveDownloadSpeedBps);
  String get formattedUploadSpeed => Formatters.formatSpeed(_liveUploadSpeedBps);
  List<double> get downloadSpeedHistory => List.unmodifiable(_downloadSpeedHistory);
  List<double> get uploadSpeedHistory => List.unmodifiable(_uploadSpeedHistory);

  double getClientDownloadSpeedBps(String mac) => _clientSpeeds[mac.toLowerCase()]?.downloadBps ?? 0.0;
  double getClientUploadSpeedBps(String mac) => _clientSpeeds[mac.toLowerCase()]?.uploadBps ?? 0.0;
  String getClientDownloadSpeed(String mac) => Formatters.formatSpeed(getClientDownloadSpeedBps(mac));
  String getClientUploadSpeed(String mac) => Formatters.formatSpeed(getClientUploadSpeedBps(mac));
  String getClientTotalSpeed(String mac) => Formatters.formatSpeed(getClientDownloadSpeedBps(mac) + getClientUploadSpeedBps(mac));

  void updateSpeeds(RouterStatusModel statusData) {
    final now = DateTime.now();
    if (_prevTrafficTime != null && _prevRxBytes != null && _prevTxBytes != null) {
      final deltaSeconds = now.difference(_prevTrafficTime!).inMilliseconds / 1000.0;
      if (deltaSeconds >= 0.5) {
        if (statusData.traffic.currentDownloadMbps > 0) {
          _liveDownloadSpeedBps = (statusData.traffic.currentDownloadMbps * 1000 * 1000) / 8;
        } else {
          final rxDiff = statusData.traffic.rxBytes - _prevRxBytes!;
          _liveDownloadSpeedBps = rxDiff >= 0 ? (rxDiff / deltaSeconds) : 0.0;
        }

        if (statusData.traffic.currentUploadMbps > 0) {
          _liveUploadSpeedBps = (statusData.traffic.currentUploadMbps * 1000 * 1000) / 8;
        } else {
          final txDiff = statusData.traffic.txBytes - _prevTxBytes!;
          _liveUploadSpeedBps = txDiff >= 0 ? (txDiff / deltaSeconds) : 0.0;
        }

        _downloadSpeedHistory.add(_liveDownloadSpeedBps);
        if (_downloadSpeedHistory.length > 10) _downloadSpeedHistory.removeAt(0);

        _uploadSpeedHistory.add(_liveUploadSpeedBps);
        if (_uploadSpeedHistory.length > 10) _uploadSpeedHistory.removeAt(0);
      }
    } else if (statusData.traffic.currentDownloadMbps > 0 || statusData.traffic.currentUploadMbps > 0) {
      _liveDownloadSpeedBps = (statusData.traffic.currentDownloadMbps * 1000 * 1000) / 8;
      _liveUploadSpeedBps = (statusData.traffic.currentUploadMbps * 1000 * 1000) / 8;
      _downloadSpeedHistory.add(_liveDownloadSpeedBps);
      _uploadSpeedHistory.add(_liveUploadSpeedBps);
    }

    final deltaSec = (_prevTrafficTime != null)
        ? now.difference(_prevTrafficTime!).inMilliseconds / 1000.0
        : 0.0;
    for (final client in statusData.clients) {
      final mac = client.mac.toLowerCase();
      final prev = _clientSpeeds[mac];
      if (prev != null && deltaSec >= 0.5) {
        final rxDiff = client.rxBytes - prev.lastRx;
        final txDiff = client.txBytes - prev.lastTx;
        _clientSpeeds[mac] = ClientSpeedSnapshot(
          lastRx: client.rxBytes,
          lastTx: client.txBytes,
          downloadBps: rxDiff >= 0 ? (rxDiff / deltaSec) : 0.0,
          uploadBps: txDiff >= 0 ? (txDiff / deltaSec) : 0.0,
        );
      } else {
        _clientSpeeds[mac] = ClientSpeedSnapshot(
          lastRx: client.rxBytes,
          lastTx: client.txBytes,
          downloadBps: prev?.downloadBps ?? 0.0,
          uploadBps: prev?.uploadBps ?? 0.0,
        );
      }
    }

    final activeMacs = statusData.clients.map((c) => c.mac.toLowerCase()).toSet();
    _clientSpeeds.removeWhere((mac, _) => !activeMacs.contains(mac));

    _prevRxBytes = statusData.traffic.rxBytes;
    _prevTxBytes = statusData.traffic.txBytes;
    _prevTrafficTime = now;
  }
}
