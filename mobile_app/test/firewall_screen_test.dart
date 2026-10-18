import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/firewall_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

RouterStatusModel _buildFullFirewallStatus() {
  final sampleJson = {
    "cpu": {
      "cores": 2,
      "threads": 4,
      "model": "MediaTek MT7621DAT @ 880MHz",
      "architecture": "MIPS 1004Kc V2.15",
      "frequency_mhz": 880,
      "usage_percent": 22,
      "temperature_c": 44,
      "load_avg": "0.45, 0.50, 0.40",
      "uptime_seconds": 12500
    },
    "memory": {
      "total_kb": 131072,
      "used_kb": 54200,
      "free_kb": 42000,
      "cached_kb": 24000,
      "available_kb": 66000,
      "type": "DDR3 1200MHz",
      "usage_percent": 41
    },
    "storage": {
      "total_kb": 16384,
      "used_kb": 10240,
      "available_kb": 6144,
      "device": "16MB SPI NOR Flash",
      "usage_percent": 62
    },
    "traffic": {
      "interface": "wan",
      "rx_bytes": 125000000,
      "tx_bytes": 35000000,
      "wan_ip": "103.145.12.84",
      "current_download_mbps": 48.5,
      "current_upload_mbps": 14.2,
      "ping_ms": 11
    },
    "network": {
      "hw_offload": {"enabled": true},
      "sqm": {"enabled": true},
      "wan_details": {
        "gateway": "103.145.12.1",
        "protocol": "PPPoE (Fiber Optic ONU)"
      },
      "wireguard": {"enabled": false},
      "doh": {"enabled": true},
      "dns_rebind_protection": true,
      "wan_lockdown": true
    },
    "wireless": {
      "radio_2g": {"enabled": true, "ssid": "Archer_C6_2.4G", "channel": 6, "connected_clients": 2},
      "radio_5g": {"enabled": true, "ssid": "Archer_C6_5G", "channel": 149, "connected_clients": 3},
      "guest": {"enabled": true, "ssid": "ArcherC6_Guest", "channel": 6, "connected_clients": 1}
    },
    "clients": [
      {
        "mac": "3c:22:fb:1a:2b:3c",
        "ip": "192.168.1.101",
        "hostname": "Sabbir MacBook Pro",
        "connection_type": "5GHz",
        "ssid_name": "Archer_C6_5G",
        "signal_dbm": -45,
        "rx_bytes": 12500000,
        "tx_bytes": 4500000,
        "connected_seconds": 3600,
        "blocked": false,
        "nds_authenticated": true
      },
      {
        "mac": "ff:ee:dd:cc:bb:aa",
        "ip": "192.168.1.199",
        "hostname": "Rogue Intruder Device",
        "connection_type": "LAN",
        "ssid_name": "",
        "signal_dbm": 0,
        "rx_bytes": 5000,
        "tx_bytes": 2000,
        "connected_seconds": 60,
        "blocked": true,
        "nds_authenticated": false
      }
    ],
    "leds": {"stealth_mode": false},
    "firewall": {
      "engine": "nftables v1.0.8 (fw4)",
      "table": "table inet fw4",
      "status": "enforcing",
      "syn_flood": true,
      "drop_invalid": true,
      "wan_ping": false,
      "wan_lockdown": true,
      "dns_rebind": true,
      "flow_offload": true,
      "flow_offload_hw": true,
      "mss_clamping": true,
      "anti_spoofing": true,
      "ipv6_firewall": true,
      "stealth_mode": true,
      "guest_isolation": true,
      "dmz_enabled": true,
      "dmz_ip": "192.168.1.150",
      "conntrack_count": 342,
      "conntrack_max": 16384,
      "port_forwards": [
        {
          "id": "pf_web",
          "name": "HTTP Web Server",
          "proto": "tcp",
          "extPort": "8080",
          "intIp": "192.168.1.101",
          "intPort": "80",
          "enabled": true
        },
        {
          "id": "pf_wireguard",
          "name": "WireGuard VPN",
          "proto": "udp",
          "extPort": "51820",
          "intIp": "192.168.1.1",
          "intPort": "51820",
          "enabled": false
        }
      ],
      "traffic_rules": [
        {
          "id": "tr_ping",
          "name": "Allow Ping from LAN to Router",
          "proto": "icmp",
          "src": "lan",
          "dest": "router",
          "target": "ACCEPT",
          "enabled": true
        },
        {
          "id": "tr_guest_drop",
          "name": "Block Guest Access to Router Admin",
          "proto": "all",
          "src": "guest",
          "dest": "router",
          "target": "DROP",
          "enabled": true
        }
      ]
    },
    "timestamp": 1729000000
  };

  return RouterStatusModel.fromJson(sampleJson);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PreferencesService prefs;
  late RouterController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    prefs = PreferencesService(sp);
    controller = RouterController(prefs);
    controller.setStatusForTesting(_buildFullFirewallStatus());
  });

  group('Enhanced FirewallScreen Suite Tests', () {
    testWidgets('renders all major firewall sections cleanly', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Header and Engine
      expect(find.text('Firewall & Traffic Guard'), findsOneWidget);
      expect(find.text('Firewall 4 (nftables)'), findsOneWidget);
      expect(find.text('table inet fw4'), findsOneWidget);
      expect(find.text('Enforcing'), findsOneWidget);
      expect(find.text('Conntrack State Table'), findsOneWidget);
      expect(find.text('Flush Table'), findsOneWidget);

      // NAT Flow Offloading
      expect(find.text('NAT Flow Offloading'), findsOneWidget);
      expect(find.text('Software Flow Offload'), findsOneWidget);
      expect(find.text('Hardware Flow Offload (MT7621 PPE)'), findsOneWidget);
      expect(find.text('TCP MSS Clamping (MTU Fix)'), findsOneWidget);
      expect(find.text('Anti-Spoofing & Martian Filter (rp_filter)'), findsOneWidget);
      expect(find.text('IPv6 Stateful Firewall'), findsOneWidget);

      // Cyber Attack & DDoS Defenses
      expect(find.text('Cyber Attack & DDoS Defenses'), findsOneWidget);
      expect(find.text('TCP SYN Flood Protection'), findsOneWidget);
      expect(find.text('Drop Invalid Packets'), findsOneWidget);
      expect(find.text('Stealth Port Probing Shield'), findsOneWidget);
      expect(find.text('WAN Ping Response (ICMP Echo)'), findsOneWidget);
      expect(find.text('Remote WAN Lockdown'), findsOneWidget);
      expect(find.text('DNS Rebind Mitigation'), findsOneWidget);

      // Zone Forwarding & Isolation
      expect(find.text('Zone Forwarding & Isolation'), findsOneWidget);
      expect(find.text('LAN Zone (Private)'), findsOneWidget);
      expect(find.text('WAN Zone (Public)'), findsOneWidget);
      expect(find.text('Guest Zone (Isolated)'), findsOneWidget);
      expect(find.text('Guest Network Isolation'), findsOneWidget);
      expect(find.text('Demilitarized Zone (DMZ)'), findsOneWidget);

      // Port Forwarding
      expect(find.text('Port Forwarding (NAT)'), findsOneWidget);
      expect(find.text('HTTP Web Server'), findsOneWidget);
      expect(find.text('WireGuard VPN'), findsOneWidget);

      // Traffic Filter Rules
      expect(find.text('Traffic Filter Rules'), findsOneWidget);
      expect(find.text('Allow Ping from LAN to Router'), findsOneWidget);
      expect(find.text('Block Guest Access to Router Admin'), findsOneWidget);

      // Firewall Blocklist
      expect(find.text('Firewall Blocklist'), findsOneWidget);
      expect(find.text('Rogue Intruder Device'), findsOneWidget);
      expect(find.text('Unblock'), findsOneWidget);

      // Maintenance Controls
      expect(find.text('Firewall Maintenance & Control'), findsOneWidget);
      expect(find.text('Reload Rules'), findsOneWidget);
      expect(find.text('Restart Subsystem'), findsOneWidget);
      expect(find.text('Flush Conntrack'), findsOneWidget);
      expect(find.text('Factory Defaults'), findsOneWidget);
    });

    testWidgets('tapping Add Port Forward opens interactive sheet with device suggestions', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      // Find the add icon on Port Forwarding card
      final addRuleBtn = find.byTooltip('Add Rule');
      expect(addRuleBtn, findsOneWidget);

      await tester.ensureVisible(addRuleBtn);
      await tester.tap(addRuleBtn);
      await tester.pumpAndSettle();

      // Modal should be visible
      expect(find.text('Add Port Forwarding Rule'), findsOneWidget);
      expect(find.text('Rule Name'), findsOneWidget);
      expect(find.text('External Port'), findsOneWidget);
      expect(find.text('Internal Destination IP'), findsOneWidget);
      expect(find.text('Apply Port Forward Rule'), findsOneWidget);
    });

    testWidgets('tapping Add Traffic Filter opens interactive filter sheet', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final addFilterBtn = find.byTooltip('Add Filter');
      expect(addFilterBtn, findsOneWidget);

      await tester.ensureVisible(addFilterBtn);
      await tester.tap(addFilterBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add Traffic Filter Rule'), findsOneWidget);
      expect(find.text('Source Zone'), findsOneWidget);
      expect(find.text('Destination Zone'), findsOneWidget);
      expect(find.text('Save Traffic Filter Rule'), findsOneWidget);
    });

    testWidgets('tapping Block MAC opens interactive block sheet', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final blockMacBtn = find.byTooltip('Block MAC');
      expect(blockMacBtn, findsOneWidget);

      await tester.ensureVisible(blockMacBtn);
      await tester.tap(blockMacBtn);
      await tester.pumpAndSettle();

      expect(find.text('Block Client at Firewall Forward Chain'), findsOneWidget);
      expect(find.text('Client Hardware MAC Address'), findsOneWidget);
      expect(find.text('Enforce Firewall Drop Rule'), findsOneWidget);
    });

    testWidgets('tapping Change IP in DMZ opens DMZ configuration sheet', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: FirewallScreen(controller: controller),
        ),
      );
      await tester.pumpAndSettle();

      final changeIpBtn = find.text('Change IP');
      expect(changeIpBtn, findsOneWidget);

      await tester.ensureVisible(changeIpBtn);
      await tester.tap(changeIpBtn);
      await tester.pumpAndSettle();

      expect(find.text('Configure DMZ Host IP'), findsOneWidget);
      expect(find.text('DMZ Destination IP'), findsOneWidget);
      expect(find.text('Save & Apply DMZ'), findsOneWidget);
    });
  });
}
