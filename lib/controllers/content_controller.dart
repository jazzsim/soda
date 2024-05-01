import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/api/server_api.dart';
import 'package:soda/modals/http_server.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/providers/preferences_service.dart';

import '../modals/page_content.dart';

final httpServerStateProvider = StateProvider<HttpServer>((ref) => HttpServer(url: '', username: '', password: ''));

final pathStateProvider = StateProvider<String>((ref) => '');

final titleStateProvider = StateProvider<String>((ref) => '');

final contentControllerProvider = Provider((ref) => ContentController(ref));

final serverListStateProvider = StateProvider<List<String>>((ref) {
  final servers = PreferencesService().getServerList();

  var urls = <String>[];
  for (var s in servers) {
    final server = HttpServer.fromRawJson(s);
    urls.add(server.url);
  }

  return urls;
});

final pageContentStateProvider = StateProvider<PageContent>((ref) {
  return PageContent(folders: [], files: []);
});

final imagesContentStateProvider = StateProvider<List<FileElement>>((ref) => []);

final videosContentStateProvider = StateProvider<List<FileElement>>((ref) => []);

final documentsContentStateProvider = StateProvider<List<FileElement>>((ref) => []);

final othersContentStateProvider = StateProvider<List<FileElement>>((ref) => []);

class ContentController {
  final ProviderRef<Object?> ref;
  ContentController(this.ref);

  Future<void> getPageContent() async {
    // append path to selected server
    HttpServer targetServer = ref.watch(httpServerStateProvider).copyWith(url: ref.watch(httpServerStateProvider).url + ref.watch(pathStateProvider));
    final res = await ServerApi().getContent(targetServer);

    ref.read(pageContentStateProvider.notifier).update((state) => state.copyWith(folders: res.folders, files: res.files));
    sortFiles();
  }

  void sortFiles() {
    List<String> mediaTypes = ['image', 'video', 'document', 'others'];

    for (var type in mediaTypes) {
      final contents = ref.watch(pageContentStateProvider).files.where((file) => file.media.toLowerCase() == type).toList();
      switch (type) {
        case "image":
          ref.read(imagesContentStateProvider.notifier).update((state) => contents);
          break;
        case "video":
          ref.read(videosContentStateProvider.notifier).update((state) => contents);
          break;
        case "document":
          ref.read(documentsContentStateProvider.notifier).update((state) => contents);
          break;
        default:
          ref.read(othersContentStateProvider.notifier).update((state) => contents);
      }
    }
  }

  // will sort the saved server url into proper origin and path pair
  // e.g: If saved url was https://example.com/a1/films/,
  // will be separate as https://example.com and /a1/films/ and assign to respective StateProviders
  Uri selectServer(String url) {
    List<String> serverListString = PreferencesService().getServerList();

    for (var s in serverListString) {
      final server = HttpServer.fromRawJson(s);
      if (server.url == url) {
        ref.read(httpServerStateProvider.notifier).update(
              (state) => state.copyWith(
                url: url,
                username: server.username,
                password: server.password,
              ),
            );
        Uri serverUri = Uri.parse(server.url);

        return serverUri;
      }
    }
    return Uri.parse(ref.read(httpServerStateProvider).url);
  }

  Uri handleReverse() {
    Uri originalUri = Uri.parse(ref.watch(httpServerStateProvider).url + ref.watch(pathStateProvider));
    List<String> newPathSegments = List.from(originalUri.pathSegments);

    // remove empty path ("/")
    if (newPathSegments.last == '') {
      newPathSegments.removeLast();
    }

    // remove latest path
    newPathSegments.removeLast();

    Uri modifiedUri = originalUri.replace(pathSegments: newPathSegments);
    return modifiedUri;
  }

  Future<void> updateServerList() async {
    List<String> serverList = PreferencesService().getServerList();
    final newServer = ref.watch(httpServerStateProvider).toRawJson();

    if (!serverList.contains(newServer)) {
      serverList.add(newServer);
      ref.read(selectedIndexStateProvvider.notifier).update((state) => serverList.length - 1);
      await PreferencesService().setServerList(serverList);
    }
  }

  Future<void> deleteServer(int index) async {
    final selectedServer = ref.watch(serverListStateProvider)[index];
    List<String> serverList = PreferencesService().getServerList();
    List<String> newServerList = [];

    for (var server in serverList) {
      var serverJson = jsonDecode(server);
      if (serverJson["url"] != selectedServer) {
        newServerList.add(json.encode(serverJson));
      }
    }
    await PreferencesService().setServerList(newServerList);
    ref.invalidate(serverListStateProvider);

    // clear content if current active content is from deleted server
    if (ref.watch(selectedIndexStateProvvider) == index) {
      ref.invalidate(selectedIndexStateProvvider);
      ref.invalidate(pageContentStateProvider);
    }
  }
}
