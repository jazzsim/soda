import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:extended_text/extended_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/widgets/extensions/padding.dart';
import 'package:window_manager/window_manager.dart';
import 'package:window_size/window_size.dart';

final offSetStateProvider = StateProvider<double>((ref) => 0);

final showVolumeProvider = StateProvider<bool>((ref) => false);

final playlistProvider = StateProvider<List<Media>>((ref) => []);

final playingVideoProvider = StateProvider<int>((ref) => 0);

final videoTimerProvider = StateProvider<Timer?>((ref) => null);

class MainVideoPlayer extends ConsumerStatefulWidget {
  final String url;
  const MainVideoPlayer(this.url, {super.key});

  @override
  ConsumerState<MainVideoPlayer> createState() => _MainVideoPlayerState();
}

class _MainVideoPlayerState extends ConsumerState<MainVideoPlayer> {
  bool showVideoControl = false;
  Timer? _timer;
  final Duration _duration = const Duration(milliseconds: 850); // Set the duration for pointer stop
  final Duration _volumeDuration = const Duration(milliseconds: 1200); // Set the duration for pointer stop

  late final videoPlayerHeight = (MediaQuery.of(context).size.height) / 2, videoPlayerWidth = (MediaQuery.of(context).size.width) / 2;
  late final player = Player();
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

