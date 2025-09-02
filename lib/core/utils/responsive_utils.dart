import 'package:flutter/material.dart';

/// Utility class to handle responsive spacing and prevent overflow issues
class ResponsiveUtils {
  static const double baseWidth = 375.0; // iPhone SE width as base
  static const double baseHeight = 667.0; // iPhone SE height as base

  /// Get responsive width based on screen size
  static double width(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (size * screenWidth) / baseWidth;
  }

  /// Get responsive height based on screen size
  static double height(BuildContext context, double size) {
    final screenHeight = MediaQuery.of(context).size.height;
    return (size * screenHeight) / baseHeight;
  }

  /// Get responsive font size
  static double fontSize(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    return (size * screenWidth) / baseWidth;
  }

  /// Safe area padding
  static EdgeInsets safePadding(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return EdgeInsets.only(
      top: mediaQuery.padding.top,
      bottom: mediaQuery.padding.bottom,
      left: mediaQuery.padding.left,
      right: mediaQuery.padding.right,
    );
  }

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) {
      return ScreenSize.mobile;
    } else if (width < 900) {
      return ScreenSize.tablet;
    } else {
      return ScreenSize.desktop;
    }
  }

  /// Get appropriate grid count based on screen size
  static int getGridCount(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 2;
      case ScreenSize.tablet:
        return 3;
      case ScreenSize.desktop:
        return 4;
    }
  }

  /// Get appropriate card width for lists
  static double getCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.mobile:
        return screenWidth * 0.4;
      case ScreenSize.tablet:
        return screenWidth * 0.3;
      case ScreenSize.desktop:
        return screenWidth * 0.25;
    }
  }

  /// Get bottom navigation bar height
  static double getBottomNavHeight(BuildContext context) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.mobile:
        return 80;
      case ScreenSize.tablet:
        return 90;
      case ScreenSize.desktop:
        return 100;
    }
  }
}

enum ScreenSize { mobile, tablet, desktop }

/// Widget wrapper that prevents overflow
class OverflowSafeWidget extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const OverflowSafeWidget({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(8),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Text widget that automatically handles overflow
class SafeText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final int? maxLines;
  final TextAlign? textAlign;

  const SafeText(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Text(
        text,
        style: style,
        maxLines: maxLines ?? 2,
        overflow: TextOverflow.ellipsis,
        textAlign: textAlign,
        softWrap: true,
      ),
    );
  }
}
