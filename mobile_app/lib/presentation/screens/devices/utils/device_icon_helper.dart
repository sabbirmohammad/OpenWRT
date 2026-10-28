import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';
import '../../../../models/router_status_model.dart';

class DeviceIconHelper {
  DeviceIconHelper._();

  static Color resolveSignalColor(int dbm) {
    if (dbm >= -60) return GlossyColors.emeraldMint;
    if (dbm >= -72) return GlossyColors.lightBlue;
    if (dbm >= -82) return GlossyColors.amberWarm;
    return GlossyColors.roseCoral;
  }

  static IconData resolveDeviceIcon(ClientInfo client) {
    final name = (client.customName?.isNotEmpty == true
            ? client.customName!
            : client.hostname)
        .toLowerCase();
    final vendor = (client.vendor ?? '').toLowerCase();
    final allText = '$name $vendor';

    // 1. Phones & Mobile Devices
    if (allText.contains('iphone') ||
        allText.contains('android') ||
        allText.contains('pixel') ||
        allText.contains('galaxy') ||
        allText.contains('-a34') ||
        allText.contains('-a5') ||
        allText.contains('v2419') ||
        allText.contains('vivo') ||
        allText.contains('oppo') ||
        allText.contains('xiaomi') ||
        allText.contains('redmi') ||
        allText.contains('realme') ||
        allText.contains('oneplus') ||
        allText.contains('poco') ||
        allText.contains('mobile') ||
        allText.contains('phone')) {
      return Icons.phone_android_rounded;
    }

    // 2. Tablets & iPads
    if (allText.contains('ipad') ||
        allText.contains('tablet') ||
        allText.contains('tab') ||
        allText.contains('pad')) {
      return Icons.tablet_mac_rounded;
    }

    // 3. Laptops & MacBooks
    if (allText.contains('macbook') ||
        allText.contains('laptop') ||
        allText.contains('notebook') ||
        allText.contains('thinkpad') ||
        allText.contains('zenbook') ||
        allText.contains('chromebook')) {
      return Icons.laptop_mac_rounded;
    }

    // 4. Desktop PCs & Workstations
    if (allText.contains('desktop') ||
        allText.contains('pc') ||
        allText.contains('imac') ||
        allText.contains('workstation') ||
        allText.contains('windows') ||
        allText.contains('linux')) {
      return Icons.desktop_windows_rounded;
    }

    // 5. Smart TVs & Streaming Devices
    if (allText.contains('tv') ||
        allText.contains('cast') ||
        allText.contains('chromecast') ||
        allText.contains('firestick') ||
        allText.contains('fire tv') ||
        allText.contains('roku') ||
        allText.contains('bravia') ||
        allText.contains('webos') ||
        allText.contains('sony') ||
        allText.contains('shield')) {
      return Icons.tv_rounded;
    }

    // 6. Smart Home, IoT & Raspberry Pi
    if (allText.contains('raspberry') ||
        allText.contains('pi') ||
        allText.contains('homeassistant') ||
        allText.contains('esp') ||
        allText.contains('arduino') ||
        allText.contains('sensor') ||
        allText.contains('smart') ||
        allText.contains('alexa') ||
        allText.contains('echo') ||
        allText.contains('nest')) {
      return Icons.memory_rounded;
    }

    // 7. Security Cameras
    if (allText.contains('cam') ||
        allText.contains('camera') ||
        allText.contains('cctv')) {
      return Icons.videocam_rounded;
    }

    // 8. Gaming Consoles
    if (allText.contains('playstation') ||
        allText.contains('ps4') ||
        allText.contains('ps5') ||
        allText.contains('xbox') ||
        allText.contains('nintendo') ||
        allText.contains('switch')) {
      return Icons.sports_esports_rounded;
    }

    // 9. Physical Media fallback
    if (client.connectionType.contains('LAN')) {
      return Icons.lan_outlined;
    }
    if (client.connectionType.contains('5GHz')) {
      return Icons.wifi_sharp;
    }
    if (client.connectionType.contains('2.4GHz')) {
      return Icons.wifi_2_bar_sharp;
    }

    return Icons.devices_rounded;
  }
}
