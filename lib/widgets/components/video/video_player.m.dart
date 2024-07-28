import 'dart:io';
import 'dart:ui';

import 'package:extended_text/extended_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/services/device_size.dart';
import 'package:soda/widgets/components/dialogs/loading_view.dart';
import 'package:soda/widgets/components/dialogs/toast_overlay.dart';
import 'package:soda/widgets/components/primary_button.dart';
import 'package:soda/widgets/components/secondary_button.dart';
import 'package:soda/widgets/components/video/video_control.m.dart';
import 'package:soda/widgets/extensions/padding.dart';
import 'package:soda/widgets/extensions/row.dart';

final onHoverDurationProvider = StateProvider<String?>((ref) => null);

final playlistProvider = StateProvider<List<Media>>((ref) => []);

final playingVideoProvider = StateProvider<int>((ref) => 0);

final alterVideoDurationStateProvider = StateProvider<bool>((ref) => false);

final browsePathStateProvider = StateProvider.autoDispose<String>((ref) => ref.read(pathStateProvider));

class MobilleVideoPlayer extends ConsumerStatefulWidget {
  final String url;
  const MobilleVideoPlayer(this.url, {super.key});

  @override
  ConsumerState<MobilleVideoPlayer> createState() => _MobilleVideoPlayerState();
}

class _MobilleVideoPlayerState extends ConsumerState<MobilleVideoPlayer> {
  final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (player.platform is NativePlayer) {
          await (player.platform as dynamic).setProperty(
            'force-seekable',
            'yes',
          );
          player.setVolume(ref.read(volumeStateProvider));
        }

        var record = getPlaylist(ref, widget.url);
        ref.read(playlistProvider.notifier).update((state) => record.$1);
        ref.read(playingVideoProvider.notifier).update((state) => record.$2);

