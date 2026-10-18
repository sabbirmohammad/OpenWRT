import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/wireless_screen.dart';

void main() {
  late RouterController controller;

  final testSsids = [
    SsidInfo(
      id: 'default_radio0',
      ssid: 'Archer_C6_2.4G',
      band: '2.4 GHz',
      radio: 'radio0',
      ifname: 'wlan0',
      enabled: true,
      encryption: 'WPA2-PSK/WPA3-SAE',
      channel: 6,
      connectedClients: 2,
      isGuest: false,
    ),
    SsidInfo(
      id: 'default_radio1',
      ssid: 'Archer_C6_5G',
      band: '5.0 GHz',
      radio: 'radio1',
      ifname: 'wlan1',
      enabled: true,
      encryption: 'WPA2-PSK/WPA3-SAE',
      channel: 149,
      connectedClients: 1,
      isGuest: false,
    ),
    SsidInfo(
      id: 'guest',
      ssid: 'ArcherC6_Guest',
      band: '2.4 GHz',
      radio: 'radio0',
      ifname: 'wlan0-1',
      enabled: false,
      encryption: 'WPA2-PSK',
      channel: 6,
      connectedClients: 0,
      isGuest: true,
      isIsolated: true,
    ),
    SsidInfo(
      id: 'ap_office',
      ssid: 'Archer_Office_IoT',
      band: '2.4 GHz',
      radio: 'radio0',
      ifname: 'wlan0-2',
      enabled: true,
      encryption: 'WPA2-PSK',
      channel: 6,
      connectedClients: 3,
      isGuest: false,
      isIsolated: false,
    ),
  ];

  final testClients = [
    ClientInfo(
      mac: '3c:22:fb:1a:2b:3c',
      ip: '192.168.1.101',
      hostname: "Sabbir's MacBook",
      connectionType: '5GHz',
      ssidName: 'Archer_C6_5G',
      signalDbm: -45,
      rxBytes: 50000000,
      txBytes: 20000000,
      connectedSeconds: 7200,
      blocked: false,
      ndsAuthenticated: true,
    ),
    ClientInfo(
      mac: 'a4:c3:f0:88:99:11',
      ip: '192.168.1.105',
      hostname: 'Galaxy S23',
      connectionType: '2.4GHz',
      ssidName: 'Archer_C6_2.4G',
      signalDbm: -55,
      rxBytes: 30000000,
      txBytes: 10000000,
      connectedSeconds: 3600,
      blocked: false,
      ndsAuthenticated: true,
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PreferencesService(sp);
    controller = RouterController(prefs);
  });

  void setupStatus({List<SsidInfo>? ssids, List<ClientInfo>? clients}) {
    final effectiveSsids = ssids ?? testSsids;
    final effectiveClients = clients ?? testClients;

    final status = RouterStatusModel(
      cpu: CpuInfo(
        cores: 2,
        threads: 4,
        model: 'MediaTek MT7621DAT',
        architecture: 'MIPS',
        frequencyMhz: 880,
        usagePercent: 15.0,
        temperatureC: 42.0,
        loadAvg: '0.10',
        uptimeSeconds: 10000,
      ),
      memory: MemoryInfo(
        totalKb: 131072,
        usedKb: 50000,
        freeKb: 50000,
        cachedKb: 31072,
        availableKb: 81072,
        type: 'DDR3',
        usagePercent: 38.0,
      ),
      storage: StorageInfo(
        totalKb: 16384,
        usedKb: 8000,
        availableKb: 8384,
        device: 'Flash',
        usagePercent: 48.0,
      ),
      traffic: TrafficInfo(
        interfaceName: 'wan',
        rxBytes: 100000000,
        txBytes: 50000000,
        currentDownloadMbps: 25.0,
        currentUploadMbps: 5.0,
        wanIp: '103.145.12.84',
        pingMs: 12,
      ),
      network: NetworkInfo(
        hwOffload: true,
        sqmEnabled: false,
        gateway: '103.145.12.1',
        dns: '1.1.1.1',
        protocol: 'PPPoE',
      ),
      wireless: WirelessInfo(
        radio2g: RadioInfo(
          band: '2.4 GHz',
          enabled: true,
          ssid: 'Archer_C6_2.4G',
          channel: 6,
          txpowerDbm: 20,
          connectedClients: 2,
        ),
        radio5g: RadioInfo(
          band: '5.0 GHz',
          enabled: true,
          ssid: 'Archer_C6_5G',
          channel: 149,
          txpowerDbm: 23,
          connectedClients: 1,
        ),
        guest: RadioInfo(
          band: 'Guest',
          enabled: false,
          ssid: 'ArcherC6_Guest',
          channel: 6,
          txpowerDbm: 18,
          connectedClients: 0,
        ),
        ssids: effectiveSsids,
      ),
      clients: effectiveClients,
      stealthLeds: false,
      timestamp: 123456789,
    );

    controller.setStatusForTesting(status);
  }

  Widget createTestWidget() {
    return MaterialApp(
      home: WirelessScreen(controller: controller),
    );
  }

  group('WirelessScreen SSID Suite Tests', () {
    testWidgets('SSID header renders total, active, and inactive counts', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify Header Section
      expect(find.text('SSID Networks'), findsOneWidget);
      expect(find.text('4 SSIDs'), findsOneWidget);
      expect(find.text('3 Active • 1 Inactive'), findsOneWidget);
      expect(find.text('Add SSID'), findsOneWidget);
    });

    testWidgets('Renders all configured SSIDs with band, encryption, and active badges', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify all 4 SSIDs are rendered
      expect(find.text('Archer_C6_2.4G'), findsWidgets);
      expect(find.text('Archer_C6_5G'), findsWidgets);
      expect(find.text('ArcherC6_Guest'), findsWidgets);
      expect(find.text('Archer_Office_IoT'), findsOneWidget);

      // Verify Guest Badge
      expect(find.text('Isolated Guest'), findsOneWidget);

      // Verify Active / Inactive Badges
      expect(find.text('Active'), findsWidgets);
      expect(find.text('Inactive'), findsWidgets);
    });

    testWidgets('Non-primary virtual SSID displays Delete button while primary does not', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Only 'Archer_Office_IoT' is a non-primary virtual SSID (ap_office)
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Tapping Edit button opens Edit SSID Modal Sheet', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find first Edit button and tap
      final editButtons = find.text('Edit');
      expect(editButtons, findsWidgets);

      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      // Modal bottom sheet should be presented
      expect(find.text('Edit SSID Configuration'), findsOneWidget);
      expect(find.text('SSID Name (Broadcast Name)'), findsOneWidget);
      expect(find.text('WPA2/WPA3 Password'), findsOneWidget);
      expect(find.text('Hide SSID Broadcast'), findsOneWidget);
      expect(find.text('Client Isolation'), findsOneWidget);
      expect(find.text('Save Configuration'), findsOneWidget);
    });

    testWidgets('Tapping Share button opens Wi-Fi Credentials Sheet', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final shareButtons = find.text('Share');
      expect(shareButtons, findsWidgets);

      await tester.tap(shareButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Share Wi-Fi Credentials'), findsOneWidget);
      expect(find.text('Copy Wi-Fi Connect String'), findsOneWidget);
    });

    testWidgets('Tapping Devices button opens Connected Clients Sheet filtered by SSID', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on '1 Devices' for Archer_C6_5G
      final devicesButton = find.text('1 Devices');
      expect(devicesButton, findsOneWidget);

      await tester.ensureVisible(devicesButton);
      await tester.tap(devicesButton);
      await tester.pumpAndSettle();

      // Connected devices sheet should show Sabbir's MacBook
      expect(find.text('Archer_C6_5G Clients'), findsOneWidget);
      expect(find.text("Sabbir's MacBook"), findsOneWidget);
      expect(find.text('-45 dBm'), findsOneWidget);
    });

    testWidgets('Tapping Add SSID button opens Add Virtual SSID Sheet', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final addSsidBtn = find.text('Add SSID');
      expect(addSsidBtn, findsOneWidget);

      await tester.tap(addSsidBtn);
      await tester.pumpAndSettle();

      expect(find.text('Add New Virtual SSID'), findsOneWidget);
      expect(find.text('2.4 GHz Radio'), findsOneWidget);
      expect(find.text('5.0 GHz Radio'), findsOneWidget);
      expect(find.text('Enforce Client Isolation'), findsOneWidget);
      expect(find.text('Create SSID'), findsOneWidget);
    });

    testWidgets('Tapping SSID card opens SsidDetailSheet with traffic, range, and quality telemetry', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap on the Archer_C6_5G card directly (not on the buttons)
      final ssidText = find.text('Archer_C6_5G');
      expect(ssidText, findsWidgets);

      await tester.ensureVisible(ssidText.first);
      await tester.tap(ssidText.first);
      await tester.pumpAndSettle();

      // Detailed Sheet should be open
      expect(find.text('Data Traffic & Bandwidth'), findsOneWidget);
      expect(find.text('Coverage Distance & Propagation'), findsOneWidget);
      expect(find.text('Network Quality & Health'), findsOneWidget);
      expect(find.text('Total Downloaded'), findsOneWidget);
      expect(find.text('Total Uploaded'), findsOneWidget);
      expect(find.text('Estimated Indoor Range'), findsOneWidget);
      expect(find.text('Signal Quality Score'), findsOneWidget);

      // Connected device for 5G should be listed in sheet
      expect(find.text("Sabbir's MacBook"), findsOneWidget);
    });

    testWidgets('Accidental touch protection: Tapping active switch shows confirmation dialog before deactivating', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find all switches (first is Master Wi-Fi, second is default_radio0)
      final switches = find.byType(Switch);
      expect(switches, findsWidgets);

      // Tap switch on active SSID (default_radio0 is at index 1)
      final radio0Switch = switches.at(1);
      await tester.ensureVisible(radio0Switch);
      await tester.tap(radio0Switch);
      await tester.pumpAndSettle();

      // Confirmation dialog should be visible to prevent accidental touch
      expect(find.text('Deactivate Network?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Turn Off'), findsOneWidget);

      // Tap Cancel to test accidental tap abort
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog dismissed, no deactivation occurred
      expect(find.text('Deactivate Network?'), findsNothing);
    });

    testWidgets('Tapping Supported Wi-Fi Protocols card opens ProtocolsDetailSheet with full technical capabilities', (tester) async {
      setupStatus();

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final protocolsTitle = find.text('Supported Wi-Fi Protocols & Roaming');
      expect(protocolsTitle, findsOneWidget);

      await tester.ensureVisible(protocolsTitle);
      await tester.tap(protocolsTitle);
      await tester.pumpAndSettle();

      // Protocols detail sheet should be open
      expect(find.text('Wi-Fi Protocols & Roaming'), findsOneWidget);
      expect(find.text('MediaTek Dual-Band SoC Architecture'), findsOneWidget);
      expect(find.text('802.11r FT (Fast BSS Transition)'), findsOneWidget);
      expect(find.text('802.11ac Wave 2 (MU-MIMO 2x2)'), findsOneWidget);
      expect(find.text('802.11w PMF (Protected Management Frames)'), findsOneWidget);
      expect(find.text('Close Standards Explorer'), findsOneWidget);

      // Close the sheet
      await tester.tap(find.text('Close Standards Explorer'));
      await tester.pumpAndSettle();
      expect(find.text('Close Standards Explorer'), findsNothing);
    });
  });
}
