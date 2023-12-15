import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'desktop/home_page.d.dart';
import 'mobile/home_page.m.dart';
import 'responsive_layout.dart';
import 'tablet/home_page.t.dart';

final selectedIndexStateProvvider = StateProvider<int?>((ref) => null);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: HomePageMobile(),
      tabletLayout: HomePageTablet(),
      dekstopLayout: HomePageDekstop(),
    );
  }
}
