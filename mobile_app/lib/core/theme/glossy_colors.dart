import 'package:flutter/material.dart';

/// Design tokens for the Modern Glossy design system.
/// Emphasizes frosted acrylic glass, soft specular rim lighting, deep midnight canvas,
/// and executive blue/emerald accents. Strictly non-sci-fi.
class GlossyColors {
  // Canvas & Backgrounds
  static const Color backgroundPrimary = Color(0xFF0B0F17); // Deep Obsidian Slate
  static const Color backgroundSecondary = Color(0xFF111726); // Midnight Slate
  static const Color backgroundElevated = Color(0xFF182032); // Slightly elevated sheet

  // Frosted Glass Surfaces (Translucent with light refraction)
  static const Color glassSurface = Color(0x12FFFFFF); // ~7% white opacity
  static const Color glassSurfaceHover = Color(0x1AFFFFFF); // ~10% white opacity
  static const Color glassSurfaceActive = Color(0x24FFFFFF); // ~14% white opacity

  // Specular Border & Light Reflection Rims
  static const Color glassBorderLight = Color(0x33FFFFFF); // Top-left specular rim (~20%)
  static const Color glassBorderDark = Color(0x0AFFFFFF); // Bottom-right shadow rim (~4%)
  static const Color glassDivider = Color(0x14FFFFFF);

  // Modern Executive Accents (Clean & Polished, not Neon)
  static const Color primaryBlue = Color(0xFF2563EB); // Royal Blue
  static const Color lightBlue = Color(0xFF3B82F6); // Azure Light
  static const Color skyBlue = Color(0xFF60A5FA); // Sky Highlight

  static const Color emeraldMint = Color(0xFF10B981); // Positive / Connected
  static const Color emeraldSoft = Color(0xFF34D399);

  static const Color amberWarm = Color(0xFFF59E0B); // Moderate load / Warning
  static const Color roseCoral = Color(0xFFEF4444); // High load / Error / Disconnected

  // Isolated SSID & Guest Network Accents (Executive Amethyst Purple)
  static const Color isolatedAccent = Color(0xFFA855F7); // Amethyst Purple
  static const Color isolatedLight = Color(0xFFC084FC); // Bright Violet
  static const Color isolatedGlow = Color(0x33A855F7); // 20% specular glow

  // Typography
  static const Color textPrimary = Color(0xFFF8FAFC); // Polar White
  static const Color textSecondary = Color(0xFF94A3B8); // Slate Neutral
  static const Color textMuted = Color(0xFF64748B); // Dark Slate

  // Modern Gradients
  static const LinearGradient glassBorderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x40FFFFFF), // 25% specular highlight at top-left
      Color(0x12FFFFFF),
      Color(0x05FFFFFF), // Soft fade at bottom-right
    ],
  );

  static const LinearGradient cardGlossGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x14FFFFFF),
      Color(0x08FFFFFF),
    ],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6),
      Color(0xFF1D4ED8),
    ],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981),
      Color(0xFF059669),
    ],
  );
}
