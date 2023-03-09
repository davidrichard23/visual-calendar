import 'package:flutter/material.dart';

class ResponsiveLayoutHelper {
  static const int mobileMaxWidth = 576;
  static const int tabletMaxWidth = 768;
  static const int desktopMaxWidth = 992;

  static bool isMobile(context) {
    return MediaQuery.of(context).size.width <= mobileMaxWidth;
  }

  static bool isTablet(context) {
    return mobileMaxWidth < MediaQuery.of(context).size.width &&
        MediaQuery.of(context).size.width <= tabletMaxWidth;
  }

  static bool isDesktop(context) {
    return tabletMaxWidth < MediaQuery.of(context).size.width &&
        MediaQuery.of(context).size.width <= desktopMaxWidth;
  }

  static bool isLarge(context) {
    return desktopMaxWidth < MediaQuery.of(context).size.width;
  }
}
