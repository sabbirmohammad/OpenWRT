import 'package:flutter/material.dart';
import '../../../../models/router_status_model.dart';
import '../../../controllers/router_controller.dart';
import '../sheets/add_ssid_sheet.dart';
import '../sheets/connected_devices_sheet.dart';
import '../sheets/edit_ssid_sheet.dart';
import '../sheets/protocols_detail_sheet.dart';
import '../sheets/share_ssid_sheet.dart';
import '../sheets/ssid_detail_sheet.dart';

class WirelessSheetHelper {
  WirelessSheetHelper._();

  static void showAddSsidModal(BuildContext context, RouterController controller) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddSsidSheet(controller: controller),
    );
  }

  static void showEditSsidModal(BuildContext context, RouterController controller, SsidInfo ssid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EditSsidSheet(controller: controller, ssid: ssid),
    );
  }

  static void showShareSsidModal(BuildContext context, SsidInfo ssid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareSsidSheet(ssid: ssid),
    );
  }

  static void showConnectedDevicesModal(
    BuildContext context,
    SsidInfo ssid,
    List<ClientInfo> allClients,
  ) {
    final clients = allClients.where((c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase()).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConnectedDevicesSheet(ssid: ssid, clients: clients),
    );
  }

  static void showSsidDetailModal(
    BuildContext context,
    RouterController controller,
    SsidInfo ssid,
    List<ClientInfo> allClients,
    List<SsidInfo> allSsids,
  ) {
    final clients = allClients.where((c) => c.ssidName.toLowerCase() == ssid.ssid.toLowerCase()).toList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SsidDetailSheet(
        ssid: ssid,
        clients: clients,
        allSsids: allSsids,
        onEdit: () {
          Navigator.pop(context);
          showEditSsidModal(context, controller, ssid);
        },
        onShare: () {
          Navigator.pop(context);
          showShareSsidModal(context, ssid);
        },
      ),
    );
  }

  static void showProtocolsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ProtocolsDetailSheet(),
    );
  }
}
