import 'package:flutter/material.dart';
import 'package:kltn2026_2027/app/consts/app_dimens.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppDimens.tabletBreakpoint) {
          return tablet;
        }
        return mobile;
      },
    );
  }
}
