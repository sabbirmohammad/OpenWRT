import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/firewall_screen.dart';
import 'package:mobile_app/presentation/screens/main_navigation_shell.dart';
import 'package:mobile_app/presentation/screens/security_screen.dart';
import 'package:mobile_app/presentation/screens/tools_screen.dart';
import 'package:mobile_app/presentation/widgets/glossy_sidebar_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

RouterStatusModel _buildTestStatus() {
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
      "wan_ip": "172.29.202.225",
      "current_download_mbps": 45.2,
      "current_upload_mbps": 12.8,
      "ping_ms": 12
    },
    "network": {
      "hw_offload": {"enabled": true},
      "sqm": {"enabled": false},
      "wan_details": {
        "gateway": "172.17.128.1",
        "protocol": "PPPoE (Fiber Optic ONU)"
      },
      "wireguard": {
        "enabled": true,
        "endpoint": "10.14.0.1:51820",
        "status": "connected"
      },
      "doh": {
        "enabled": true,
        "provider": "Cloudflare (1.1.1.1)"
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
        "hostname": "Sabbir-Phone",
        "signal_dbm": -50,
        "connection_type": "5GHz",
        "ssid_name": "Wi-Fi 5G",
        "rx_bytes": 69250282,
        "tx_bytes": 5649000,
        "connected_seconds": 2670,
        "blocked": false,
        "nds_authenticated": false
      },
      {
        "mac": "aa:bb:cc:dd:ee:ff",
        "ip": "192.168.1.150",
        "hostname": "Suspicious-Device",
        "signal_dbm": -78,
        "connection_type": "2.4GHz",
        "ssid_name": "Wi-Fi",
        "rx_bytes": 1000,
        "tx_bytes": 500,
        "connected_seconds": 120,
        "blocked": true,
        "nds_authenticated": false
      }
    ],
    "leds": {"stealth_mode": false},
    "timestamp": 1792166904
  };

  return RouterStatusModel.fromJson(sampleJson);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RouterController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'router_ip': '192.168.1.1',
      'router_port': 80,
      'router_secret': 'test_secret',
      'auto_refresh': false,
    });
    final prefs = await PreferencesService.init();
    controller = RouterController(prefs);
    controller.setStatusForTesting(_buildTestStatus());
  });

  group('GlossySidebarDrawer Tests', () {
    testWidgets('Renders all sidebar menu sections: Settings, Security, Firewall, and System Tools', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlossySidebarDrawer(controller: controller),
          ),
        ),
      );

      // Verify Drawer Header
      expect(find.text('ArcherGuard C6'), findsOneWidget);
      expect(find.text('192.168.1.1'), findsOneWidget);
      expect(find.text('CONTROL & SECURITY'), findsOneWidget);

      // Verify all requested sections exist in the sidebar menu
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Firewall'), findsOneWidget);
      expect(find.text('System & Tools'), findsOneWidget);

      // Verify Quick Action tools
      expect(find.text('QUICK ACTIONS'), findsOneWidget);
      expect(find.text('Stealth LED Mode'), findsOneWidget);
      expect(find.text('Flush Memory'), findsOneWidget);
      expect(find.text('Reboot Router'), findsOneWidget);
    });

    testWidgets('Tapping Menu in bottom navigation bar opens the sidebar drawer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: MainNavigationShell(controller: controller),
        ),
      );

      // Verify drawer is initially closed
      expect(find.text('CONTROL & SECURITY'), findsNothing);

      // Tap on the 5th item "Menu" in bottom navigation bar
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();

      // Verify the sidebar drawer is now opened and showing the sections
      expect(find.text('CONTROL & SECURITY'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Firewall'), findsOneWidget);
    });

    testWidgets('Swiping from right edge opens the sidebar drawer', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: MainNavigationShell(controller: controller),
        ),
      );

      // Verify drawer is initially closed
      expect(find.text('CONTROL & SECURITY'), findsNothing);

      // Simulate swipe / slide from right edge (x=400 inward to the left)
      await tester.dragFrom(const Offset(400, 300), const Offset(-200, 0));
      await tester.pumpAndSettle();

      // Verify sidebar drawer opened via slide
      expect(find.text('CONTROL & SECURITY'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Firewall'), findsOneWidget);
    });
  });

  group('SecurityScreen Tests', () {
    testWidgets('SecurityScreen renders score, Stealth LED, Blocklist, WireGuard, and DoH', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: SecurityScreen(controller: controller),
        ),
      );

      // Verify Security Screen Header & Title
      expect(find.text('Security Hub'), findsOneWidget);
      expect(find.text('Security Level: A+ Optimal'), findsOneWidget);

      // Verify Stealth LED Mode card
      expect(find.text('Stealth LED Night Mode'), findsOneWidget);

      // Verify Blocklist card with blocked client
      expect(find.text('Client Access & Blocklist'), findsOneWidget);
      expect(find.text('Suspicious-Device'), findsOneWidget);
      expect(find.text('Unblock'), findsOneWidget);

      // Verify WireGuard VPN Shield
      expect(find.text('WireGuard VPN Tunnel Shield'), findsOneWidget);

      // Verify DNS-over-HTTPS (DoH) Privacy
      expect(find.text('DNS-over-HTTPS (DoH) Privacy'), findsOneWidget);

      // Verify Threat Defenses
      expect(find.text('Automated Threat Defenses'), findsOneWidget);
      expect(find.text('DNS Rebinding Shield'), findsOneWidget);
    });
  });

  group('FirewallScreen Tests', () {
    testWidgets('FirewallScreen renders Firewall 4 nftables status, Flow Offload, and Zones', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );

      // Verify Firewall Title
      expect(find.text('Firewall & Traffic Guard'), findsOneWidget);

      // Verify Firewall 4 (nftables) Engine
      expect(find.text('Firewall 4 (nftables)'), findsOneWidget);
      expect(find.text('table inet fw4'), findsOneWidget);

      // Verify NAT Flow Offloading
      expect(find.text('NAT Flow Offloading'), findsOneWidget);
      expect(find.text('Software Flow Offload'), findsOneWidget);

      // Verify Zones
      expect(find.text('Zone Forwarding & Isolation'), findsOneWidget);
      expect(find.text('LAN Zone (Private)'), findsOneWidget);
      expect(find.text('WAN Zone (Public)'), findsOneWidget);
      expect(find.text('Guest Zone (Isolated)'), findsOneWidget);

      // Verify Actions
      expect(find.text('Reload Rules'), findsOneWidget);
      expect(find.text('Restart Subsystem'), findsOneWidget);
    });
  });

  group('ToolsScreen Tests', () {
    testWidgets('ToolsScreen renders hardware specs, memory & storage, ping and logs without duplications', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 915));

      await tester.pumpWidget(
        MaterialApp(
          home: ToolsScreen(controller: controller),
        ),
      );

      // Verify Header
      expect(find.text('System & Tools'), findsOneWidget);
      expect(find.text('MT7621DAT Architecture, Memory & Diagnostics'), findsOneWidget);

      // Verify Hardware Specifications
      expect(find.text('Hardware Specifications'), findsOneWidget);
      expect(find.text('Archer C6 v3'), findsOneWidget);
      expect(find.text('Processor (SoC)'), findsOneWidget);
      expect(find.text('Architecture'), findsOneWidget);
      expect(find.text('Clock Speed'), findsOneWidget);
      expect(find.text('Switch Core'), findsOneWidget);

      // Verify Memory & Storage Allocation
      expect(find.text('Memory & Storage Allocation'), findsOneWidget);
      expect(find.text('RAM Capacity (DDR3)'), findsOneWidget);

      // Verify Network Ping Diagnostic Utility
      expect(find.text('Network Ping Diagnostic'), findsOneWidget);
      expect(find.text('Run Ping Diagnostic'), findsOneWidget);
      expect(find.text('1.1.1.1 (Cloudflare)'), findsOneWidget);

      // Verify Diagnostics & Logs Card
      expect(find.text('Diagnostics & Logs'), findsOneWidget);
      expect(find.text('Inspect Logs'), findsOneWidget);
      expect(find.text('Backup Config'), findsOneWidget);

      // VERIFY ABSENCE OF DUPLICATED FUNCTIONS:
      // 1. No duplicate Reboot Router in ToolsScreen
      expect(find.text('Reboot Router'), findsNothing);
      expect(find.text('Reboot Router?'), findsNothing);

      // 2. No duplicate Flush Memory in ToolsScreen
      expect(find.text('Flush Memory'), findsNothing);

      // 3. No duplicate Stealth LED Mode in ToolsScreen
      expect(find.text('Stealth LED Mode'), findsNothing);

      // 4. No duplicate Router & Gateway Settings form in ToolsScreen
      expect(find.text('Router & Gateway Settings'), findsNothing);
      expect(find.text('Save Settings'), findsNothing);
    });
  });
}

