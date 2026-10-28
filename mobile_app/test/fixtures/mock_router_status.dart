import 'package:mobile_app/models/router_status_model.dart';

class MockRouterFixtures {
  static Map<String, dynamic> sampleRouterJson({
    bool stealthMode = false,
    bool wireguardEnabled = false,
    bool dohEnabled = true,
  }) {
    return {
      "cpu": {
        "cores": 2,
        "threads": 4,
        "model": "MediaTek MT7621DAT @ 880MHz",
        "architecture": "MIPS 1004Kc V2.15",
        "frequency_mhz": 880,
        "usage_percent": 22.0,
        "temperature_c": 44.0,
        "load_avg": "0.45, 0.50, 0.40",
        "uptime_seconds": 12500,
      },
      "memory": {
        "total_kb": 131072,
        "used_kb": 54200,
        "free_kb": 42000,
        "cached_kb": 24000,
        "available_kb": 66000,
        "type": "DDR3 1200MHz",
        "usage_percent": 41.0,
      },
      "storage": {
        "total_kb": 16384,
        "used_kb": 10240,
        "available_kb": 6144,
        "device": "16MB SPI NOR Flash",
        "usage_percent": 62.0,
      },
      "traffic": {
        "interface": "wan",
        "rx_bytes": 125000000,
        "tx_bytes": 35000000,
        "wan_ip": "103.145.12.84",
        "current_download_mbps": 48.5,
        "current_upload_mbps": 14.2,
        "ping_ms": 11,
      },
      "network": {
        "hw_offload": {"enabled": true},
        "sqm": {"enabled": true},
        "wan_details": {
          "gateway": "103.145.12.1",
          "protocol": "PPPoE (Fiber Optic ONU)",
        },
        "wireguard": {"enabled": wireguardEnabled},
        "doh": {"enabled": dohEnabled},
        "dns_rebind_protection": true,
        "wan_lockdown": true,
      },
      "wireless": {
        "radio_2g": {
          "enabled": true,
          "ssid": "Archer_C6_2.4G",
          "channel": 6,
          "connected_clients": 2,
        },
        "radio_5g": {
          "enabled": true,
          "ssid": "Archer_C6_5G",
          "channel": 149,
          "connected_clients": 3,
        },
        "guest": {
          "enabled": true,
          "ssid": "ArcherC6_Guest",
          "channel": 6,
          "connected_clients": 1,
        },
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
          "nds_authenticated": true,
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
          "nds_authenticated": false,
        },
      ],
      "leds": {"stealth_mode": stealthMode},
      "firewall": {
        "engine": "nftables v1.0.8 (fw4)",
        "table": "table inet fw4",
        "status": "enforcing",
        "syn_flood": true,
        "drop_invalid": true,
        "wan_ping": false,
        "wan_lockdown": true,
        "mss_clamping": true,
        "anti_spoofing": true,
        "ipv6_firewall": true,
        "guest_isolation": true,
        "stealth_mode": stealthMode,
        "flow_offload": "Hardware Acceleration (MTK PPE)",
        "dmz_enabled": false,
        "dmz_ip": "192.168.1.150",
        "zones": [
          {"name": "lan", "forward": "ACCEPT", "input": "ACCEPT", "iface": "br-lan"},
          {"name": "wan", "forward": "REJECT", "input": "REJECT", "iface": "eth0.2"},
        ],
        "port_forwards": [
          {
            "id": "pf1",
            "name": "Plex Server",
            "src_port": "32400",
            "dest_ip": "192.168.1.100",
            "dest_port": "32400",
            "proto": "tcp",
            "enabled": true,
          },
        ],
        "traffic_rules": [
          {
            "id": "tr1",
            "name": "Block IoT External",
            "src": "lan",
            "dest": "wan",
            "target": "REJECT",
            "proto": "any",
            "enabled": true,
          },
        ],
      },
      "timestamp": 1729000000,
    };
  }

  static RouterStatusModel mockRouterStatus({
    bool stealthMode = false,
    bool wireguardEnabled = false,
    bool dohEnabled = true,
  }) {
    return RouterStatusModel.fromJson(
      sampleRouterJson(
        stealthMode: stealthMode,
        wireguardEnabled: wireguardEnabled,
        dohEnabled: dohEnabled,
      ),
    );
  }
}
