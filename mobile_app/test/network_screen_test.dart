import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/services/preferences_service.dart';
import 'package:mobile_app/models/router_status_model.dart';
import 'package:mobile_app/presentation/controllers/router_controller.dart';
import 'package:mobile_app/presentation/screens/network_screen.dart';
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
        sqmQdisc: 'cake',
        sqmDownloadKbit: 95000,
        sqmUploadKbit: 20000,
        gateway: '103.145.12.1',
        dns: '1.1.1.1, 8.8.8.8',
        protocol: 'PPPoE (Fiber Optic ONU)',
        mtu: 1492,
        latencyMs: 8.5,
        jitterMs: 0.9,
        wireguardEnabled: false,
        wireguardInterface: 'wg0',
        wireguardEndpoint: 'sg-vpn.cyberguard.net:51820',
        wireguardStatus: 'standby',
        wireguardLatestHandshake: 'Never',
        wireguardTransferRx: 14205000,
        wireguardTransferTx: 3200100,
        multiWanEnabled: false,
        multiWanMode: 'failover',
        multiWanWan1: 'online',
        multiWanWan2: 'standby',
        dohEnabled: true,
        dohProvider: 'Cloudflare (1.1.1.1)',
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
          channel: 36,
          txpowerDbm: 23,
          connectedClients: 2,
        ),
        guest: RadioInfo(
          band: '2.4 GHz',
          enabled: false,
          ssid: 'Archer_Guest',
          channel: 6,
          txpowerDbm: 18,
          connectedClients: 0,
        ),
        ssids: [],
      ),
      clients: [],
      timestamp: 1690000000,
    );
    controller.setStatusForTesting(status);
  });

  testWidgets('NetworkScreen renders all 6 acceleration and routing cards on 360x780 screen without overflow', (tester) async {
    tester.view.physicalSize = const Size(360, 780);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Title & AppBar
    expect(find.text('Network & Acceleration'), findsOneWidget);
    expect(find.text('WAN Online'), findsOneWidget);

    // Card 1: WAN Internet Gateway
    expect(find.text('WAN Internet Gateway'), findsOneWidget);
    expect(find.text('103.145.12.84'), findsOneWidget);
    expect(find.text('103.145.12.1'), findsOneWidget);

    // Card 2: MediaTek HW NAT Offload
    expect(find.text('MediaTek HW NAT Offload'), findsOneWidget);
    expect(find.textContaining('MT7621 PPE Active'), findsOneWidget);

    // Card 3: CAKE SQM QoS
    expect(find.text('CAKE SQM QoS'), findsOneWidget);
    expect(find.text('95.0 Mbps ↓'), findsOneWidget);
    expect(find.text('20.0 Mbps ↑'), findsOneWidget);

    // Card 4: WireGuard VPN Tunnel
    expect(find.text('WireGuard VPN Tunnel'), findsOneWidget);
    expect(find.text('sg-vpn.cyberguard.net:51820'), findsOneWidget);

    // Card 5: Multi-WAN Failover
    await tester.scrollUntilVisible(find.text('Multi-WAN Failover & Backup'), 200);
    expect(find.text('Multi-WAN Failover & Backup'), findsOneWidget);

    // Card 6: DNS-over-HTTPS (DoH) Privacy
    await tester.scrollUntilVisible(find.text('DNS-over-HTTPS (DoH) Privacy'), 200);
    expect(find.text('DNS-over-HTTPS (DoH) Privacy'), findsOneWidget);
  });

  testWidgets('NetworkScreen renders without error on compact 320x640 screen', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Network & Acceleration'), findsOneWidget);
    expect(find.text('WAN Internet Gateway'), findsOneWidget);
  });

  testWidgets('NetworkScreen renders cleanly on large 412x915 screen', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Network & Acceleration'), findsOneWidget);
  });

  testWidgets('Tapping Public WAN IP copies IP address to clipboard and shows feedback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    final ipFinder = find.text('103.145.12.84');
    expect(ipFinder, findsOneWidget);

    await tester.tap(ipFinder);
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('103.145.12.84'), findsWidgets);
  });

  testWidgets('Tapping SQM configure text opens interactive SQM tuning bottom sheet', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    final tuneTrigger = find.text('Tap to configure bandwidth limits');
    await tester.scrollUntilVisible(tuneTrigger, 200);
    expect(tuneTrigger, findsOneWidget);

    await tester.tap(tuneTrigger);
    await tester.pumpAndSettle();

    expect(find.text('Tune CAKE SQM Bandwidth'), findsOneWidget);
    expect(find.text('CAKE (Modern)'), findsOneWidget);
    expect(find.text('FQ_CoDel'), findsOneWidget);
    expect(find.text('Apply SQM Tuning'), findsOneWidget);
  });

  testWidgets('Tapping DNS Upstream metric tile opens Upstream DNS Resolver modal with presets and live DNS', (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: NetworkScreen(controller: controller),
      ),
    );
    await tester.pumpAndSettle();

    final dnsTileFinder = find.textContaining('DNS •');
    expect(dnsTileFinder, findsOneWidget);

    await tester.tap(dnsTileFinder);
    await tester.pumpAndSettle();

    expect(find.text('Upstream DNS Resolver'), findsOneWidget);
    expect(find.text('ACTIVE ROUTER DNS RESOLVER'), findsOneWidget);
    expect(find.text('PRIMARY DNS'), findsOneWidget);
    expect(find.text('SECONDARY DNS'), findsOneWidget);
    expect(find.text('Configure Upstream DNS (Editable)'), findsOneWidget);
    expect(find.text('Primary DNS Server IPv4'), findsOneWidget);
    expect(find.text('Secondary DNS Server IPv4 (Optional)'), findsOneWidget);
    expect(find.text('Select DNS Provider Preset'), findsOneWidget);
    expect(find.text('Cloudflare DNS'), findsWidgets);
    expect(find.text('AdGuard Ad-Block'), findsOneWidget);

    // Drag the modal list up to reveal remaining presets and apply button
    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Google Public DNS'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Quad9 Security'), findsOneWidget);
    expect(find.textContaining('ISP Automatic'), findsOneWidget);

    await tester.drag(find.byType(ListView).last, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.text('Custom Manual DNS'), findsOneWidget);
    expect(find.text('Apply & Save to Router'), findsOneWidget);
  });
}

