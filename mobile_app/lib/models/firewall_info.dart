import 'model_helpers.dart';
import 'port_forward_rule.dart';
import 'traffic_rule.dart';

class FirewallInfo {
  final String engine;
  final String table;
  final String status;
  final bool synFlood;
  final bool dropInvalid;
  final bool wanPing;
  final bool wanLockdown;
  final bool dnsRebind;
  final bool flowOffload;
  final bool flowOffloadHw;
  final bool mssClamping;
  final bool antiSpoofing;
  final bool ipv6Firewall;
  final bool stealthMode;
  final bool guestIsolation;
  final bool dmzEnabled;
  final String dmzIp;
  final int conntrackCount;
  final int conntrackMax;
  final List<PortForwardRule> portForwards;
  final List<TrafficRule> trafficRules;

  FirewallInfo({
    this.engine = 'nftables v1.0.8 (fw4)',
    this.table = 'table inet fw4',
    this.status = 'enforcing',
    this.synFlood = true,
    this.dropInvalid = true,
    this.wanPing = false,
    this.wanLockdown = true,
    this.dnsRebind = true,
    this.flowOffload = true,
    this.flowOffloadHw = true,
    this.mssClamping = true,
    this.antiSpoofing = true,
    this.ipv6Firewall = true,
    this.stealthMode = true,
    this.guestIsolation = true,
    this.dmzEnabled = false,
    this.dmzIp = '192.168.1.150',
    this.conntrackCount = 342,
    this.conntrackMax = 16384,
    List<PortForwardRule>? portForwards,
    List<TrafficRule>? trafficRules,
  })  : portForwards = portForwards ?? _defaultPortForwards(),
        trafficRules = trafficRules ?? _defaultTrafficRules();

  factory FirewallInfo.defaultConfig() => FirewallInfo();

  static List<PortForwardRule> _defaultPortForwards() => [
        PortForwardRule(id: 'pf_web', name: 'HTTP Web Server', proto: 'tcp', extPort: '8080', intIp: '192.168.1.101', intPort: '80', enabled: true),
        PortForwardRule(id: 'pf_ssh', name: 'SSH Remote Admin', proto: 'tcp', extPort: '2222', intIp: '192.168.1.120', intPort: '22', enabled: false),
        PortForwardRule(id: 'pf_wg', name: 'WireGuard VPN Tunnel', proto: 'udp', extPort: '51820', intIp: '192.168.1.1', intPort: '51820', enabled: true),
        PortForwardRule(id: 'pf_plex', name: 'Plex Media Server', proto: 'tcp', extPort: '32400', intIp: '192.168.1.120', intPort: '32400', enabled: true),
        PortForwardRule(id: 'pf_mc', name: 'Minecraft Game Server', proto: 'tcp+udp', extPort: '25565', intIp: '192.168.1.105', intPort: '25565', enabled: false),
      ];

  static List<TrafficRule> _defaultTrafficRules() => [
        TrafficRule(id: 'tr_ping', name: 'Allow Ping from LAN to Router', proto: 'icmp', src: 'lan', dest: 'router', target: 'ACCEPT', enabled: true),
        TrafficRule(id: 'tr_dns', name: 'Force Router DNS (Port 53 Intercept)', proto: 'udp', src: 'lan', dest: 'router', target: 'ACCEPT', enabled: true),
        TrafficRule(id: 'tr_doh', name: 'Block Plain HTTP DoH Bypass', proto: 'tcp', src: 'lan', dest: 'wan', target: 'REJECT', enabled: false),
        TrafficRule(id: 'tr_guest', name: 'Block Guest Access to Router Admin', proto: 'all', src: 'guest', dest: 'router', target: 'DROP', enabled: true),
      ];

