import 'package:flutter/material.dart';
import '../../../../core/theme/glossy_colors.dart';

class DnsPreset {
  final String id;
  final String name;
  final String primary;
  final String secondary;
  final String desc;
  final IconData icon;
  final Color color;

  const DnsPreset({
    required this.id,
    required this.name,
    required this.primary,
    required this.secondary,
    required this.desc,
    required this.icon,
    required this.color,
  });

  static const List<DnsPreset> presets = [
    DnsPreset(
      id: 'cloudflare',
      name: 'Cloudflare DNS',
      primary: '1.1.1.1',
      secondary: '1.0.0.1',
      desc: 'Ultra-fast response time, zero-logging privacy',
      icon: Icons.bolt_rounded,
      color: GlossyColors.amberWarm,
    ),
    DnsPreset(
      id: 'adguard',
      name: 'AdGuard Ad-Block',
      primary: '94.140.14.14',
      secondary: '94.140.15.15',
      desc: 'Blocks ads, trackers & phishing router-wide',
      icon: Icons.shield_rounded,
      color: GlossyColors.emeraldMint,
    ),
    DnsPreset(
      id: 'google',
      name: 'Google Public DNS',
      primary: '8.8.8.8',
      secondary: '8.8.4.4',
      desc: 'High reliability, worldwide Anycast routing',
      icon: Icons.public,
      color: GlossyColors.lightBlue,
    ),
    DnsPreset(
      id: 'quad9',
      name: 'Quad9 Security',
      primary: '9.9.9.9',
      secondary: '149.112.112.112',
      desc: 'Blocks malware, spyware & infected hosts',
      icon: Icons.security_rounded,
      color: GlossyColors.roseCoral,
    ),
    DnsPreset(
      id: 'auto',
      name: 'ISP Automatic (DHCP / PPPoE)',
      primary: 'auto',
      secondary: '',
      desc: 'Dynamic DNS assigned by your ISP gateway',
      icon: Icons.sync_rounded,
      color: GlossyColors.textSecondary,
    ),
    DnsPreset(
      id: 'custom',
      name: 'Custom Manual DNS',
      primary: '',
      secondary: '',
      desc: 'Specify your own custom IPv4 DNS servers',
      icon: Icons.edit_note_rounded,
      color: GlossyColors.primaryBlue,
    ),
  ];
}
