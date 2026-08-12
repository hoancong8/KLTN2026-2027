import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_color.dart';

//R = Regular
//SB = SemiBold
//I = Italic
//M = Medium

class AppTextStyle {
  AppTextStyle._();

  static String fontAver = 'Fonts_AvertaStdCy';
  static String fontIBM = 'IBM_Plex_Sans';

  static AppTextStyle? _instance;

  static AppTextStyle get instance {
    return _instance ??= AppTextStyle._();
  }

  void refresh() {
    _instance = AppTextStyle._();
  }

  TextStyle textDisplay31SB = TextStyle(
    fontSize: 18,
    height: 39 / 31,
    letterSpacing: 0,
    fontFamily: fontAver,
    fontWeight: FontWeight.w600,
    color: AppColor.cBlack_50,
  );

  TextStyle textDisplay31R = TextStyle(
    fontSize: 16,
    height: 39 / 31,
    letterSpacing: 0,
    fontFamily: fontAver,
    fontWeight: FontWeight.w400,
    color: AppColor.cGray70,
  );
}
