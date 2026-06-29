import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens ported from the original Schumann Resonance app.
class KpColors {
  static const quiet = Color(0xFF10B981); // Sakin
  static const unsettled = Color(0xFFF59E0B); // Kararsız
  static const active = Color(0xFFF97316); // Aktif
  static const storm = Color(0xFFEF4444); // Fırtına
  static const portal = Color(0xFF00E5FF); // Portal
  static const extreme = Color(0xFFFFFFFF); // Ekstrem
}

class AppColors {
  static const primaryGold = Color(0xFFD4AF37);
  static const bgDark = Color(0xFF05050A);
  static const bgSpace = Color(0xFF030308);
  static const bgCard = Color(0x8C12121C); // rgba(18,18,28,0.55)
  static const borderLight = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const borderGold = Color(0x33D4AF37); // rgba(212,175,55,0.2)
  static const textMain = Color(0xFFFFFFFF);
  static const textMuted = Color(0xFF8E8EA8);
}

/// Outfit sans + JetBrains Mono via google_fonts.
class AppText {
  static TextStyle sans({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textMain,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.outfit(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle mono({
    double size = 12,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.textMain,
    double? letterSpacing,
  }) =>
      GoogleFonts.jetBrainsMono(
        fontSize: size,
        fontWeight: weight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
