import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Get screen type based on width
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  // Get responsive size based on screen width
  static double getResponsiveSize(BuildContext context, double baseSize) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return baseSize;
      case ScreenType.tablet:
        return baseSize * 1.2;
      case ScreenType.desktop:
        return baseSize * 1.4;
    }
  }

  // Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Scale font size based on screen width, with minimum and maximum bounds
    final scaleFactor = screenWidth / 375.0; // 375 is iPhone 6/7/8 width
    final scaledSize = baseSize * scaleFactor;
    return scaledSize.clamp(baseSize * 0.8, baseSize * 1.5);
  }

  // Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double horizontal = 16.0,
    double vertical = 16.0,
  }) {
    final screenType = getScreenType(context);
    final multiplier = screenType == ScreenType.mobile ? 1.0 :
                      screenType == ScreenType.tablet ? 1.5 : 2.0;

    return EdgeInsets.symmetric(
      horizontal: horizontal * multiplier,
      vertical: vertical * multiplier,
    );
  }

  // Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context, {
    double horizontal = 16.0,
    double vertical = 16.0,
  }) {
    return getResponsivePadding(context, horizontal: horizontal, vertical: vertical);
  }

  // Get responsive height
  static double getResponsiveHeight(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.height * percentage;
  }

  // Get responsive width
  static double getResponsiveWidth(BuildContext context, double percentage) {
    return MediaQuery.of(context).size.width * percentage;
  }

  // Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getScreenType(context) == ScreenType.mobile;
  }

  // Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getScreenType(context) == ScreenType.tablet;
  }

  // Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getScreenType(context) == ScreenType.desktop;
  }

  // Get grid cross axis count based on screen size
  static int getGridCrossAxisCount(BuildContext context, {int maxCount = 3}) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return maxCount > 2 ? 2 : maxCount;
      case ScreenType.tablet:
        return maxCount > 3 ? 3 : maxCount;
      case ScreenType.desktop:
        return maxCount;
    }
  }

  // Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    return getResponsiveSize(context, baseSize);
  }

  // Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    return getResponsiveSize(context, baseRadius);
  }

  // Get responsive elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    final screenType = getScreenType(context);
    final multiplier = screenType == ScreenType.mobile ? 1.0 : 1.2;
    return baseElevation * multiplier;
  }
}

enum ScreenType {
  mobile,
  tablet,
  desktop,
}

// Extension methods for easier usage
extension ResponsiveExtension on BuildContext {
  ScreenType get screenType => ResponsiveUtils.getScreenType(this);
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);

  double responsiveSize(double baseSize) => ResponsiveUtils.getResponsiveSize(this, baseSize);
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  double responsiveHeight(double percentage) => ResponsiveUtils.getResponsiveHeight(this, percentage);
  double responsiveWidth(double percentage) => ResponsiveUtils.getResponsiveWidth(this, percentage);
  double responsiveIconSize(double baseSize) => ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  double responsiveBorderRadius(double baseRadius) => ResponsiveUtils.getResponsiveBorderRadius(this, baseRadius);
  double responsiveElevation(double baseElevation) => ResponsiveUtils.getResponsiveElevation(this, baseElevation);

  EdgeInsets responsivePadding({double horizontal = 16.0, double vertical = 16.0}) {
    return ResponsiveUtils.getResponsivePadding(this, horizontal: horizontal, vertical: vertical);
  }

  EdgeInsets responsiveMargin({double horizontal = 16.0, double vertical = 16.0}) {
    return ResponsiveUtils.getResponsiveMargin(this, horizontal: horizontal, vertical: vertical);
  }

  int gridCrossAxisCount({int maxCount = 3}) {
    return ResponsiveUtils.getGridCrossAxisCount(this, maxCount: maxCount);
  }
}
