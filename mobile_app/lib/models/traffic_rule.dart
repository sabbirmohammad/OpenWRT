class TrafficRule {
  final String id;
  final String name;
  final String proto;
  final String src;
  final String dest;
  final String target;
  final bool enabled;

  TrafficRule({
    required this.id,
    required this.name,
    required this.proto,
    required this.src,
    required this.dest,
    required this.target,
    required this.enabled,
  });

  factory TrafficRule.fromJson(Map<String, dynamic> json) {
    return TrafficRule(
      id: json['id'] as String? ?? 'tr_${DateTime.now().millisecondsSinceEpoch}',
      name: json['name'] as String? ?? 'Traffic Filter',
      proto: (json['proto'] as String? ?? 'tcp').toLowerCase(),
      src: (json['src'] as String? ?? 'lan').toLowerCase(),
      dest: (json['dest'] as String? ?? 'wan').toLowerCase(),
      target: (json['target'] as String? ?? 'DROP').toUpperCase(),
      enabled: json['enabled'] != false,
    );
  }

  TrafficRule copyWith({
    String? id,
    String? name,
    String? proto,
    String? src,
    String? dest,
    String? target,
    bool? enabled,
  }) {
    return TrafficRule(
      id: id ?? this.id,
      name: name ?? this.name,
      proto: proto ?? this.proto,
      src: src ?? this.src,
      dest: dest ?? this.dest,
      target: target ?? this.target,
      enabled: enabled ?? this.enabled,
    );
  }
}