        final playlist = Playlist(
          record.$1,
          index: record.$2,
        );
        await player.open(playlist);
      },
    );
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: DeviceSizeService.device.size.width,
                child: StreamBuilder<Playlist>(
                  stream: player.stream.playlist,
                  builder: (context, snapshot) {
                    if (snapshot.data?.index != null) {
                      // auto load based on matching filename
                      ref.read(contentControllerProvider).autoLoadSubs(player, snapshot.data!.index);
                    }
                    return Video(
                      subtitleViewConfiguration: const SubtitleViewConfiguration(visible: false),
                      controller: controller,
                      controls: (state) {
                        return Stack(
                          children: [
                            ref.watch(onHoverDurationProvider) == null
                                ? const SizedBox()
                                : BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                                    child: Center(
                                      child: Text(
                                        ref.read(onHoverDurationProvider) ?? '',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                            BufferingWidget(player: player),
                            MobileVideoControlWidget(
                              player: player,
                              state: state,
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BufferingWidget extends StatelessWidget {
  const BufferingWidget({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: player.stream.buffering,
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return GestureDetector(
            onSecondaryTapDown: (event) => player.state.playing ? player.pause() : player.play(),
            child: Container(
              height: DeviceSizeService.device.size.height,
              width: DeviceSizeService.device.size.width,
              color: Colors.black26,
              child: Center(
                child: SizedBox(
                  height: DeviceSizeService.device.size.height * 0.1,
                  width: DeviceSizeService.device.size.height * 0.1,
                  child: const CircularProgressIndicator(
                    color: Colors.red,
                  ),
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}

class MobileEndDrawerWidget extends ConsumerStatefulWidget {
  const MobileEndDrawerWidget({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  ConsumerState<MobileEndDrawerWidget> createState() => _MobileEndDrawerWidgetState();
}

class _MobileEndDrawerWidgetState extends ConsumerState<MobileEndDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Container(
          width: 300,
          color: CupertinoColors.systemGrey6.withOpacity(0.6),
          child: Column(
            children: [
              TabBar(
                tabs: <Widget>[
                  Tab(
                    child: const Text(
                      "Playlist",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ).pt(10),
                  ),
                  Tab(
                    child: const Text(
                      "Settings",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ).pt(10),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    PlaylistTab(widget.player),
                    SettingTab(widget.player),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistTab extends ConsumerStatefulWidget {
  final Player player;
  const PlaylistTab(this.player, {super.key});

  @override
  ConsumerState<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends ConsumerState<PlaylistTab> {
  int? selectedIndex;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: ref.read(playlistProvider).length,
        itemBuilder: (BuildContext context, int index) {
          Media media = ref.read(playlistProvider)[index];
          bool playing = index == ref.read(playingVideoProvider);
          return GestureDetector(
            onDoubleTap: () async {
              await widget.player.jump(index).then((_) {
                ref.read(playingVideoProvider.notifier).update((state) => index);
                setState(() {});
              });
            },
            child: Listener(
              onPointerDown: (_) {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                color: selectedIndex == index ? const Color.fromARGB(255, 55, 84, 237) : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.arrow_right,
                        size: 26,
                        color: playing
                            ? selectedIndex == index
                                ? Colors.white
                                : Colors.black
                            : Colors.transparent,
                      ),
                      Expanded(
                        child: ExtendedText(
                          Uri.decodeComponent(media.uri),
                          maxLines: 1,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontSize: 13,
                                color: selectedIndex == index ? Colors.white : Colors.black,
                              ),
                          overflowWidget: TextOverflowWidget(
                            position: TextOverflowPosition.start,
                            child: Text(
                              "...",
                              style: TextStyle(
                                color: selectedIndex == index ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ).pr(20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}

class SettingTab extends ConsumerStatefulWidget {
  final Player player;
  const SettingTab(this.player, {super.key});

  @override
  ConsumerState<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends ConsumerState<SettingTab> {
  List<SubtitleTrack> subtitles = [];
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    subtitles.isNotEmpty ? subtitles.clear() : null;
    subtitles.addAll(widget.player.state.tracks.subtitle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Subtitles",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ).pltrb(15, 15, 0, 0),
              Flexible(
                child: StreamBuilder<Tracks>(
                  stream: widget.player.stream.tracks,
                  builder: (context, snapshot) => SingleChildScrollView(
                    child: Column(
                      children: [
                        ...(snapshot.data?.subtitle ?? subtitles).asMap().entries.map(
                          (e) {
                            late SubtitleTrack subtitleTrack;
                            late bool loaded;
                            if (snapshot.data?.subtitle == null) {
                              subtitleTrack = subtitles[e.key];
                              if (widget.player.state.track.subtitle.title == null) {
                                loaded = e.value.id == widget.player.state.track.subtitle.id;
                              } else {
                                loaded = e.value.title == widget.player.state.track.subtitle.title;
                              }
                            } else {
                              subtitleTrack = widget.player.state.tracks.subtitle[e.key];
                              loaded = e.value.title == widget.player.state.track.subtitle.title;
                            }

                            return GestureDetector(
                              onDoubleTap: () async {
                                await widget.player.setSubtitleTrack(e.value);
                                setState(() {});
                              },
                              child: Listener(
                                onPointerDown: (_) => setState(() {
                                  selectedIndex = e.key;
                                }),
                                child: Container(
                                  color: selectedIndex == e.key ? const Color.fromARGB(255, 55, 84, 237) : Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.5),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.arrow_right,
                                          size: 26,
                                          color: loaded
                                              ? selectedIndex == e.key
                                                  ? Colors.white
                                                  : Colors.black
                                              : Colors.transparent,
                                        ),
                                        Expanded(
                                          child: Text(
                                            subtitleTrack.title ?? subtitleTrack.id,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontSize: 13,
                                                  color: selectedIndex == e.key ? Colors.white : Colors.black,
                                                ),
                                          ).pr(15).py(3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          "External Subtitles",
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ).pltrb(15, 15, 0, 10),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 217, 217, 217),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () => showOverlay(context, widget.player),
          child: Text(
            "Browse from this server",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ).btnRow(15),
        const SizedBox(
          height: 10,
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 217, 217, 217),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['srt', 'ass', 'sub', 'vtt', '.ssa'],
            );

            if (result != null) {
              File file = File(result.files.single.path!);
              await widget.player.setSubtitleTrack(
                SubtitleTrack.data(
                  file.readAsStringSync(),
                  title: file.path.split('/').last,
                ),
              );

              setState(() {});
            }
          },
          child: Text(
            "Browse from local file",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ).btnRow(15),
      ],
    );
  }
}

void showOverlay(BuildContext context, Player player) async {
  OverlayEntry? overlayEntry;

  final backdrop = Container(
    color: Colors.black.withOpacity(0.5),
  );

  overlayEntry = OverlayEntry(
    builder: (context) => BrowseFileOverlay(overlayEntry: overlayEntry, backdrop: backdrop, player: player),
  );

  Overlay.of(context).insert(overlayEntry);
}

class BrowseFileOverlay extends ConsumerStatefulWidget {
  final OverlayEntry? overlayEntry;
  final Widget backdrop;
  final Player player;
  const BrowseFileOverlay({required this.overlayEntry, required this.backdrop, required this.player, super.key});

  @override
  ConsumerState<BrowseFileOverlay> createState() => _BrowseFileOverlayState();
}

class _BrowseFileOverlayState extends ConsumerState<BrowseFileOverlay> {
  int selectedIndex = -1;
  OverlayEntry? loadingOverlayEntry;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.backdrop,
        Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: SizedBox(
              width: DeviceSizeService.device.size.width * 0.8,
              height: DeviceSizeService.device.size.height * 0.8,
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Browse subtitle from server',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ).pa(20),
                    Text(
                      "Path: ${Uri.decodeComponent(ref.watch(browsePathStateProvider))}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ).px(20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            ...ref.watch(pageContentStateProvider).folders.map(
                              (folder) {
                                return ListTile(
                                  onTap: () {
                                    loadingOverlayEntry = showLoadingOverlay(context);
                                    Overlay.of(context).insert(loadingOverlayEntry!);
                                    if (folder == '../') {
                                      Uri uri = ref.read(contentControllerProvider).handleReverse(browse: true);
                                      ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: uri.origin));
                                      ref.read(browsePathStateProvider.notifier).update((state) => "${uri.path}/");
                                    } else {
                                      ref.watch(browsePathStateProvider.notifier).update((state) => '$state$folder');
                                    }
                                    ref.read(contentControllerProvider).getPageContent(browse: true).then((value) {
                                      selectedIndex = -1;
                                      loadingOverlayEntry?.remove();
                                    }).catchError((err, st) {
                                      showToast(context, ToastType.error, err);
                                    });
                                  },
                                  title: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.folder,
                                        color: Color.fromARGB(255, 117, 117, 117),
                                      ).pltrb(10, 0, 5, 0),
                                      Expanded(
                                        child: Text(
                                          Uri.decodeComponent(folder),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ).px(5),
                                      ),
                                    ],
                                  ).py(8),
                                );
                              },
                            ),
                            ...ref.watch(othersContentStateProvider).asMap().entries.map(
                              (file) {
                                return ListTile(
                                  onTap: () async => setState(() {
                                    selectedIndex = file.key;
                                  }),
                                  splashColor: Colors.transparent,
                                  selectedTileColor: const Color.fromARGB(255, 58, 124, 238),
                                  selectedColor: Colors.white,
                                  leading: Icon(
                                    Icons.description,
                                    color: selectedIndex == file.key ? Colors.white : const Color.fromARGB(255, 117, 117, 117),
                                  ).pltrb(10, 0, 5, 0),
                                  selected: selectedIndex == file.key,
                                  title: Text(Uri.decodeComponent(file.value.filename)),
                                );
                              },
                            ),
                          ],
                        ),
                      ).pt(20),
                    ),
                    Card(
                      margin: EdgeInsets.zero,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          WebPrimaryButton(
                            "Load",
                            onPressed: selectedIndex == -1
                                ? null
                                : () async {
                                    List<String> subsExt = ['srt', 'ass', 'sub', 'vtt', 'ssa'];
                                    final file = ref.read(othersContentStateProvider)[selectedIndex];
                                    for (var ext in subsExt) {
                                      if (file.filename.contains(ext)) {
                                        loadingOverlayEntry = showLoadingOverlay(context);
                                        Overlay.of(context).insert(loadingOverlayEntry!);
                                        await ref.read(contentControllerProvider).loadExternalSubs(widget.player, file);
                                        loadingOverlayEntry?.remove();
                                        widget.overlayEntry?.remove();
                                        return;
                                      }
                                    }
                                    showToast(context, ToastType.error, 'File not supported', extent: true);
                                  },
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          WebSecondaryButton(
                            "Cancel",
                            onPressed: () => widget.overlayEntry?.remove(),
                          )
                        ],
                      ).pa(15),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

OverlayEntry showLoadingOverlay(BuildContext context) {
  return OverlayEntry(
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        backgroundColor: const Color.fromARGB(150, 0, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LoadingView(35).py(8.0),
            const Text(
              'Loading',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 15.0),
            ),
          ],
        ).py(12),
      );
    },
  );
}

String durationToStringWithoutMilliseconds(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));

  if (hours == '00') {
    return '$minutes:$seconds';
  }
  return '$hours:$minutes:$seconds';
}

(List<Media>, int) getPlaylist(WidgetRef ref, String url) {
  String playlistPrefix = ref.read(baseURLStateProvider);
  List<Media> playlist = [];
  int index = 0;
  for (var i = 0; i < ref.read(videosContentStateProvider).length; i++) {
    final videoInPlaylistUrl = ref.read(videosContentStateProvider)[i].filename;
    if (url == videoInPlaylistUrl) {
      index = i;
    }
    playlist.add(
      Media(
        ref.read(contentControllerProvider).getUrl(playlistPrefix + videoInPlaylistUrl),
      ),
    );
  }
  return (playlist, index);
}
