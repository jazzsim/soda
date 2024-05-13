import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/extensions/padding.dart';
import 'package:window_manager/window_manager.dart';

final videoTimerProvider = StateProvider<Timer?>((ref) => null);

final showVolumeProvider = StateProvider<bool>((ref) => false);

final showVideoControlProvider = StateProvider<bool>((ref) => false);

final timerProvider = StateProvider<Timer?>((ref) => null);

final durationProvider = StateProvider<Duration>((ref) => const Duration(milliseconds: 850));

class VideoControlWidget extends ConsumerStatefulWidget {
  final Player player;
  final VideoState state;
  const VideoControlWidget({required this.player, required this.state, super.key});

  @override
  ConsumerState<VideoControlWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends ConsumerState<VideoControlWidget> {
  final Duration _volumeDuration = const Duration(milliseconds: 1200); // Set the duration for pointer

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(timerProvider.notifier).state = Timer.periodic(ref.read(durationProvider), (Timer timer) {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        ref.read(timerProvider)?.cancel();
        ref.read(videoTimerProvider)?.cancel();
      },
      child: Listener(
        onPointerDown: (event) {
          windowManager.startDragging();
        },
        onPointerSignal: (pointerSignal) {
          if (pointerSignal is PointerScrollEvent) {
            // do something when scrolled
            double currentVolume = widget.player.state.volume;
            if (pointerSignal.scrollDelta.dy < 0) {
              if (currentVolume + 2.0 > 100) {
                widget.player.setVolume(100);
              } else {
                widget.player.setVolume(currentVolume + 2.0);
              }
            } else {
              if (currentVolume - 2.0 < 0) {
                widget.player.setVolume(0);
              } else {
                widget.player.setVolume(currentVolume - 2.0);
              }
            }
            ref.read(volumeStateProvider.notifier).update((state) => widget.player.state.volume);
            ref.read(showVolumeProvider.notifier).update((state) => true);
          }
        },
        onPointerHover: (event) {
          ref.read(showVideoControlProvider.notifier).update((state) => true);
          setState(() {});
          ref.watch(timerProvider)?.cancel();
          ref.read(timerProvider.notifier).update(
                (state) => Timer(
                  ref.read(durationProvider),
                  () {
                    ref.read(showVideoControlProvider.notifier).update((state) => false);
                    setState(() {});
                  },
                ),
              );
        },
        child: GestureDetector(
          onDoubleTap: () {
            widget.state.toggleFullscreen();
          },
          onSecondaryTapDown: (event) => widget.player.state.playing ? widget.player.pause() : widget.player.play(),
          child: CallbackShortcuts(
            bindings: getShortcuts(widget.state, context, ref, widget.player),
            child: Container(
              color: Colors.transparent,
              child: Stack(
                children: [
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
                                value: widget.player.state.volume / 100,
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
                      opacity: ref.watch(showVideoControlProvider) ? 1 : 0,
                      curve: Curves.decelerate,
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      child: MouseRegion(
                        onEnter: (event) => setState(
                          () {
                            ref.read(timerProvider)?.cancel();
                            ref.read(showVideoControlProvider.notifier).update((state) => true);
                          },
                        ),
                        child: IconButton(
                          onPressed: () async {
                            if (widget.state.isFullscreen()) {
                              await widget.state.toggleFullscreen();
                            }
                            if (!context.mounted) return;
                            Navigator.of(context).pop();
                          },
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
                    child: StreamBuilder<List<String>>(
                        stream: widget.player.stream.subtitle,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            for (var element in snapshot.data ?? []) {
                              return Stack(
                                children: [
                                  // Text(
                                  //   element,
                                  //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  //         // fontWeight: FontWeight.bold,
                                  //         fontSize: 34,
                                  //       ),
                                  // ),
                                  Text(
                                    element,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Colors.yellow,
                                          fontSize: 34,
                                        ),
                                  ),
                                ],
                              );
                            }
                          }
                          return Container();
                        }),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      opacity: ref.watch(showVideoControlProvider) ? 1 : 0,
                      curve: Curves.decelerate,
                      duration: const Duration(
                        milliseconds: 180,
                      ),
                      child: MouseRegion(
                        onEnter: (event) => setState(
                          () {
                            ref.read(timerProvider)?.cancel();
                            ref.read(showVideoControlProvider.notifier).update((state) => true);
                          },
                        ),
                        child: _ControlsOverlay(
                          videoPlayerSize: widget.player.state.width?.toDouble() ?? 0,
                          player: widget.player,
                        ),
                      ),
                    ).pb(20),
                  ),
                ],
              ),
            ),
          ),
        ),
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
