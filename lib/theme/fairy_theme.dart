import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:serenity_diary/providers/preferences_provider.dart';

class FairyTheme {
  FairyTheme._();

  static ThemeType currentTheme = ThemeType.fairyDay;

  // ── Backgrounds ─────────────────────────────────────
  static Color get bgSage {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF1B1A30);
      case ThemeType.autumnMagic: return const Color(0xFF8B5A2B);
      default: return const Color(0xFF7B8F68);
    }
  }
  static Color get bgSageDark {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF121124);
      case ThemeType.autumnMagic: return const Color(0xFF5E3A1A);
      default: return const Color(0xFF5E6F4E);
    }
  }
  static Color get bgSageLight {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF2C2A4A);
      case ThemeType.autumnMagic: return const Color(0xFFB07D4C);
      default: return const Color(0xFF96AA81);
    }
  }

  // ── Card surfaces ────────────────────────────────────
  static Color get cardSurface {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF28283E); // Dark surface
      case ThemeType.autumnMagic: return const Color(0xFFF5ECD8); // Warm cream
      default: return const Color(0xFFF5EDD8); // Default cream
    }
  }

  static Color get cream {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFFE8E8F0); // Light for text visibility
      case ThemeType.autumnMagic: return const Color(0xFFF5ECD8); 
      default: return const Color(0xFFF5EDD8);
    }
  }
  static Color get parchment {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF32324C);
      case ThemeType.autumnMagic: return const Color(0xFFE8D0AA);
      default: return const Color(0xFFEAD9B0);
    }
  }
  static Color get parchmentDark {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF40405A);
      case ThemeType.autumnMagic: return const Color(0xFFD4B482);
      default: return const Color(0xFFD6C08A);
    }
  }

  // ── Accent palette ───────────────────────────────────
  static Color get lavender {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF7A68A6);
      case ThemeType.autumnMagic: return const Color(0xFFC48671); // Terracotta
      default: return const Color(0xFFC9B8D8);
    }
  }
  static Color get lavenderDark {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF594882);
      case ThemeType.autumnMagic: return const Color(0xFF965B4A);
      default: return const Color(0xFF9B87B8);
    }
  }
  static Color get dustyRose {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF5C4B5E); // Dusty purple
      case ThemeType.autumnMagic: return const Color(0xFFCC855E); // Pumpkin
      default: return const Color(0xFFE8C5C5);
    }
  }
  static Color get mint {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF509088);
      case ThemeType.autumnMagic: return const Color(0xFF8B8C65); // Olive
      default: return const Color(0xFFADD8C7);
    }
  }
  static Color get mintLight {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF386862);
      case ThemeType.autumnMagic: return const Color(0xFFB0B088);
      default: return const Color(0xFFD0EDE5);
    }
  }
  static Color get gold {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFFC0A8C0); // Silver/Moonlight
      case ThemeType.autumnMagic: return const Color(0xFFD4A017); // Rich gold
      default: return const Color(0xFFD4A853);
    }
  }
  static Color get goldDark {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF8B7A8B);
      case ThemeType.autumnMagic: return const Color(0xFF996B00);
      default: return const Color(0xFFB88A3A);
    }
  }

  // ── Text ─────────────────────────────────────────────
  static Color get inkBrown {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFFE8E8F0); // Off-white
      case ThemeType.autumnMagic: return const Color(0xFF4A1A1A); // Dark maroon
      default: return const Color(0xFF4A3020);
    }
  }
  static Color get medBrown {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFFB0B0C4); // Light greyish blue
      case ThemeType.autumnMagic: return const Color(0xFF7A3A20);
      default: return const Color(0xFF7A5430);
    }
  }
  static Color get lightBrown {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF7A7A90);
      case ThemeType.autumnMagic: return const Color(0xFFA05A30);
      default: return const Color(0xFFA07850);
    }
  }
  static Color get sageText {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF90A0B0);
      case ThemeType.autumnMagic: return const Color(0xFF5A4A30);
      default: return const Color(0xFF3D4F2C);
    }
  }

  // ── Decorative ───────────────────────────────────────
  static Color get leafGreen {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFF4B6B8A); // Moonlight blue
      case ThemeType.autumnMagic: return const Color(0xFFA53A2C); // Crimson leaf
      default: return const Color(0xFF6B8B5E);
    }
  }
  static Color get berryPink {
    switch (currentTheme) {
      case ThemeType.nightForest: return const Color(0xFFA06B9A);
      case ThemeType.autumnMagic: return const Color(0xFF7A2215); // Dark Rust (high contrast on pumpkin)
      default: return const Color(0xFFD4829A);
    }
  }

  // ── Text Styles ──────────────────────────────────────
  static TextStyle titleScript({double size = 32, Color? color}) =>
      GoogleFonts.dancingScript(
        fontSize: size,
        fontWeight: FontWeight.bold,
        color: color ?? inkBrown,
      );

  static TextStyle serifHeader({double size = 18, Color? color}) =>
      GoogleFonts.playfairDisplay(
        fontSize: size,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
        color: color ?? inkBrown,
      );

  static TextStyle softBody({double size = 14, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        color: color ?? inkBrown,
      );

  static TextStyle softBold({double size = 14, Color? color}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: FontWeight.w700,
        color: color ?? inkBrown,
      );

  // ── Shared Decorations ───────────────────────────────
  static BoxDecoration parchmentCard({
    double radius = 20,
    Color? color,
    Color? borderColor,
    List<BoxShadow>? shadows,
  }) =>
      BoxDecoration(
        color: color ?? cardSurface,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? gold.withOpacity(0.45),
          width: 1.5,
        ),
        boxShadow: shadows ??
            [
              BoxShadow(
                color: inkBrown.withOpacity(0.13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
      );
}
