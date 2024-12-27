import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/services/device_size.dart';
import 'package:window_manager/window_manager.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Must add this line.
    await windowManager.ensureInitialized();
  }

  await PreferencesService.initialize();

  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  // Set version
  String version = packageInfo.version;
  String code = packageInfo.buildNumber;
  PreferencesService().setVersion("v$version ($code)");

  MediaKit.ensureInitialized();

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
  build(BuildContext context) {
    DeviceSizeService.instance.initialize(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soda',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(centerTitle: true),
      ),
      home: const HomePage(),
    );
  }
}
