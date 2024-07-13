import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soda/api/server_api.dart';
import 'package:soda/controllers/content_controller.dart';

// Necessary for code-generation to work
part 'provider.g.dart';

// Non autoDispose provider
@Riverpod(keepAlive: true)
Future<String> vidThumbnail(VidThumbnailRef ref, String filename) async {
  try {
    String url = ref.read(baseURLStateProvider) + filename;
    final res = await ServerApi().getThumbnail(getUrl(ref, url), filename);
    return res.thumbnail;
  } catch (e) {
    log("error $e");
  }

  return '';
}

String getUrl(VidThumbnailRef ref, String url) {
  final username = ref.watch(httpServerStateProvider).username;
  final password = ref.watch(httpServerStateProvider).password;
  if (username != '' && password != '') {
    var uri = Uri.parse(url);
    url = uri.replace(userInfo: '$username:$password').toString();
  }

  return url;
}
