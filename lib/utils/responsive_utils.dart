import 'package:flutter/material.dart';

class ResponsiveUtils {
  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 700;
  }

  static bool isVerySmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.height > 800;
  }

  static bool isWideScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 400;
  }

  static double getAdaptivePadding(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 12.0;
    } else if (isSmallScreen(context)) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  static double getAdaptiveSpacing(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 12.0;
    } else if (isSmallScreen(context)) {
      return 16.0;
    } else {
      return 24.0;
    }
  }

  static double getAdaptiveIconSize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 60.0;
    } else if (isSmallScreen(context)) {
      return 80.0;
    } else {
      return 100.0;
    }
  }

  static double getAdaptiveTitleSize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 18.0;
    } else if (isSmallScreen(context)) {
      return 20.0;
    } else {
      return 24.0;
    }
  }

  static double getAdaptiveBodySize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 12.0;
    } else if (isSmallScreen(context)) {
      return 14.0;
    } else {
      return 16.0;
    }
  }

  static double getAdaptiveCaptionSize(BuildContext context) {
    if (isVerySmallScreen(context)) {
      return 10.0;
    } else if (isSmallScreen(context)) {
      return 12.0;
    } else {
      return 14.0;
    }
  }

  static EdgeInsets getScreenPadding(BuildContext context) {
    final padding = getAdaptivePadding(context);
    return EdgeInsets.all(padding);
  }

  static Widget responsiveColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
  }) {
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  static Widget responsiveContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    BoxDecoration? decoration,
  }) {
    return Container(
      padding: padding ?? EdgeInsets.all(getAdaptivePadding(context)),
      decoration: decoration,
      child: child,
    );
  }

  static Widget scrollableContent({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return SingleChildScrollView(
      padding: padding ?? getScreenPadding(context),
      child: child,
    );
  }
}
