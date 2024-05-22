import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:soda/constants/colours.dart';
import 'package:soda/pages/home_page.dart';
import 'package:window_manager/window_manager.dart';

import 'providers/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Must add this line.
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    center: true,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });

  await PreferencesService.initialize();
  MediaKit.ensureInitialized();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'home',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const HomePage();
      //     },
      //   ),
      // ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('jazzsim.soda/cursor');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Soda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: themePrimary),
      ),
      routerConfig: _router,
    );
  }
}
