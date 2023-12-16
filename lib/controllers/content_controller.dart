import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/api/server_api.dart';
import 'package:soda/modals/http_server.dart';
import 'package:soda/pages/add_server.func.dart';
import 'package:soda/providers/preferences_service.dart';

import '../modals/page_content.dart';

final contentControllerProvider = Provider((ref) => ContentController(ref));

final serverListStateProvider = StateProvider<List<String>>((ref) {
  final servers = PreferencesService.prefs.getStringList('servers') ?? [];

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
    final res = await ServerApi().getContent(ref.watch(httpServerStateProvider));

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

  void selectServer(String url) {
    List<String> serverListString = PreferencesService.prefs.getStringList('servers') ?? [];

    for (var s in serverListString) {
      final server = HttpServer.fromRawJson(s);
      if (server.url == url) {
        ref.read(httpServerStateProvider.notifier).update((state) => server);
      }
    }
  }

  Future<void> updateServerList() async {
    List<String> serverList = PreferencesService.prefs.getStringList('servers') ?? [];
    final newServer = ref.watch(httpServerStateProvider).toRawJson();

    if (!serverList.contains(newServer)) {
      serverList.add(newServer);
      await PreferencesService.prefs.setStringList('servers', serverList);
    }
  }
}
