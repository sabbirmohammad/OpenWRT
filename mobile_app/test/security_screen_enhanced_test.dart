import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/security_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RouterController controller;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PreferencesService(sp);
    controller = RouterController(prefs);

    final status = RouterStatusModel(
      stealthLeds: false,
      cpu: CpuInfo(
        cores: 2,
        threads: 4,
        model: 'MediaTek MT7621DAT',
        architecture: 'MIPS',
        frequencyMhz: 880,
        usagePercent: 18.0,
        temperatureC: 43.0,
        loadAvg: '0.15',
        uptimeSeconds: 14200,
      ),
      memory: MemoryInfo(
        totalKb: 131072,
        usedKb: 54000,
        freeKb: 40000,
        cachedKb: 27000,
        availableKb: 77000,
        type: 'DDR3',
        usagePercent: 41.0,
      ),
      storage: StorageInfo(
        totalKb: 16384,
        usedKb: 10240,
        availableKb: 6144,
        device: 'Flash',
        usagePercent: 62.0,
      ),
      traffic: TrafficInfo(
        interfaceName: 'wan',
        rxBytes: 25000000,
        txBytes: 5000000,
        wanIp: '103.145.12.84',
        currentDownloadMbps: 12.5,
        currentUploadMbps: 3.2,
      ),
      network: NetworkInfo(
        hwOffload: true,
        flowOffloadingHw: true,
        sqmEnabled: true,
        gateway: '103.145.12.1',
        dns: '1.1.1.1, 8.8.8.8',
        protocol: 'PPPoE',
        wireguardEnabled: true,
        dohEnabled: true,
        dnsRebindProtection: true,
        wanLockdown: true,
      ),
      wireless: WirelessInfo(
        radio2g: RadioInfo(band: '2.4 GHz', enabled: true, ssid: 'Archer_2.4G', channel: 6, txpowerDbm: 20, connectedClients: 1),
        radio5g: RadioInfo(band: '5.0 GHz', enabled: true, ssid: 'Archer_5G', channel: 36, txpowerDbm: 23, connectedClients: 1),
        guest: RadioInfo(band: '2.4 GHz', enabled: false, ssid: 'Archer_Guest', channel: 6, txpowerDbm: 18, connectedClients: 0),
        pmfProtected: true,
        fastRoaming: true,
      ),
      clients: [
        ClientInfo(
          mac: '3c:22:fb:1a:2b:3c',
          ip: '192.168.1.101',
          hostname: "Sabbir's MacBook Pro",
          connectionType: '5GHz',
          ssidName: 'Archer_5G',
          signalDbm: -45,
          rxBytes: 50000000,
          txBytes: 15000000,
          connectedSeconds: 3600,
          blocked: false,
          ndsAuthenticated: true,
        ),
        ClientInfo(
          mac: 'aa:bb:cc:dd:ee:ff',
          ip: '192.168.1.199',
          hostname: 'Rogue-Device',
          connectionType: '2.4GHz',
          ssidName: 'Archer_2.4G',
          signalDbm: -75,
          rxBytes: 100000,
          txBytes: 20000,
          connectedSeconds: 120,
          blocked: true,
          ndsAuthenticated: false,
        ),
      ],
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
    );

    controller.setStatusForTesting(status);
  });

  group('Enhanced SecurityScreen Tests', () {
    testWidgets('renders all security cards: Score, PMF, Rebind, WAN Lock, WireGuard, DoH, Blocklist', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: SecurityScreen(controller: controller),
        ),
      );

      // Verify Score and Checklist button
      expect(find.text('Security Hub'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('Security Level: A+ Optimal'), findsOneWidget);
      expect(find.text('Security Audit & Posture Checklist'), findsOneWidget);

      // Verify Core Defense cards
      expect(find.text('802.11w PMF Deauth Defense'), findsOneWidget);
      expect(find.text('DNS Rebinding Attack Guard'), findsOneWidget);
      expect(find.text('Remote WAN Access Lockdown'), findsWidgets);
      expect(find.text('WireGuard VPN Tunnel Shield'), findsOneWidget);
      expect(find.text('DNS-over-HTTPS (DoH) Privacy'), findsOneWidget);
      expect(find.text('Stealth LED Night Mode'), findsOneWidget);
      expect(find.text('Client Access & Blocklist'), findsOneWidget);
      expect(find.text('Automated Threat Defenses'), findsOneWidget);
    });

    testWidgets('Tapping Security Audit button opens Posture checklist sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: SecurityScreen(controller: controller),
        ),
      );

      final auditButton = find.text('Security Audit & Posture Checklist');
      expect(auditButton, findsOneWidget);
      await tester.tap(auditButton);
      await tester.pumpAndSettle();

      expect(find.text('Security Audit & Posture'), findsOneWidget);
      expect(find.text('802.11w Protected Management Frames (PMF)'), findsOneWidget);
      expect(find.text('DNS Rebinding Attack Protection'), findsOneWidget);
      expect(find.text('Remote WAN Management Lockdown'), findsOneWidget);
      expect(find.text('All Essential Router Protections Active!'), findsOneWidget);
    });

    testWidgets('Tapping Quick Action connected devices button opens picker bottom sheet', (tester) async {
      await tester.binding.setSurfaceSize(const Size(412, 1200));

      await tester.pumpWidget(
        MaterialApp(
          home: SecurityScreen(controller: controller),
        ),
      );

      final pickerButton = find.text('Quick Action: Select Connected Device (2 Online)');
      expect(pickerButton, findsOneWidget);
      await tester.tap(pickerButton);
      await tester.pumpAndSettle();

      expect(find.text('Select Client to Kick or Block'), findsOneWidget);
      expect(find.text("Sabbir's MacBook Pro"), findsOneWidget);
      expect(find.text('Rogue-Device'), findsWidgets);
      expect(find.text('Block'), findsWidgets); // For unblocked device and manual input
      expect(find.text('Unblock'), findsWidgets); // For blocked device
    });
  });
}
