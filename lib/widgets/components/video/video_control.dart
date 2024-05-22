import 'dart:async';

import 'package:anydrawer/anydrawer.dart';
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

final endDrawerWidthProvider = StateProvider<bool>((ref) => false);

final endDrawerVisibilityProvider = StateProvider<bool>((ref) => false);

class VideoControlWidget extends ConsumerStatefulWidget {
  final Player player;
  final VideoState state;
  const VideoControlWidget({required this.player, required this.state, super.key});

  @override
  ConsumerState<VideoControlWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends ConsumerState<VideoControlWidget> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(timerProvider.notifier).state = Timer.periodic(ref.read(durationProvider), (Timer timer) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (_) {
        ref.read(timerProvider)?.cancel();
        ref.read(videoTimerProvider)?.cancel();
      },
      child: CallbackShortcuts(
        bindings: getShortcuts(widget.state, context, ref, widget.player),
        child: FocusScope(
          autofocus: true,
          child: Stack(
            children: [
              MouseRegion(
                cursor: ref.watch(showVideoControlProvider) ? MouseCursor.defer : SystemMouseCursors.none,
                onEnter: (event) => setState(
                  () {
                    ref.read(timerProvider)?.cancel();
                    ref.read(showVideoControlProvider.notifier).update((state) => true);
                  },
                ),
                onExit: (event) => setState(
                  () {
                    ref.read(timerProvider)?.cancel();
                    ref.read(showVideoControlProvider.notifier).update((state) => true);
                  },
                ),
                child: Listener(
                  onPointerDown: (event) {
                    windowManager.startDragging();
                  },
                  onPointerSignal: (pointerSignal) async {
                    if (pointerSignal is PointerScrollEvent) {
                      double currentVolume = ref.read(volumeStateProvider);
                      if (pointerSignal.scrollDelta.dy < 0) {
                        if (currentVolume + 2.0 > 100) {
                          ref.read(volumeStateProvider.notifier).update((state) => 100);
                        } else {
                          ref.read(volumeStateProvider.notifier).update((state) => currentVolume + 2.0);
                        }
                      } else {
                        if (currentVolume - 2.0 < 0) {
                          ref.read(volumeStateProvider.notifier).update((state) => 0);
                        } else {
                          ref.read(volumeStateProvider.notifier).update((state) => currentVolume - 2.0);
                        }
                      }
                      await widget.player.setVolume(ref.read(volumeStateProvider));
                    }

                    ref.read(showVolumeProvider.notifier).update((state) => true);
                  },
                  onPointerHover: (event) {
                    ref.read(showVideoControlProvider.notifier).update((state) => true);
                    setState(() {});
                    ref.read(timerProvider)?.cancel();
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
                    child: Container(
                      color: Colors.transparent,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 85,
                left: 30,
                child: VolumeOverlay(
                  player: widget.player,
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
              Positioned(
                bottom: (MediaQuery.sizeOf(context).height - 100) * (ref.watch(subtitlePositionStateProvider) ?? 0),
                left: 0,
                right: 0,
                child: StreamBuilder<List<String>>(
                    stream: widget.player.stream.subtitle,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        for (String element in snapshot.data ?? []) {
                          return SubtitleWidget(subtitle: element).py(40);
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
                  child: _ControlsOverlay(
                    videoPlayerSize: widget.player.state.width?.toDouble() ?? 0,
                    player: widget.player,
                  ),
                ).pb(20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VolumeOverlay extends ConsumerStatefulWidget {
  final Player player;
  const VolumeOverlay({required this.player, super.key});

  @override
  ConsumerState<VolumeOverlay> createState() => _VolumeOverlayState();
}

class _VolumeOverlayState extends ConsumerState<VolumeOverlay> {
  final Duration _volumeDuration = const Duration(milliseconds: 1200);

  @override
  Widget build(BuildContext context) {
    ref.listen(volumeStateProvider, (previous, next) {
      ref.read(videoTimerProvider)?.cancel();
      ref.read(videoTimerProvider.notifier).state = Timer(_volumeDuration, () {
        ref.read(showVolumeProvider.notifier).update((state) => false);
        setState(() {});
      });
    });
    return AnimatedOpacity(
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
    );
  }
}

class SubtitleWidget extends ConsumerWidget {
  final String subtitle;

  const SubtitleWidget({
    super.key,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ref.watch(subtitleScaleStateProvider) * 100,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 8
              ..color = Colors.black,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: ref.watch(subtitleScaleStateProvider) * 100,
            color: Colors.yellow,
          ),
        ),
      ],
    );
  }
}

class _ControlsOverlay extends ConsumerWidget {
  final Player player;
  final double videoPlayerSize;

  const _ControlsOverlay({required this.player, required this.videoPlayerSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: controlsOverlaySize,
                  height: 70,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
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
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onPressed: () async {
                            showDrawer(
                              context,
                              builder: (context) => EndDrawerWidget(player: player),
                              config: const DrawerConfig(
                                widthPercentage: 0.15,
                                maxDragExtent: 120,
                                closeOnClickOutside: true,
                                closeOnEscapeKey: true,
                                backdropOpacity: 0.5,
                                borderRadius: 0,
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.playlist_play_rounded,
                            size: 20,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                durationToStringWithoutMilliseconds(player.state.position),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                              const Spacer(),
                              Text(
                                durationToStringWithoutMilliseconds(player.state.duration),
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontWeight: FontWeight.w400,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ProgressBar(player: player),
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
        player.state.position - const Duration(seconds: 4),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowRight): () async {
      await player.seek(
        player.state.position + const Duration(seconds: 4),
      );
    },
    const SingleActivator(LogicalKeyboardKey.arrowUp): () async {
      double currentVolume = player.state.volume;
      if (currentVolume + 5.0 > 100) {
        await player.setVolume(100);
      } else {
        await player.setVolume(currentVolume + 5.0).then((value) {});
      }
      ref.read(volumeStateProvider.notifier).update((state) => currentVolume + 5.0);
      ref.read(showVolumeProvider.notifier).update((state) => true);
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () async {
      double currentVolume = player.state.volume;
      if (currentVolume - 5.0 < 0) {
        await player.setVolume(0);
      } else {
        await player.setVolume(currentVolume - 5.0);
      }
      ref.read(volumeStateProvider.notifier).update((state) => currentVolume - 5.0);
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

void showVideo(WidgetRef ref, {bool callTimer = true}) {
  ref.read(showVideoControlProvider.notifier).update((state) => true);
  ref.watch(timerProvider)?.cancel();

  if (callTimer == true) {
    ref.read(timerProvider.notifier).update(
          (state) => Timer(
            ref.read(durationProvider),
            () {
              ref.read(showVideoControlProvider.notifier).update((state) => false);
            },
          ),
        );
  }
}
