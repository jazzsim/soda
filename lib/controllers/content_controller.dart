import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:soda/api/server_api.dart';
import 'package:soda/modals/http_server.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/providers/preferences_service.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/components/video/video_control.dart';

import '../modals/page_content.dart';

final httpServerStateProvider = StateProvider<HttpServer>((ref) => HttpServer(url: '', username: '', password: ''));

final pathStateProvider = StateProvider<String>((ref) => '');

final baseURLStateProvider = StateProvider<String>((ref) => ref.watch(httpServerStateProvider).url + ref.watch(pathStateProvider));

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

  Map<String, String> authHeader() => {
        "Authorization": "Basic ${base64.encode(utf8.encode('${ref.read(httpServerStateProvider).username}:${ref.read(httpServerStateProvider).password}'))}",
      };

  Future<void> getPageContent({bool browse = false}) async {
    clear();

    final String path = browse ? ref.read(browsePathStateProvider) : ref.read(pathStateProvider);
    // append path to selected server
    HttpServer targetServer = ref.read(httpServerStateProvider).copyWith(url: ref.read(httpServerStateProvider).url + path);
    final res = await ServerApi().getContent(targetServer);

    ref.read(pageContentStateProvider.notifier).update((state) => state.copyWith(folders: res.folders, files: res.files));
    sortFiles();
  }

  void sortFiles() {
    List<String> mediaTypes = ['image', 'video', 'document', 'others'];

    for (var type in mediaTypes) {
      final contents = ref.read(pageContentStateProvider).files.where((file) => file.media.toLowerCase() == type).toList();
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

  Uri handleReverse({bool browse = false}) {
    String path = browse ? ref.read(browsePathStateProvider) : ref.read(pathStateProvider);
    Uri originalUri = Uri.parse(ref.watch(httpServerStateProvider).url + path);
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

  // video
  Future<String> vidThumbnail(String filename) async {
    try {
      String url = ref.read(baseURLStateProvider) + filename;
      final res = await ServerApi().getThumbnail(getUrl(url), filename);
      return res.thumbnail;
    } catch (e) {
      log("error $e");
    }

    return '';
  }

  // pdf
  Future<String> pdfThumbnail(String filename) async {
    try {
      String url = ref.read(baseURLStateProvider) + filename;
      final doc = PdfViewer.uri(Uri.parse(getUrl(url)));
      return doc.documentRef.sourceName;
      // return res.thumbnail;
    } catch (e) {}
    return "";
  }

  String getUrl(String url) {
    final username = ref.watch(httpServerStateProvider).username;
    final password = ref.watch(httpServerStateProvider).password;
    if (username != '' && password != '') {
      var uri = Uri.parse(url);
      url = uri.replace(userInfo: '$username:$password').toString();
    }

    return url;
  }

  void startCancelTimer() {
    const Duration volumeDuration = Duration(milliseconds: 1200);

    ref.read(videoTimerProvider)?.cancel();
    ref.read(videoTimerProvider.notifier).state = Timer(volumeDuration, () {
      ref.read(showVolumeProvider.notifier).update((state) => false);
    });
  }

  void autoLoadSubs(Player player, String filename) async {
    List<String> subsExt = ['srt', 'ass', 'sub', 'vtt', 'ssa'];

    for (var otherFile in ref.read(othersContentStateProvider)) {
      for (var ext in subsExt) {
        if (otherFile.filename.contains(ext)) {
          if (compareWithoutExtension(filename, otherFile.filename)) {
            loadExternalSubs(player, otherFile);
            // load the first matched
            return;
          }
        }
      }
    }
  }

  Future<void> loadExternalSubs(Player player, FileElement otherFile) async {
    File file = File('.cache/${otherFile.filename}');
    final url = ref.read(httpServerStateProvider).url + ref.read(browsePathStateProvider);

    // check if cached
    if (await file.exists() == false) {
      final response = await http.get(Uri.parse(getUrl(url) + otherFile.filename));
      file = await cache(otherFile.filename);
      await file.writeAsBytes(response.bodyBytes);
    }

    try {
      await player.setSubtitleTrack(
        SubtitleTrack.data(
          file.readAsStringSync(),
          title: Uri.decodeComponent(otherFile.filename),
        ),
      );
    } catch (e) {
      if (e is FileSystemException) {
        String content = decodeFile(file.readAsBytesSync());

        await player.setSubtitleTrack(
          SubtitleTrack.data(
            content,
            title: Uri.decodeComponent(otherFile.filename),
          ),
        );
      }
    }
  }

  Future<File> cache(String filename) async {
    // Check if the directory exists, if not, create it
    final cacheDir = Directory('.cache/');
    if (!(await cacheDir.exists())) {
      cacheDir.create();
    }
    return File('.cache/$filename');
  }

  String decodeFile(Uint8List fileBytes) {
    List<Codec> codecList = [ascii, utf8, latin1];
    String content = "";
    for (var codec in codecList) {
      try {
        content = codec.decode(fileBytes);
      } catch (e) {
        log('e $e');
      }
    }
    return content;
  }

  bool compareWithoutExtension(String string1, String string2) {
    RegExp regExp = RegExp(r'([^\.]+)');
    String filename1 = regExp.firstMatch(string1)?.group(1) ?? string1;
    String filename2 = regExp.firstMatch(string2)?.group(1) ?? string2;
    return filename1 == filename2;
  }

  void clear() {
    ref.invalidate(imagesContentStateProvider);
    ref.invalidate(videosContentStateProvider);
    ref.invalidate(documentsContentStateProvider);
    ref.invalidate(othersContentStateProvider);
  }
}
