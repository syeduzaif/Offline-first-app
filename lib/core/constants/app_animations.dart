import 'package:flutter/animation.dart';

class AppAnimations {
  AppAnimations._();

  // Durations
  static const Duration durationXxs = Duration(milliseconds: 100);
  static const Duration durationXs = Duration(milliseconds: 150);
  static const Duration durationSm = Duration(milliseconds: 200);
  static const Duration durationMd = Duration(milliseconds: 250);
  static const Duration durationBase = Duration(milliseconds: 300);
  static const Duration durationLg = Duration(milliseconds: 400);
  static const Duration durationXl = Duration(milliseconds: 500);

  // Curves
  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveInOut = Curves.easeInOut;
  static const Curve curveOut = Curves.easeOut;
  static const Curve curveIn = Curves.easeIn;
  static const Curve curveFastOutSlowIn = Curves.fastOutSlowIn;

  // Scale
  static const double scalePressed = 0.95;
  static const double scaleNormal = 1.0;

  // Offsets
  static const Offset offsetSlideRight = Offset(1.0, 0.0);
  static const Offset offsetSlideBottom = Offset(0.0, 1.0);
  static const Offset offsetZero = Offset.zero;

  // Opacity
  static const double opacityTransparent = 0.0;
  static const double opacityHalf = 0.5;
  static const double opacityFull = 1.0;
}