  factory FirewallInfo.fromJson(Map<String, dynamic> json) {
    if (json.isEmpty) return FirewallInfo.defaultConfig();

    final rawPfs = json['port_forwards'] as List<dynamic>?;
    final pfs = rawPfs?.whereType<Map<String, dynamic>>().map((p) => PortForwardRule.fromJson(p)).toList();

    final rawTrs = json['traffic_rules'] as List<dynamic>?;
    final trs = rawTrs?.whereType<Map<String, dynamic>>().map((t) => TrafficRule.fromJson(t)).toList();

    return FirewallInfo(
      engine: json['engine'] as String? ?? 'nftables v1.0.8 (fw4)',
      table: json['table'] as String? ?? 'table inet fw4',
      status: json['status'] as String? ?? 'enforcing',
      synFlood: json['syn_flood'] != false,
      dropInvalid: json['drop_invalid'] != false,
      wanPing: json['wan_ping'] == true,
      wanLockdown: (json['wan_lockdown'] ?? json['wan_block']) != false,
      dnsRebind: (json['dns_rebind'] ?? json['rebind_protection']) != false,
      flowOffload: json['flow_offload'] != false,
      flowOffloadHw: json['flow_offload_hw'] != false,
      mssClamping: json['mss_clamping'] != false,
      antiSpoofing: json['anti_spoofing'] != false,
      ipv6Firewall: json['ipv6_firewall'] != false,
      stealthMode: json['stealth_mode'] != false,
      guestIsolation: json['guest_isolation'] != false,
      dmzEnabled: json['dmz_enabled'] == true,
      dmzIp: json['dmz_ip'] as String? ?? '192.168.1.150',
      conntrackCount: ModelHelpers.toInt(json['conntrack_count'], 342),
      conntrackMax: ModelHelpers.toInt(json['conntrack_max'], 16384),
      portForwards: pfs,
      trafficRules: trs,
    );
  }

  FirewallInfo copyWith({
    String? engine,
    String? table,
    String? status,
    bool? synFlood,
    bool? dropInvalid,
    bool? wanPing,
    bool? wanLockdown,
    bool? dnsRebind,
    bool? flowOffload,
    bool? flowOffloadHw,
    bool? mssClamping,
    bool? antiSpoofing,
    bool? ipv6Firewall,
    bool? stealthMode,
    bool? guestIsolation,
    bool? dmzEnabled,
    String? dmzIp,
    int? conntrackCount,
    int? conntrackMax,
    List<PortForwardRule>? portForwards,
    List<TrafficRule>? trafficRules,
  }) {
    return FirewallInfo(
      engine: engine ?? this.engine,
      table: table ?? this.table,
      status: status ?? this.status,
      synFlood: synFlood ?? this.synFlood,
      dropInvalid: dropInvalid ?? this.dropInvalid,
      wanPing: wanPing ?? this.wanPing,
      wanLockdown: wanLockdown ?? this.wanLockdown,
      dnsRebind: dnsRebind ?? this.dnsRebind,
      flowOffload: flowOffload ?? this.flowOffload,
      flowOffloadHw: flowOffloadHw ?? this.flowOffloadHw,
      mssClamping: mssClamping ?? this.mssClamping,
      antiSpoofing: antiSpoofing ?? this.antiSpoofing,
      ipv6Firewall: ipv6Firewall ?? this.ipv6Firewall,
      stealthMode: stealthMode ?? this.stealthMode,
      guestIsolation: guestIsolation ?? this.guestIsolation,
      dmzEnabled: dmzEnabled ?? this.dmzEnabled,
      dmzIp: dmzIp ?? this.dmzIp,
      conntrackCount: conntrackCount ?? this.conntrackCount,
      conntrackMax: conntrackMax ?? this.conntrackMax,
      portForwards: portForwards ?? this.portForwards,
      trafficRules: trafficRules ?? this.trafficRules,
    );
  }

  int get activeDefensesCount {
    int count = 0;
    if (synFlood) count++;
    if (dropInvalid) count++;
    if (!wanPing) count++;
    if (wanLockdown) count++;
    if (dnsRebind) count++;
    if (mssClamping) count++;
    if (antiSpoofing) count++;
    if (ipv6Firewall) count++;
    if (stealthMode) count++;
    if (guestIsolation) count++;
    return count;
  }

  int get totalDefensesCount => 10;
  int get activePortForwardsCount => portForwards.where((p) => p.enabled).length;
  int get activeTrafficRulesCount => trafficRules.where((t) => t.enabled).length;
  double get conntrackPercent => (conntrackCount / (conntrackMax > 0 ? conntrackMax : 16384) * 100).clamp(0, 100).toDouble();
}
