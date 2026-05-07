import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppMargins {
  AppMargins._();

  static double get smallest    => 4.w;
  static double get small       => 8.w;
  static double get mediumSmall => 12.w;
  static double get base        => 16.w;
  static double get medium      => 24.w;
  static double get large       => 32.w;

  static EdgeInsets get allSmall       => EdgeInsets.all(small);
  static EdgeInsets get allBase        => EdgeInsets.all(base);
  static EdgeInsets get allMedium      => EdgeInsets.all(medium);
  static EdgeInsets get horizontalBase => EdgeInsets.symmetric(horizontal: base);
  static EdgeInsets get verticalBase   => EdgeInsets.symmetric(vertical: 8.h);
}
