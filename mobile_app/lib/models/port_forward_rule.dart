class PortForwardRule {
  final String id;
  final String name;
  final String proto;
  final String extPort;
  final String intIp;
  final String intPort;
  final bool enabled;

  PortForwardRule({
    required this.id,
    required this.name,
    required this.proto,
    required this.extPort,
    required this.intIp,
    required this.intPort,
    required this.enabled,
  });

  factory PortForwardRule.fromJson(Map<String, dynamic> json) {
    return PortForwardRule(
      id: json['id'] as String? ?? 'pf_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Port Forward',
      proto: (json['proto'] as String? ?? 'tcp').toLowerCase(),
      extPort: (json['extPort'] ?? json['ext_port'] ?? json['src_dport'] ?? '8080').toString(),
      intIp: (json['intIp'] ?? json['int_ip'] ?? json['dest_ip'] ?? '192.168.1.100').toString(),
      intPort: (json['intPort'] ?? json['int_port'] ?? json['dest_port'] ?? '80').toString(),
      enabled: json['enabled'] != false,
    );
  }

  PortForwardRule copyWith({
    String? id,
    String? name,
    String? proto,
    String? extPort,
    String? intIp,
    String? intPort,
    bool? enabled,
  }) {
    return PortForwardRule(
      id: id ?? this.id,
      name: name ?? this.name,
      proto: proto ?? this.proto,
      extPort: extPort ?? this.extPort,
      intIp: intIp ?? this.intIp,
      intPort: intPort ?? this.intPort,
      enabled: enabled ?? this.enabled,
    );
  }
}
