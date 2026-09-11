import 'package:flutter/cupertino.dart';

class Tok {
  static const double s2 = 2, s4 = 4, s6 = 6, s8 = 8, s10 = 10, s12 = 12,
      s14 = 14, s16 = 16, s20 = 20, s24 = 24, s28 = 28, s32 = 32, s48 = 48;

  static const double r8 = 8, r12 = 12, r16 = 16, r20 = 20, r24 = 24, r99 = 99;

  static const double f11 = 11, f12 = 12, f13 = 13, f14 = 14, f15 = 15,
      f16 = 16, f18 = 18, f22 = 22, f26 = 26, f28 = 28;

  static const double i18 = 18, i22 = 22, i28 = 28, i32 = 32, i48 = 48, i64 = 64;

  static const LinearGradient heroGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1F3C), Color(0xFF2D3561)],
  );
  static const LinearGradient accentGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C42)],
  );
  static const LinearGradient commissionGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4776E6), Color(0xFF8E54E9)],
  );
  static const LinearGradient subGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
  );
}
