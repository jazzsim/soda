import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/pages/mobile/add_server.m.dart';

import '../modals/http_server.dart';

final httpServerStateProvider = StateProvider<HttpServer>((ref) => HttpServer(url: '', username: '', password: ''));

void addServer(WidgetRef ref, BuildContext context, double screenWidth) {
  if (screenWidth < 640) {
    // showModalBottomSheet function
    addServerModal(ref, context);
  } else if (screenWidth > 640 && screenWidth < 1025) {
    // showModalBottomSheet / showDialog function
  } else {
    // showModalBottomSheet / showDialog function
  }
}
