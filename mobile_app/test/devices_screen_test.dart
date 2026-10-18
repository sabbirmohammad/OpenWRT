import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/core/services/router_api_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/devices_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeRouterApiService extends RouterApiService {
  _FakeRouterApiService(super.prefs);

  @override
  Future<Map<String, dynamic>> executeAction({
    required String command,
    Map<String, dynamic>? params,
  }) async {
    return {'status': 'ok', 'success': true};
  }

  @override
  Future<RouterStatusModel> fetchStatus() async {
    throw const HttpException('test');
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RouterController controller;

  final sampleClients = [
    ClientInfo(
      mac: '3c:22:fb:1a:2b:3c',
      ip: '192.168.1.101',
      hostname: "Sabbir's MacBook Pro",
      connectionType: '5GHz',
      ssidName: 'Archer_C6_5G',
      signalDbm: -45,
      rxBytes: 150000000,
      txBytes: 45000000,
      connectedSeconds: 14250,
      blocked: false,
      ndsAuthenticated: true,
    ),
    ClientInfo(
      mac: 'a4:c3:f0:88:99:11',
      ip: '192.168.1.105',
      hostname: 'Galaxy S23 Ultra',
      connectionType: '2.4GHz',
      ssidName: 'Archer_C6_2.4G',
      signalDbm: -65,
      rxBytes: 50000000,
      txBytes: 10000000,
      connectedSeconds: 3600,
      blocked: true,
      ndsAuthenticated: false,
    ),
    ClientInfo(
      mac: 'b8:27:eb:d1:82:19',
      ip: '192.168.1.120',
      hostname: 'HomeAssistant Pi',
      connectionType: 'LAN',
      ssidName: 'Ethernet LAN',
      signalDbm: 0,
      rxBytes: 80000000,
      txBytes: 30000000,
      connectedSeconds: 86400,
      blocked: false,
      ndsAuthenticated: false,
    ),
    ClientInfo(
      mac: '3c:5a:37:99:88:77',
      ip: '192.168.1.135',
      hostname: 'Guest Pixel 8',
      connectionType: 'Guest',
      ssidName: 'Internet',
      signalDbm: -68,
      rxBytes: 1200000,
      txBytes: 450000,
      connectedSeconds: 1850,
      blocked: false,
      ndsAuthenticated: false,
      isIsolated: true,
    ),
  ];

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final sp = await SharedPreferences.getInstance();
    final prefs = PreferencesService(sp);
    controller = RouterController(prefs, apiService: _FakeRouterApiService(prefs));
  });

  void setupStatus(List<ClientInfo> clients) {
    final status = RouterStatusModel(
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
        sqmEnabled: true,
        gateway: '103.145.12.1',
        dns: '1.1.1.1',
        protocol: 'PPPoE',
      ),
      wireless: WirelessInfo(
        radio2g: RadioInfo(
          band: '2.4 GHz',
          enabled: true,
          ssid: 'Archer_2.4G',
          channel: 6,
          txpowerDbm: 20,
          connectedClients: 1,
        ),
        radio5g: RadioInfo(
          band: '5.0 GHz',
          enabled: true,
          ssid: 'Archer_5G',
          channel: 149,
          txpowerDbm: 23,
          connectedClients: 1,
        ),
        guest: RadioInfo(
          band: 'Guest',
          enabled: false,
          ssid: 'Guest',
          channel: 6,
          txpowerDbm: 18,
          connectedClients: 0,
        ),
      ),
      clients: clients,
      stealthLeds: false,
      timestamp: 123456789,
    );

    controller.setStatusForTesting(status);
  }

  testWidgets('DevicesScreen renders search bar and filter dropdown in header', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify search input is present
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Search device, IP, MAC...'), findsOneWidget);

    // Verify filter dropdown trigger is present beside search bar
    expect(find.text('Filter'), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);

    // Verify client cards render
    expect(find.text("Sabbir's MacBook Pro"), findsOneWidget);
    expect(find.text('Galaxy S23 Ultra'), findsOneWidget);
    expect(find.text('HomeAssistant Pi'), findsOneWidget);
  });

  testWidgets('Tapping device card opens interactive Device Details bottom sheet', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on Sabbir's MacBook Pro card
    await tester.tap(find.text("Sabbir's MacBook Pro"));
    await tester.pumpAndSettle();

    // Details Modal should be displayed
    expect(find.text('DATA CONSUMPTION'), findsOneWidget);
    expect(find.text('CONNECTION TIMING & UPTIME'), findsOneWidget);
    expect(find.text('NETWORK & HARDWARE ADDRESSING'), findsOneWidget);

    // Verify IP and MAC addresses in details
    expect(find.text('192.168.1.101'), findsWidgets);
    expect(find.text('3c:22:fb:1a:2b:3c'), findsWidgets);

    // Verify action buttons in modal
    expect(find.text('Block Access'), findsWidgets);
    expect(find.text('Deauth Portal'), findsWidgets);
    expect(find.text('Disconnect (Off)'), findsOneWidget);
    expect(find.text('Wake-on-LAN'), findsOneWidget);
  });

  testWidgets('Search query filters device list accurately', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Type 'Galaxy' in search input
    await tester.enterText(find.byType(TextField), 'Galaxy');
    await tester.pumpAndSettle();

    // Should only show Galaxy S23 Ultra
    expect(find.text('Galaxy S23 Ultra'), findsOneWidget);
    expect(find.text("Sabbir's MacBook Pro"), findsNothing);
    expect(find.text('HomeAssistant Pi'), findsNothing);
  });

  testWidgets('Dropdown selection filters by category correctly', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on filter dropdown button
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    // Verify menu items appear
    expect(find.widgetWithText(PopupMenuItem<String>, '5.0 GHz Wi-Fi'), findsOneWidget);
    expect(find.widgetWithText(PopupMenuItem<String>, '2.4 GHz Wi-Fi'), findsOneWidget);
    expect(find.widgetWithText(PopupMenuItem<String>, 'Gigabit LAN'), findsOneWidget);
    expect(find.widgetWithText(PopupMenuItem<String>, 'Isolated SSID'), findsOneWidget);
    expect(find.widgetWithText(PopupMenuItem<String>, 'Blocked Clients'), findsOneWidget);

    // Tap on '5.0 GHz Wi-Fi'
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, '5.0 GHz Wi-Fi'));
    await tester.pumpAndSettle();

    // Only Sabbir's MacBook Pro should be visible
    expect(find.text("Sabbir's MacBook Pro"), findsOneWidget);
    expect(find.text('Galaxy S23 Ultra'), findsNothing);
    expect(find.text('HomeAssistant Pi'), findsNothing);
    expect(find.text('Guest Pixel 8'), findsNothing);
  });

  testWidgets('Normal card view shows clean metadata, isolated styling, and smart device icons', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify action buttons are NOT visible on normal card view
    expect(find.text('Block Access'), findsNothing);
    expect(find.text('Deauth Portal'), findsNothing);
    expect(find.text('Disconnect (Off)'), findsNothing);
    expect(find.text('Wake-on-LAN'), findsNothing);

    // Verify smart device icons
    expect(find.byIcon(Icons.laptop_mac_rounded), findsOneWidget); // Sabbir's MacBook Pro
    expect(find.byIcon(Icons.phone_android_rounded), findsNWidgets(2)); // Galaxy S23 Ultra & Guest Pixel 8
    expect(find.byIcon(Icons.memory_rounded), findsOneWidget); // HomeAssistant Pi

    // Verify normal Wi-Fi device
    expect(find.text("Sabbir's MacBook Pro"), findsOneWidget);
    expect(find.text('5GHz • SSID: Archer_C6_5G'), findsOneWidget);
    expect(find.text('3c:22:fb:1a:2b:3c'), findsOneWidget);
    expect(find.text('-45 dBm • Excellent'), findsOneWidget);

    // Verify blocked device
    expect(find.text('Galaxy S23 Ultra'), findsOneWidget);
    expect(find.text('2.4GHz • SSID: Archer_C6_2.4G'), findsOneWidget);
    expect(find.text('a4:c3:f0:88:99:11'), findsOneWidget);
    expect(find.text('Blocked'), findsOneWidget);

    // Verify LAN device
    expect(find.text('HomeAssistant Pi'), findsOneWidget);
    expect(find.text('LAN • SSID: Ethernet LAN'), findsOneWidget);
    expect(find.text('b8:27:eb:d1:82:19'), findsOneWidget);
    expect(find.text('Gigabit LAN'), findsOneWidget);

    // Verify Isolated SSID device (Distinct color & badge)
    expect(find.text('Guest Pixel 8'), findsOneWidget);
    expect(find.text('Isolated Wi-Fi • SSID: Internet'), findsOneWidget);
    expect(find.text('3c:5a:37:99:88:77'), findsOneWidget);
    expect(find.text('Isolated • -68 dBm'), findsOneWidget);
    expect(find.byIcon(Icons.wifi_lock_rounded), findsOneWidget);
  });

  testWidgets('Isolated SSID filtering and details sheet display isolated properties', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Open filter dropdown
    await tester.tap(find.text('Filter'));
    await tester.pumpAndSettle();

    // Select Isolated SSID
    await tester.tap(find.widgetWithText(PopupMenuItem<String>, 'Isolated SSID'));
    await tester.pumpAndSettle();

    // Only Guest Pixel 8 should be shown
    expect(find.text('Guest Pixel 8'), findsOneWidget);
    expect(find.text("Sabbir's MacBook Pro"), findsNothing);
    expect(find.text('Galaxy S23 Ultra'), findsNothing);
    expect(find.text('HomeAssistant Pi'), findsNothing);

    // Tap on Guest Pixel 8 to open details sheet
    await tester.tap(find.text('Guest Pixel 8'));
    await tester.pumpAndSettle();

    // Verify isolated badges and network addressing in details sheet
    expect(find.text('Isolated SSID'), findsWidgets);
    expect(find.text('Isolated Wi-Fi • SSID: Internet'), findsWidgets);
    expect(find.text('Internet (Isolated SSID)'), findsOneWidget);
  });

  testWidgets('Long-pressing device card opens Rename Device dialog and allows renaming', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Long press on Galaxy S23 Ultra
    await tester.longPress(find.text('Galaxy S23 Ultra'));
    await tester.pumpAndSettle();

    // Verify Rename Device dialog opened
    expect(find.text('Rename Device'), findsOneWidget);
    expect(find.text('Device Nickname'), findsOneWidget);
    expect(find.text('Save Name'), findsOneWidget);

    // Enter new custom name in dialog TextField
    final dialogField = find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField));
    await tester.enterText(dialogField, 'My Work Phone');
    await tester.tap(find.text('Save Name'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(seconds: 4));

    // Verify optimistic update reflected new name
    expect(find.text('My Work Phone'), findsOneWidget);
  });

  testWidgets('Details sheet displays Rename button and opens rename dialog', (tester) async {
    setupStatus(sampleClients);

    await tester.pumpWidget(
      MaterialApp(
        home: DevicesScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Tap on device card to open details sheet
    await tester.tap(find.text("Sabbir's MacBook Pro"));
    await tester.pumpAndSettle();

    // Verify Rename button in sheet header
    expect(find.text('Rename'), findsOneWidget);

    // Tap Rename button in header
    await tester.tap(find.text('Rename'));
    await tester.pumpAndSettle();

    // Verify Rename Device dialog appeared
    expect(find.text('Rename Device'), findsWidgets);
    expect(find.text('Device Nickname'), findsOneWidget);
    expect(find.text('Save Name'), findsOneWidget);
  });
}


