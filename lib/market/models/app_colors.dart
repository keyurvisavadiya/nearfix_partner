import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core green palette
  static const primary       = Color(0xFF00875A); // rich forest green
  static const primaryDark   = Color(0xFF006644);
  static const primaryLight  = Color(0xFFE3FCEF);
  static const primaryMid    = Color(0xFF57D9A3); // mint accent

  // Aliases for backward compat
  static const purple   = primary;
  static const purpleBg = primaryLight;
  static const green    = primary;

  // Neutrals
  static const bg         = Color(0xFFF4F5F7);
  static const dark       = Color(0xFF172B4D);
  static const grey       = Color(0xFF7A869A);
  static const labelGrey  = Color(0xFF97A0AF);
  static const borderGrey = Color(0xFFDFE1E6);
  static const divider    = Color(0xFFEBECF0);
  static const cardText   = Color(0xFF42526E);

  // Surface
  static const surface    = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFFAFBFC);
}
