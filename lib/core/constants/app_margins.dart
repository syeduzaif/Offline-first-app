import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppMargins {
  AppMargins._();

  static double get smallest => 4.w;
  static double get small => 8.w;
  static double get base => 16.w;
  static double get medium => 24.w;
  static double get large => 32.w;

  static EdgeInsets symmetric({
    double? horizontal,
    double? vertical,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );

  static EdgeInsets only({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) =>
      EdgeInsets.only(
        top: top ?? 0,
        bottom: bottom ?? 0,
        left: left ?? 0,
        right: right ?? 0,
      );
}
