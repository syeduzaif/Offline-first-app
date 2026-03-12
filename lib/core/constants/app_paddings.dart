import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppPaddings {
  AppPaddings._();

  static double get smallest => 4.w;
  static double get small => 8.w;
  static double get mediumSmall => 12.w;
  static double get base => 16.w;
  static double get medium => 24.w;
  static double get large => 32.w;

  static double get verticalSmallest => 4.h;
  static double get verticalSmall => 6.h;
  static double get verticalBase => 8.h;
  static double get verticalMedium => 12.h;
  static double get verticalLarge => 16.h;

  static EdgeInsets all(double value) => EdgeInsets.all(value);
  static EdgeInsets get allSmallest => EdgeInsets.all(smallest);
  static EdgeInsets get allSmall => EdgeInsets.all(small);
  static EdgeInsets get allMediumSmall => EdgeInsets.all(mediumSmall);
  static EdgeInsets get allBase => EdgeInsets.all(base);
  static EdgeInsets get allMedium => EdgeInsets.all(medium);
  static EdgeInsets get allLarge => EdgeInsets.all(large);

  static EdgeInsets symmetric({
    double? horizontal,
    double? vertical,
  }) =>
      EdgeInsets.symmetric(
        horizontal: horizontal ?? 0,
        vertical: vertical ?? 0,
      );

  static EdgeInsets get horizontalSmall =>
      EdgeInsets.symmetric(horizontal: small);
  static EdgeInsets get horizontalMediumSmall =>
      EdgeInsets.symmetric(horizontal: mediumSmall);
  static EdgeInsets get horizontalBase =>
      EdgeInsets.symmetric(horizontal: base);
  static EdgeInsets get horizontalMedium =>
      EdgeInsets.symmetric(horizontal: medium);

  static EdgeInsets get verticalSmallPadding =>
      EdgeInsets.symmetric(vertical: verticalSmall);
  static EdgeInsets get verticalBasePadding =>
      EdgeInsets.symmetric(vertical: verticalBase);

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

  static EdgeInsets get bottomSmall => EdgeInsets.only(bottom: small);
  static EdgeInsets get bottomBase => EdgeInsets.only(bottom: base);
  static EdgeInsets get bottomMedium =>
      EdgeInsets.only(bottom: verticalMedium);
}
