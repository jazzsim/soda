import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/pages/mobile/home_page.m.dart';

class HomePageTablet extends ConsumerWidget {
  const HomePageTablet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: HomePageMobile(),
    );
  }
}
