import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
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
    size: Size(1400, 800),
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
  });

  await PreferencesService.initialize();
  MediaKit.ensureInitialized();

  // clear subtitle cache
  Directory cache = Directory(".cache/");
  if (cache.existsSync()) {
    for (var file in cache.listSync()) {
      file.deleteSync();
    }
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static const platform = MethodChannel('jazzsim.soda/cursor');
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soda',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: themePrimary),
      ),
      home: const HomePage(),
    );
  }
}
