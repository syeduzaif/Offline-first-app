import 'package:flutter/material.dart';
import 'package:offline_first_app/core/constants/app_colors.dart';
import 'package:offline_first_app/core/constants/app_font_sizes.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String fontFamily = 'Outfit';

  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;

  static const Color _defaultColor = AppColors.black;

  // Display
  static TextStyle get displayLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.displayLg,
        fontWeight: regular,
        height: 1.12,
        color: _defaultColor,
      );
  static TextStyle get displayMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.displayMd,
        fontWeight: regular,
        height: 1.16,
        color: _defaultColor,
      );
  static TextStyle get displaySm => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.displaySm,
        fontWeight: regular,
        height: 1.22,
        color: _defaultColor,
      );

  // Headings
  static TextStyle get h1 => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.h1,
        fontWeight: semiBold,
        height: 1.25,
        color: _defaultColor,
      );
  static TextStyle get h2 => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.h2,
        fontWeight: semiBold,
        height: 1.29,
        color: _defaultColor,
      );
  static TextStyle get h3 => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.h3,
        fontWeight: semiBold,
        height: 1.33,
        color: _defaultColor,
      );
  static TextStyle get h4 => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.h4,
        fontWeight: medium,
        height: 1.27,
        color: _defaultColor,
      );

  // Titles
  static TextStyle get titleLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.titleLg,
        fontWeight: semiBold,
        height: 1.33,
        color: _defaultColor,
      );
  static TextStyle get titleMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.titleMd,
        fontWeight: semiBold,
        height: 1.5,
        color: _defaultColor,
      );
  static TextStyle get titleSm => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.titleSm,
        fontWeight: semiBold,
        height: 1.43,
        color: _defaultColor,
      );

  // Body
  static TextStyle get bodyLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.bodyLg,
        fontWeight: regular,
        height: 1.5,
        color: _defaultColor,
      );
  static TextStyle get bodyMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.bodyMd,
        fontWeight: regular,
        height: 1.43,
        color: _defaultColor,
      );
  static TextStyle get bodySm => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.bodySm,
        fontWeight: regular,
        height: 1.5,
        color: _defaultColor,
      );

  // Labels
  static TextStyle get labelLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.labelLg,
        fontWeight: medium,
        height: 1.43,
        color: _defaultColor,
      );
  static TextStyle get labelMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.labelMd,
        fontWeight: medium,
        height: 1.33,
        color: _defaultColor,
      );
  static TextStyle get labelSm => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.labelSm,
        fontWeight: medium,
        height: 1.45,
        color: _defaultColor,
      );

  // Captions
  static TextStyle get captionLg => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.captionLg,
        fontWeight: regular,
        height: 1.33,
        color: _defaultColor,
      );
  static TextStyle get captionMd => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.captionMd,
        fontWeight: regular,
        height: 1.45,
        color: _defaultColor,
      );
  static TextStyle get captionSm => TextStyle(
        fontFamily: fontFamily,
        fontSize: AppFontSizes.captionSm,
        fontWeight: regular,
        height: 1.6,
        color: _defaultColor,
      );

  // Legacy aliases
  static TextStyle get headlineLarge => h1;
  static TextStyle get headlineMedium => h2;
  static TextStyle get headlineSmall => h3;
  static TextStyle get titleLarge => h4;
  static TextStyle get titleMedium => titleMd;
  static TextStyle get titleSmall => titleSm;
  static TextStyle get bodyLarge => bodyLg;
  static TextStyle get bodyMedium => bodyMd;
  static TextStyle get bodySmall => captionLg;
  static TextStyle get labelLarge => labelLg;
  static TextStyle get labelMedium => labelMd;
  static TextStyle get labelSmall => labelSm;
}

extension TextStyleExtension on TextStyle {
  TextStyle get light => copyWith(fontWeight: FontWeight.w300);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withHeight(double height) => copyWith(height: height);
  TextStyle withLetterSpacing(double spacing) =>
      copyWith(letterSpacing: spacing);
}
