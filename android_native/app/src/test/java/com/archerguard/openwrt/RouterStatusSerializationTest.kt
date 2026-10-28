package com.archerguard.openwrt

import com.archerguard.openwrt.domain.model.RouterStatus
import kotlinx.serialization.json.Json
import org.junit.Test
import org.junit.Assert.*

class RouterStatusSerializationTest {
    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
        isLenient = true
    }

    @Test
    fun testDeserializeFullJson() {
        val fullJson = """
        {
          "cpu": {
            "cores": 2,
            "threads": 4,
            "model": "MediaTek MT7621DAT @ 880MHz",
            "architecture": "MIPS 1004Kc V2.15",
            "frequency_mhz": 880,
            "usage_percent": 18,
            "temperature_c": 42,
            "load_avg": "0.10, 0.15, 0.12",
            "uptime_seconds": 120
          },
          "memory": {
            "total_kb": 131072,
            "used_kb": 51200,
            "free_kb": 40960,
            "buffers_kb": 8192,
            "cached_kb": 30720,
            "available_kb": 79872,
            "type": "DDR3 1200MHz",
            "usage_percent": 39
          },
          "storage": {
            "total_kb": 239362496,
            "used_kb": 13336868,
            "available_kb": 30538492,
            "device": "16MB SPI NOR Flash",
            "usage_percent": 5
          },
          "traffic": {
            "interface": "eth0",
            "rx_bytes": 1000,
            "tx_bytes": 2000,
            "wan_ip": "10.0.0.1",
            "timestamp": 1793200555
          },
          "network": {
            "hw_offload": {"enabled": true, "flow_offloading_hw": true},
            "sqm": {"enabled": true, "qdisc": "cake", "download_kbit": 95000, "upload_kbit": 20000},
            "wireguard": {"enabled": false, "interface": "wg0", "endpoint": "10.14.0.1:51820", "status": "standby"},
            "multi_wan": {"enabled": false, "mode": "failover", "wan1": "online", "wan2": "standby"},
            "doh": {"enabled": false, "provider": "Cloudflare (1.1.1.1)"},
            "wan_details": {"gateway": "", "dns": "192.168.1.1", "mtu": 1492, "protocol": "PPPoE", "latency_ms": 8.5, "jitter_ms": 0.9}
          },
          "wireless": {
            "radio_2g": {"ifname":"phy0-ap0","band":"2.4GHz","chipset":"MT7603E","enabled":true,"ssid":"ArcherC6_2.4G","channel":6,"txpower_dbm":22,"connected_clients":2},
            "radio_5g": {"ifname":"phy1-ap0","band":"5GHz","chipset":"MT7613BEN","enabled":true,"ssid":"ArcherC6_5G","channel":36,"txpower_dbm":23,"connected_clients":3},
            "guest": {"enabled":false,"ssid":"ArcherC6_Guest","channel":6,"txpower_dbm":18,"isolated":true,"connected_clients":0},
            "advanced": {"fast_roaming":true,"pmf_protected":true,"wmm_qos":true,"drop_legacy_rates":true},
            "ssids": [
              {"id":"default_radio0","ssid":"Archer_C6_2.4G","band":"2.4GHz","radio":"radio0","ifname":"phy0-ap0","enabled":true,"encryption":"WPA2-PSK","channel":6,"connected_clients":2,"is_guest":false},
              {"id":"guest","ssid":"ArcherC6_Guest","band":"2.4GHz","radio":"radio0","ifname":"phy0-ap1","enabled":false,"encryption":"WPA2-PSK","channel":6,"connected_clients":0,"is_guest":true,"isolated":true}
            ]
          },
          "clients": [
            {
              "mac": "aa:bb:cc:dd:ee:ff",
              "ip": "192.168.1.105",
              "hostname": "Pixel-Phone",
              "connection_type": "5GHz",
              "ssid_name": "ArcherC6_5G",
              "signal_dbm": -52,
              "rx_bytes": 1048576,
              "tx_bytes": 2097152,
              "connected_seconds": 1800,
              "blocked": false,
              "nds_authenticated": true
            }
          ],
          "timestamp": 1793200555
        }
        """.trimIndent()

        val status = json.decodeFromString<RouterStatus>(fullJson)
        assertNotNull(status)
        assertEquals(18.0, status.cpu.usagePercent, 0.01)
        assertEquals(39.0, status.memory.usagePercent, 0.01)
        assertEquals(5.0, status.storage.usagePercent, 0.01)
        assertEquals(1, status.clients.size)
        assertEquals("Pixel-Phone", status.clients[0].hostname)
        assertEquals(2, status.wireless.radio2g.connectedClients)
        assertEquals(3, status.wireless.radio5g.connectedClients)
    }
}
