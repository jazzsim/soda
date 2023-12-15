import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileLayout;
  final Widget tabletLayout;
  final Widget dekstopLayout;
  const ResponsiveLayout({super.key, required this.mobileLayout, required this.tabletLayout, required this.dekstopLayout});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraint) {
      if (constraint.maxWidth < 640) {
        return mobileLayout;
      } else if (constraint.maxWidth > 640 && constraint.maxWidth < 1025) {
        return tabletLayout;
      } else {
        return dekstopLayout;
      }
    });
  }
}
