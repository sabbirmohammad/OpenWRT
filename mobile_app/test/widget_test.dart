import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/theme/glossy_colors.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/widgets/circular_gauge.dart';
import 'package:mobile_app/presentation/widgets/glossy_badge.dart';
import 'package:mobile_app/presentation/widgets/glossy_bottom_bar.dart';
import 'package:mobile_app/presentation/widgets/glossy_button.dart';
import 'package:mobile_app/presentation/widgets/glossy_card.dart';
import 'package:mobile_app/presentation/widgets/hardware_vital_tile.dart';
import 'package:mobile_app/presentation/widgets/traffic_sparkline.dart';

void main() {
  group('Modern Glossy UI Widgets Test', () {
    testWidgets('GlossyCard renders child and acrylic decoration', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlossyCard(
              child: Text('Frosted Glass Content'),
            ),
          ),
        ),
      );

      expect(find.text('Frosted Glass Content'), findsOneWidget);
      expect(find.byType(GlossyCard), findsOneWidget);
    });

    testWidgets('GlossyBadge displays label and status dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlossyBadge(
              label: '4ms • Connected',
              dotColor: GlossyColors.emeraldMint,
            ),
          ),
        ),
      );

      expect(find.text('4ms • Connected'), findsOneWidget);
    });

    testWidgets('GlossyButton renders and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlossyButton(
              label: 'Reboot Router',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Reboot Router'), findsOneWidget);
      await tester.tap(find.byType(GlossyButton));
      expect(tapped, isTrue);
    });

    testWidgets('CircularGauge renders percentage and labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularGauge(
              value: 42.0,
              label: 'CPU Usage',
              subtitle: '880 MHz',
            ),
          ),
        ),
      );

      expect(find.text('42%'), findsOneWidget);
      expect(find.text('CPU Usage'), findsOneWidget);
      expect(find.text('880 MHz'), findsOneWidget);
    });
  });

  group('RouterStatusModel Serialization Test', () {
    test('Parses raw router JSON correctly', () {
      final sampleJson = {
        "cpu": {
          "cores": 2,
          "threads": 4,
          "model": "MediaTek MT7621DAT @ 880MHz",
          "architecture": "MIPS 1004Kc V2.15",
          "frequency_mhz": 880,
          "usage_percent": 18,
          "temperature_c": 42,
          "load_avg": "0.76, 0.60, 0.66",
          "uptime_seconds": 27882
        },
        "memory": {
          "total_kb": 118768,
          "used_kb": 52196,
          "free_kb": 45644,
          "cached_kb": 20928,
          "available_kb": 32200,
          "type": "DDR3 1200MHz",
          "usage_percent": 43
        },
        "storage": {
          "total_kb": 7808,
          "used_kb": 2400,
          "available_kb": 5408,
          "device": "16MB SPI NOR Flash",
          "usage_percent": 30
        },
        "traffic": {
          "interface": "wan",
          "rx_bytes": 22837608610,
          "tx_bytes": 3853016392,
          "wan_ip": "172.29.202.225"
        },
        "network": {
          "hw_offload": {"enabled": true},
          "sqm": {"enabled": false},
          "wan_details": {
            "gateway": "172.17.128.1",
            "protocol": "PPPoE (Fiber Optic ONU)"
          }
        },
        "wireless": {
          "radio_2g": {
            "band": "2.4GHz",
            "enabled": true,
            "ssid": "Wi-Fi",
            "channel": 11,
            "txpower_dbm": 22,
            "connected_clients": 3
          },
          "radio_5g": {
            "band": "5GHz",
            "enabled": true,
            "ssid": "Wi-Fi 5G",
            "channel": 149,
            "txpower_dbm": 23,
            "connected_clients": 1
          },
          "guest": {
            "enabled": true,
            "ssid": "Internet",
            "connected_clients": 1
          }
        },
        "clients": [
          {
            "mac": "ca:66:df:1b:b0:17",
            "ip": "192.168.1.239",
            "hostname": "Sabbir-s-A34",
            "signal_dbm": -50,
            "connection_type": "5GHz",
            "ssid_name": "Wi-Fi 5G",
            "rx_bytes": 69250282,
            "tx_bytes": 5649000,
            "connected_seconds": 2670,
            "blocked": false,
            "nds_authenticated": false
          }
        ],
        "leds": {"stealth_mode": false},
        "timestamp": 1792166904
      };

      final model = RouterStatusModel.fromJson(sampleJson);

      expect(model.cpu.cores, 2);
      expect(model.cpu.model, contains('MT7621DAT'));
      expect(model.cpu.usagePercent, 18.0);
      expect(model.memory.usedKb, 52196);
      expect(model.storage.device, contains('SPI NOR Flash'));
      expect(model.traffic.wanIp, '172.29.202.225');
      expect(model.wireless.radio2g.ssid, 'Wi-Fi');
      expect(model.wireless.radio5g.ssid, 'Wi-Fi 5G');
      expect(model.clients.length, 1);
      expect(model.clients.first.hostname, 'Sabbir-s-A34');
      expect(model.clients.first.ip, '192.168.1.239');
      expect(model.stealthLeds, isFalse);
    });
  });

  group('GlossyBottomBar Tests', () {
    testWidgets('GlossyBottomBar renders all 5 navigation tabs and badges', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: GlossyBottomBar(
              currentIndex: selectedTab,
              onTap: (index) => selectedTab = index,
              clientCount: 5,
            ),
          ),
        ),
      );

      // Verify all 5 tab labels are rendered
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Devices'), findsOneWidget);
      expect(find.text('Wireless'), findsOneWidget);
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);

      // Verify the client count badge on Devices tab
      expect(find.text('5'), findsOneWidget);

      // Tap on 'Devices' tab
      await tester.tap(find.text('Devices'));
      await tester.pumpAndSettle();

      expect(selectedTab, 1);

      // Tap on 'Menu' tab
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      expect(selectedTab, 4);
    });
  });

  group('Hardware Vital Graphical Tiles Test', () {
    testWidgets('UptimeStabilityTile renders uptime and stability bar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UptimeStabilityTile(
              formattedUptime: '5d 14h 22m',
              uptimeSeconds: 483840,
            ),
          ),
        ),
      );

      expect(find.text('UPTIME'), findsOneWidget);
      expect(find.text('5d 14h 22m'), findsOneWidget);
      expect(find.text('100% Stability'), findsOneWidget);
    });

    testWidgets('LoadAverageTile renders 3 horizontal load bars for 1m, 5m, 15m', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LoadAverageTile(
              loadAvgString: '0.24, 0.18, 0.15',
            ),
          ),
        ),
      );

      expect(find.text('LOAD AVG'), findsOneWidget);
      expect(find.text('1m'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('15m'), findsOneWidget);
      expect(find.text('0.24'), findsOneWidget);
      expect(find.text('0.18'), findsOneWidget);
      expect(find.text('0.15'), findsOneWidget);
    });

    testWidgets('CpuCoresDieTile renders horizontal core bars and thread tags', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CpuCoresDieTile(
              cores: 2,
              threads: 4,
              cpuUsagePercent: 25.0,
            ),
          ),
        ),
      );

      expect(find.text('CPU CORES'), findsOneWidget);
      expect(find.text('Core 1'), findsOneWidget);
      expect(find.text('Core 2'), findsOneWidget);
      expect(find.text('T1•T2'), findsOneWidget);
      expect(find.text('T3•T4'), findsOneWidget);
      expect(find.text('2 Cores / 4 Threads'), findsOneWidget);
    });

    testWidgets('ClockFrequencyTile renders frequency and capacity gauge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ClockFrequencyTile(
              frequencyMhz: 880,
            ),
          ),
        ),
      );

      expect(find.text('CLOCK SPEED'), findsOneWidget);
      expect(find.text('880 MHz'), findsNWidgets(2));
      expect(find.text('Peak Turbo'), findsOneWidget);
      expect(find.text('100% Capacity'), findsOneWidget);
    });
  });

  group('Traffic Speed & Sparkline Tests', () {
    test('TrafficInfo.formatSpeed formats B/s, KB/s, and Mbps correctly', () {
      expect(TrafficInfo.formatSpeed(0), '0.0 KB/s');
      expect(TrafficInfo.formatSpeed(500), '500 B/s');
      expect(TrafficInfo.formatSpeed(50 * 1024), '50.0 KB/s');
      // 256 KB/s * 8 bits = 2.1 Mbps
      expect(TrafficInfo.formatSpeed(256 * 1024), '2.1 Mbps');
      // 2 MB/s = 16.8 Mbps
      expect(TrafficInfo.formatSpeed(2 * 1024 * 1024), contains('Mbps'));
    });

    testWidgets('TrafficSparkline renders smoothly with data points', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100,
              height: 30,
              child: TrafficSparkline(
                data: [1000, 5000, 3000, 8000, 12000],
                color: GlossyColors.emeraldMint,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TrafficSparkline), findsOneWidget);
    });
  });
}