    _timer = Timer.periodic(_duration, (Timer timer) {});
  }

  @override
  void dispose() {
    player.stop();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        displaySeekBar: false,
        bottomButtonBar: [],
        modifyVolumeOnScroll: false,
        bufferingIndicatorBuilder: (context) => Container(),
        keyboardShortcuts: {},
      ),
      fullscreen: MaterialDesktopVideoControlsThemeData(
        displaySeekBar: false,
        bottomButtonBar: [],
        bufferingIndicatorBuilder: (context) => Container(),
        keyboardShortcuts: {},
      ),
      child: Scaffold(
        endDrawer: EndDrawerWidget(player: player),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Listener(
                        onPointerDown: (event) {
                          windowManager.startDragging();
                        },
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            // do something when scrolled
                            double currentVolume = player.state.volume;
                            if (pointerSignal.scrollDelta.dy < 0) {
                              if (currentVolume + 2.0 > 100) {
                                player.setVolume(100);
                              } else {
                                player.setVolume(currentVolume + 2.0);
                              }
                            } else {
                              if (currentVolume - 2.0 < 0) {
                                player.setVolume(0);
                              } else {
                                player.setVolume(currentVolume - 2.0);
                              }
                            }
                            ref.read(volumeStateProvider.notifier).update((state) => player.state.volume);
                            ref.read(showVolumeProvider.notifier).update((state) => true);
                          }
                        },
                        onPointerHover: (event) {
                          showVideoControl = true;
                          setState(() {});
                          _timer?.cancel();
                          _timer = Timer(_duration, () {
                            showVideoControl = false;
                            setState(() {});
                          });
                        },
                        // loading view
                        child: Stack(
                          children: [
                            Video(
                              controller: controller,
                              controls: (state) {
                                return GestureDetector(
                                  onDoubleTap: () {
                                    state.toggleFullscreen();
                                  },
                                  onSecondaryTapDown: (event) => player.state.playing ? player.pause() : player.play(),
                                  child: CallbackShortcuts(
                                    bindings: getShortcuts(state, context, ref, player),
                                    child: MaterialDesktopVideoControls(state),
                                  ),
                                );
                              },
                            ),
                            StreamBuilder(
                              stream: player.stream.buffering,
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return GestureDetector(
                                    onSecondaryTapDown: (event) => player.state.playing ? player.pause() : player.play(),
                                    child: Stack(
                                      children: [
                                        Container(
                                          color: Colors.black26,
                                        ),
                                        Positioned(
                                          top: videoPlayerHeight - 50,
                                          left: videoPlayerWidth - 50,
                                          child: const SizedBox(
                                            height: 80,
                                            width: 80,
                                            child: CircularProgressIndicator(
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return Container();
                              },
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 85,
                        left: 30,
                        child: AnimatedOpacity(
                          onEnd: () {
                            ref.read(videoTimerProvider)?.cancel();
                            ref.read(videoTimerProvider.notifier).state = Timer(_volumeDuration, () {
                              ref.read(showVolumeProvider.notifier).update((state) => false);
                              setState(() {});
                            });
                          },
                          opacity: ref.watch(showVolumeProvider) ? 1 : 0,
                          curve: Curves.decelerate,
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          child: Container(
                            width: 140,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                12,
                              ),
                              color: const Color.fromARGB(237, 238, 238, 238),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Volume: ${ref.watch(volumeStateProvider).floorToDouble().round()}",
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                                ),
                                SizedBox(
                                  width: 115,
                                  child: LinearProgressIndicator(
                                    value: player.state.volume / 100,
                                    color: Colors.blue,
                                  ).pt(5),
                                ),
                              ],
                            ).pltrb(12, 8, 12, 12),
                          ),
                        ),
                      ),
                      Positioned(
                        top: ref.read(titleBarHeight).toDouble(),
                        left: 10,
                        child: AnimatedOpacity(
                          opacity: showVideoControl ? 1 : 0,
                          curve: Curves.decelerate,
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          child: MouseRegion(
                            onEnter: (event) => setState(
                              () {
                                _timer?.cancel();
                                showVideoControl = true;
                              },
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 38,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        child: AnimatedOpacity(
                          opacity: showVideoControl ? 1 : 0,
                          curve: Curves.decelerate,
                          duration: const Duration(
                            milliseconds: 180,
                          ),
                          child: MouseRegion(
                            onEnter: (event) => setState(
                              () {
                                _timer?.cancel();
                                showVideoControl = true;
                              },
                            ),
                            child: _ControlsOverlay(
                              videoPlayerSize: player.state.width?.toDouble() ?? 0,
                              player: player,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EndDrawerWidget extends ConsumerStatefulWidget {
  const EndDrawerWidget({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  ConsumerState<EndDrawerWidget> createState() => _EndDrawerWidgetState();
}

class _EndDrawerWidgetState extends ConsumerState<EndDrawerWidget> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Container(
        width: 300,
        color: const Color.fromARGB(232, 237, 237, 237),
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
            // const Divider(),
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
  late ScrollController scrollController;
  int? selectedIndex;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: ref.read(offSetStateProvider),
      keepScrollOffset: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      scrollController.position.isScrollingNotifier.addListener(() {
        if (!scrollController.position.isScrollingNotifier.value) {
          ref.read(offSetStateProvider.notifier).update((state) => scrollController.offset);
        }
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          ...ref.read(playlistProvider).asMap().entries.map(
            (e) {
              Media media = ref.read(playlistProvider)[e.key];
              bool playing = e.key == ref.read(playingVideoProvider);
              return GestureDetector(
                onDoubleTap: () async {
                  await widget.player.jump(e.key).then((_) {
                    ref.read(playingVideoProvider.notifier).update((state) => e.key);
                    Navigator.of(context).pop();
                  });
                },
                child: Listener(
                  onPointerDown: (_) {
                    setState(() {
                      selectedIndex = e.key;
                    });
                  },
                  child: Container(
                    color: selectedIndex == e.key ? const Color.fromARGB(255, 16, 99, 240) : Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.arrow_right,
                            size: 26,
                            color: playing
                                ? selectedIndex == e.key
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
                                    color: selectedIndex == e.key ? Colors.white : Colors.black,
                                  ),
                              overflowWidget: TextOverflowWidget(
                                position: TextOverflowPosition.start,
                                child: Text(
                                  "...",
                                  style: TextStyle(
                                    color: selectedIndex == e.key ? Colors.white : Colors.black,
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
            },
          ),
        ],
      ),
    );
  }
}

class SettingTab extends StatefulWidget {
  final Player player;
  const SettingTab(this.player, {super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  late final List<SubtitleTrack> subtitles;

  @override
  void initState() {
    super.initState();
    subtitles = widget.player.state.tracks.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          12,
        ),
      ),
      child: Column(
        children: [
          Text(
            "Subtitles",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                ...subtitles.map(
                  (e) => Text(
                    "${e}",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsOverlay extends StatelessWidget {
  final Player player;
  final double videoPlayerSize;

  const _ControlsOverlay({required this.player, required this.videoPlayerSize});

  @override
  Widget build(BuildContext context) {
    const double controlsOverlaySize = 400;

    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (context, snapshot) {
        return Container(
          width: controlsOverlaySize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromARGB(240, 243, 243, 243),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 11),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: controlsOverlaySize,
                  height: 40,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () => player.state.playing ? player.pause() : player.play(),
                            alignment: Alignment.center,
                            iconSize: 42,
                            padding: EdgeInsets.zero,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            icon: Icon(
                              player.state.playing ? Icons.pause : Icons.play_arrow,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 13,
                        left: 0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.volume_up,
                                size: 20,
                              ),
                            ),
                            SizedBox(
                              width: 55,
                              child: VolumeSlider(
                                player: player,
                              ),
                            )
                          ],
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          onPressed: () {
                            // open end drawer
                            Scaffold.of(context).openEndDrawer();
                          },
                          icon: const Icon(
                            Icons.playlist_play_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Row(
                    children: [
                      Text(
                        durationToStringWithoutMilliseconds(player.state.position),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15, right: 15, bottom: 0),
                          child: ProgressBar(player: player),
                        ),
                      ),
                      Text(
                        durationToStringWithoutMilliseconds(player.state.duration),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w400,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 5,
        activeTrackColor: Colors.black38,
        inactiveTrackColor: Colors.grey[300],
        thumbShape: const EmptySliderThumb(),
        overlayColor: Colors.transparent,
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
      ),
      child: SizedBox(
        height: 20,
        child: Slider(
          min: 0.0,
          max: player.state.duration.inSeconds.toDouble(),
          value: player.state.position.inSeconds.toDouble(),
          onChangeEnd: (seekTo) async {
            await player.seek(
              Duration(
                seconds: seekTo.toInt(),
              ),
            );
          },
          onChanged: (_) {},
        ),
      ),
    );
  }
}

String durationToStringWithoutMilliseconds(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String hours = twoDigits(duration.inHours);
  String minutes = twoDigits(duration.inMinutes.remainder(60));
  String seconds = twoDigits(duration.inSeconds.remainder(60));

  return '$hours:$minutes:$seconds';
}

class VolumeSlider extends ConsumerStatefulWidget {
  final Player player;

  const VolumeSlider({required this.player, super.key});

  @override
  ConsumerState<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends ConsumerState<VolumeSlider> {
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
      ),
      child: SizedBox(
        height: 20,
        child: Slider(
          max: 100,
          value: ref.watch(volumeStateProvider) ?? widget.player.state.volume,
          onChanged: (value) => setState(() {
            widget.player.setVolume(value);
            ref.read(volumeStateProvider.notifier).update((state) => value);
            ref.read(showVolumeProvider.notifier).update((state) => true);
            setState(() {});
          }),
          activeColor: const Color.fromARGB(255, 96, 154, 254),
          inactiveColor: const Color.fromARGB(228, 222, 222, 222),
        ),
      ),
    );
  }
}

class EmptySliderThumb extends SliderComponentShape {
  const EmptySliderThumb();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    double thumbRadius = 0;
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

Map<ShortcutActivator, VoidCallback> getShortcuts(VideoState state, BuildContext context, WidgetRef ref, Player player) {
  return {
    const SingleActivator(LogicalKeyboardKey.space): () async {
      await player.playOrPause();
    },
    const SingleActivator(LogicalKeyboardKey.arrowLeft): () async {
      await player.seek(
        player.state.position - const Duration(seconds: 2),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () async {
      await player.seek(
        player.state.position + const Duration(seconds: 2),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () async {
      double currentVolume = player.state.volume;
      if (currentVolume + 2.0 > 100) {
        await player.setVolume(100);
      } else {
        await player.setVolume(currentVolume + 2.0).then((value) {});
      }
      ref.read(volumeStateProvider.notifier).update((state) => currentVolume + 2.0);
      ref.read(showVolumeProvider.notifier).update((state) => true);
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () async {
      double currentVolume = player.state.volume;
      if (currentVolume - 2.0 < 0) {
        await player.setVolume(0);
      } else {
        await player.setVolume(currentVolume - 2.0);
      }
      ref.read(volumeStateProvider.notifier).update((state) => currentVolume - 2.0);
      ref.read(showVolumeProvider.notifier).update((state) => true);
    },
    const SingleActivator(LogicalKeyboardKey.keyF): () async {
      state.toggleFullscreen();
    },
    const SingleActivator(LogicalKeyboardKey.keyN): () async {
      await player.next();
    }
  };
}

(List<Media>, int) getPlaylist(WidgetRef ref, String url) {
  String basicAuth = 'Basic ${base64.encode(utf8.encode('${ref.read(httpServerStateProvider).username}:${ref.read(httpServerStateProvider).password}'))}';
  String playlistPrefix = ref.read(httpServerStateProvider).url + ref.read(pathStateProvider);
  List<Media> playlist = [];
  int index = 0;
  for (var i = 0; i < ref.read(videosContentStateProvider).length; i++) {
    if (url == ref.read(videosContentStateProvider)[i].filename) {
      index = i;
    }
    playlist.add(
      Media(
        playlistPrefix + ref.read(videosContentStateProvider)[i].filename,
        httpHeaders: {
          "authorization": basicAuth,
        },
      ),
    );
  }
  return (playlist, index);
}
