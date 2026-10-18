import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late RouterController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'router_ip': '192.168.1.1',
      'router_port': 80,
      'router_secret': 'admin_secret_c6',
      'auto_refresh': true,
    });
    prefs = await PreferencesService.init();
    controller = RouterController(prefs);
  });

  tearDown(() {
    controller.dispose();
  });

  group('Battery Optimization & Lifecycle Tests', () {
    test('pausePolling pauses polling timer and marks isPollingPaused true', () {
      expect(controller.isPollingPaused, isFalse);

      controller.pausePolling();
      expect(controller.isPollingPaused, isTrue);
    });

    test('resumePolling unpauses polling and resets state', () {
      controller.pausePolling();
      expect(controller.isPollingPaused, isTrue);

      controller.resumePolling();
      expect(controller.isPollingPaused, isFalse);
    });

    test('setStatusForTesting sets connected state without starting uncontrolled timer', () {
      final sampleStatus = RouterStatusModel.fromJson({
        "cpu": {
          "cores": 2,
          "threads": 4,
          "model": "MediaTek MT7621DAT",
          "architecture": "MIPS",
          "frequency_mhz": 880,
          "usage_percent": 15,
          "temperature_c": 40,
          "load_avg": "0.10, 0.12, 0.15",
          "uptime_seconds": 1200
        },
        "memory": {
          "total_kb": 128000,
          "used_kb": 40000,
          "free_kb": 88000,
          "cached_kb": 20000,
          "available_kb": 80000,
          "type": "DDR3",
          "usage_percent": 31
        },
        "storage": {
          "total_kb": 16000,
          "used_kb": 4000,
          "available_kb": 12000,
          "device": "NOR Flash",
          "usage_percent": 25
        },
        "traffic": {
          "interface": "wan",
          "rx_bytes": 1000,
          "tx_bytes": 1000,
          "wan_ip": "1.2.3.4"
        },
        "network": {
          "hw_offload": {"enabled": true},
          "sqm": {"enabled": false},
          "wan_details": {"gateway": "1.2.3.1", "protocol": "PPPoE"}
        },
        "wireless": {
          "radio_2g": {"band": "2.4GHz", "enabled": true, "ssid": "Test2G", "channel": 1, "txpower_dbm": 20, "connected_clients": 0},
          "radio_5g": {"band": "5GHz", "enabled": true, "ssid": "Test5G", "channel": 36, "txpower_dbm": 20, "connected_clients": 0},
          "guest": {"enabled": false, "ssid": "Guest", "connected_clients": 0}
        },
        "clients": [],
        "leds": {"stealth_mode": false},
        "timestamp": 1234567890
      });

      controller.setStatusForTesting(sampleStatus);
      expect(controller.isConnected, isTrue);
      expect(controller.status?.cpu.cores, 2);
    });
  });
}
