import 'package:flutter/material.dart';
import '../../../../core/utils/app_feedback.dart';
import '../../../../core/utils/input_validators.dart';
import '../../../controllers/router_controller.dart';

class SecurityActionHandler {
  static Future<void> togglePmf(BuildContext context, RouterController controller) async {
    final current = controller.status?.wireless.pmfProtected ?? true;
    try {
      await controller.togglePmf(!current);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          !current
              ? '802.11w PMF Shield Enabled: Deauth attacks & rogue frame injection blocked.'
              : '802.11w PMF Shield Disabled.',
        );
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'PMF toggle failed: $e');
    }
  }

  static Future<void> toggleDnsRebind(BuildContext context, RouterController controller) async {
    final current = controller.status?.network.dnsRebindProtection ?? true;
    try {
      await controller.toggleDnsRebind(!current);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          !current
              ? 'DNS Rebind Shield Enabled: RFC 1918 resolution blocked at dnsmasq.'
              : 'DNS Rebind Protection Disabled.',
        );
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'DNS Rebind toggle failed: $e');
    }
  }

  static Future<void> toggleWanLockdown(BuildContext context, RouterController controller) async {
    final current = controller.status?.network.wanLockdown ?? true;
    try {
      await controller.toggleWanLockdown(!current);
      if (context.mounted) {
        AppFeedback.showSuccess(
          context,
          !current
              ? 'Remote WAN Management Locked: Port 80/443/22 closed to external WAN.'
              : 'Remote WAN Management Lockdown Disabled.',
        );
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'WAN lockdown toggle failed: $e');
    }
  }

  static Future<void> toggleStealth(BuildContext context, RouterController controller) async {
    final current = controller.status?.stealthLeds ?? false;
    try {
      await controller.executeAction('led_stealth', {'value': !current ? 'on' : 'off', 'enabled': !current});
      if (context.mounted) {
        AppFeedback.showInfo(context, !current ? 'Stealth Mode ON: All LEDs off.' : 'Stealth Mode OFF: Normal LEDs active.');
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'Stealth toggle failed: $e');
    }
  }

  static Future<void> toggleWireguard(BuildContext context, RouterController controller, bool enable) async {
    try {
      await controller.toggleWireguard(enable);
      if (context.mounted) {
        AppFeedback.showSuccess(context, enable ? 'WireGuard VPN Tunnel Connected.' : 'WireGuard VPN Disconnected.');
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'WireGuard action failed: $e');
    }
  }

  static Future<void> toggleDoh(BuildContext context, RouterController controller, bool enable) async {
    try {
      await controller.toggleDoh(enable);
      if (context.mounted) {
        AppFeedback.showSuccess(context, enable ? 'DNS-over-HTTPS (DoH) Enabled.' : 'DNS-over-HTTPS Disabled.');
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'DoH toggle failed: $e');
    }
  }

  static Future<bool> blockCustomMac(BuildContext context, RouterController controller, String rawMac) async {
    final mac = rawMac.trim().toLowerCase();
    if (!InputValidators.isValidMac(mac)) {
      AppFeedback.showError(context, 'Invalid MAC address. Format: AA:BB:CC:DD:EE:FF');
      return false;
    }
    try {
      await controller.blockClient(mac);
      if (context.mounted) AppFeedback.showError(context, 'Client $mac blocked at firewall!');
      return true;
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'Failed to block client: $e');
      return false;
    }
  }

  static Future<void> unblockClient(BuildContext context, RouterController controller, String mac) async {
    try {
      await controller.unblockClient(mac);
      if (context.mounted) AppFeedback.showSuccess(context, 'Client $mac unblocked successfully.');
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'Failed to unblock client: $e');
    }
  }

  static Future<void> kickClient(BuildContext context, RouterController controller, String mac, String hostname) async {
    try {
      await controller.kickClient(mac);
      if (context.mounted) AppFeedback.showWarning(context, 'Kicked $hostname ($mac) from Wi-Fi via 802.11 deauth.');
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'Failed to kick client: $e');
    }
  }

  static Future<void> autoHardenAll(BuildContext context, RouterController controller) async {
    try {
      await controller.autoHardenSecurity();
      if (context.mounted) {
        Navigator.of(context).pop();
        AppFeedback.showSuccess(context, 'Auto-Hardening Complete! PMF 802.11w, DNS Rebind, and WAN Lock active.');
      }
    } catch (e) {
      if (context.mounted) AppFeedback.showError(context, 'Auto-hardening failed: $e');
    }
  }
}
