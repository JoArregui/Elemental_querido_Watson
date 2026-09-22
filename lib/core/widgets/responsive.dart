import 'package:flutter/material.dart';

class Responsive {
  static bool isPhone(BuildContext c) => MediaQuery.of(c).size.width < 600;
  static bool isTablet(BuildContext c) => MediaQuery.of(c).size.width >= 600 && MediaQuery.of(c).size.width < 1024;
  static bool isDesktop(BuildContext c) => MediaQuery.of(c).size.width >= 1024;
  static bool isLandscape(BuildContext c) => MediaQuery.of(c).orientation == Orientation.landscape;

  static double contentMaxWidth(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1200) return 1100;
    if (w >= 900) return 860;
    if (w >= 600) return w * 0.92;
    return w;
  }

  static EdgeInsets pagePadding(BuildContext c) {
    if (isPhone(c)) return const EdgeInsets.all(12);
    if (isTablet(c)) return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
  }

  static int libraryCrossAxisCount(BuildContext c) {
    final w = MediaQuery.of(c).size.width;
    if (w >= 1200) return 2;
    if (w >= 700) return 2;
    return 1;
  }

  static double bookSheetMaxWidth(BuildContext c) {
    if (isDesktop(c)) return 720;
    if (isTablet(c)) return 640;
    return double.infinity;
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  const ResponsiveCenter({super.key, required this.child, this.maxWidth});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? Responsive.contentMaxWidth(context)),
        child: child,
      ),
    );
  }
}
