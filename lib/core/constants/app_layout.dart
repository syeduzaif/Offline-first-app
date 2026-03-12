import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';

class AppLayout {
  AppLayout._();

  // Radii
  static double get radiusXxs => 2.r;
  static double get radiusXs => 4.r;
  static double get radiusSm => 8.r;
  static double get radiusMd => 12.r;
  static double get radiusLg => 16.r;
  static double get radiusXl => 20.r;
  static double get radiusXxl => 30.r;
  static double get radiusFull => 1000.r;

  // Heights
  static double get height2 => 2.h;
  static double get height4 => 4.h;
  static double get height6 => 6.h;
  static double get height8 => 8.h;
  static double get height10 => 10.h;
  static double get height12 => 12.h;
  static double get height16 => 16.h;
  static double get height20 => 20.h;
  static double get height24 => 24.h;
  static double get height32 => 32.h;
  static double get height42 => 42.h;
  static double get height48 => 48.h;
  static double get height56 => 56.h;
  static double get height80 => 80.h;
  static double get height100 => 100.h;
  static double get height120 => 120.h;
  static double get height140 => 140.h;
  static double get height200 => 200.h;

  // Widths
  static double get width4 => 4.w;
  static double get width8 => 8.w;
  static double get width12 => 12.w;
  static double get width16 => 16.w;
  static double get width20 => 20.w;
  static double get width24 => 24.w;
  static double get width40 => 40.w;
  static double get width56 => 56.w;
  static double get width80 => 80.w;
  static double get width100 => 100.w;

  // Icon sizes
  static double get iconSizeXs => 12.w;
  static double get iconSizeSm => 16.w;
  static double get iconSizeMdSm => 20.w;
  static double get iconSizeMd => 24.w;
  static double get iconSizeLg => 32.w;
  static double get iconSizeXl => 40.w;

  // Avatar sizes
  static double get avatarSm => 32.w;
  static double get avatarMd => 40.w;
  static double get avatarLg => 48.w;

  // Stroke widths
  static const double strokeWidthThin = 1.5;
  static const double strokeWidthMedium = 2.0;

  // Navigation
  static double get bottomNavBarHeight => 64.h;

  // Shadows
  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
