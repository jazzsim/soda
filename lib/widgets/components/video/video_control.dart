import 'dart:async';
import 'dart:ui';

import 'package:anydrawer/anydrawer.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/main.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/pages/home_page.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/extensions/padding.dart';
import 'package:window_manager/window_manager.dart';

final videoTimerProvider = StateProvider<Timer?>((ref) => null);

final showVolumeProvider = StateProvider<bool>((ref) => false);

final showVideoControlProvider = StateProvider<bool>((ref) => false);

final timerProvider = StateProvider<Timer?>((ref) => null);

final durationProvider = StateProvider<Duration>((ref) => const Duration(milliseconds: 450));

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
  bool? cursorInWindow = false;

  Future<void> _getCursor({bool callTimer = true}) async {
    try {
      final result = await MyApp.platform.invokeMethod<bool>('cursorInsideWindow');
      cursorInWindow = result;
      if (cursorInWindow ?? false) {
        showControls(ref, callTimer);
      }
    } on PlatformException {
      cursorInWindow = null;
    }

    // setState(() {});
  }

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
          onFocusChange: (value) async {
            // trigger to hide controls when video enter&exit fullscreen
            if (value) {
              await Future.delayed(const Duration(milliseconds: 1000));
              _getCursor();
            }
          },
          child: Stack(
            children: [
              MouseRegion(
                cursor: ref.watch(showVideoControlProvider) ? MouseCursor.defer : SystemMouseCursors.none,
                onExit: (event) => _getCursor(callTimer: false),
                child: Listener(
                  onPointerDown: (event) => windowManager.startDragging(),
                  onPointerSignal: (pointerSignal) async {
                    if (pointerSignal is PointerScrollEvent) {
                      double currentVolume = ref.read(volumeStateProvider);
                      if (pointerSignal.scrollDelta.dy < 0) {
                        if (currentVolume + 2.0 > 100) {
                          ref.read(volumeStateProvider.notifier).update((state) => 100);
                          ref.read(contentControllerProvider).startCancelTimer();
                        } else {
                          ref.read(volumeStateProvider.notifier).update((state) => currentVolume + 2.0);
                        }
                      } else {
                        if (currentVolume - 2.0 < 0) {
                          ref.read(volumeStateProvider.notifier).update((state) => 0);
                          ref.read(contentControllerProvider).startCancelTimer();
                        } else {
                          ref.read(volumeStateProvider.notifier).update((state) => currentVolume - 2.0);
                        }
                      }
                      await widget.player.setVolume(ref.read(volumeStateProvider));
                    }

                    ref.read(showVolumeProvider.notifier).update((state) => true);
                  },
                  onPointerHover: (event) => _getCursor(),
                  child: GestureDetector(
                    onDoubleTap: () => widget.state.toggleFullscreen(),
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
                  child: MouseRegion(
                    onHover: (event) => _getCursor(callTimer: false),
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
  @override
  Widget build(BuildContext context) {
    ref.listen(volumeStateProvider, (previous, next) {
      ref.read(contentControllerProvider).startCancelTimer();
    });
    return AnimatedOpacity(
      opacity: ref.watch(showVolumeProvider) ? 1 : 0,
      curve: Curves.decelerate,
      duration: const Duration(
        milliseconds: 180,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: 140,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: CupertinoColors.systemGrey6.withOpacity(0.6),
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
    double controlsOverlaySize = MediaQuery.sizeOf(context).width / 6;

    return StreamBuilder<Duration>(
      stream: player.stream.position,
      builder: (context, snapshot) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              constraints: const BoxConstraints(minWidth: 380),
              width: controlsOverlaySize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: CupertinoColors.systemGrey6.withOpacity(0.6),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 3, 10, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(minWidth: 380),
                      width: controlsOverlaySize,
                      height: 68,
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
                              icon: StreamBuilder<bool>(
                                stream: player.stream.playing,
                                builder: (context, snapshot) => Icon(
                                  snapshot.data == true ? Icons.pause : Icons.play_arrow,
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
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                showDrawer(
                                  context,
                                  builder: (context) => EndDrawerWidget(player: player),
                                  onClose: () => showControls(ref, true),
                                  config: const DrawerConfig(
                                    widthPercentage: 0.22,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 35,
                                  width: 55,
                                  child: Center(
                                    child: Text(
                                      durationToStringWithoutMilliseconds(player.state.position),
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => ref.read(alterVideoDurationStateProvider.notifier).update((state) => !state),
                                  child: SizedBox(
                                    height: 35,
                                    width: 55,
                                    child: Center(
                                      child: Text(
                                        ref.watch(alterVideoDurationStateProvider)
                                            ? "-${durationToStringWithoutMilliseconds(player.state.duration - player.state.position)}"
                                            : durationToStringWithoutMilliseconds(player.state.duration),
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              fontWeight: FontWeight.w400,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
        ref.read(volumeStateProvider.notifier).update((state) => 100);
        ref.read(contentControllerProvider).startCancelTimer();
      } else {
        ref.read(volumeStateProvider.notifier).update((state) => currentVolume + 5.0);
      }
      await player.setVolume(ref.read(volumeStateProvider));
      ref.read(showVolumeProvider.notifier).update((state) => true);
    },
    const SingleActivator(LogicalKeyboardKey.arrowDown): () async {
      double currentVolume = player.state.volume;
      if (currentVolume - 5.0 < 0) {
        ref.read(volumeStateProvider.notifier).update((state) => 0);
        ref.read(contentControllerProvider).startCancelTimer();
      } else {
        ref.read(volumeStateProvider.notifier).update((state) => currentVolume - 5.0);
      }
      await player.setVolume(ref.read(volumeStateProvider));
      ref.read(showVolumeProvider.notifier).update((state) => true);
    },
    const SingleActivator(LogicalKeyboardKey.keyF): () async {
      state.toggleFullscreen();
    },
    const SingleActivator(LogicalKeyboardKey.keyN): () async {
      await player.next();
      ref.read(playingVideoProvider.notifier).update((state) => state += 1);
    },
    LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyS): () async {
      final Uint8List? screenshot = await player.screenshot();

      String formatDate() => DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());

      FileSaver.instance.saveFile(
        name: 'screenshot_${formatDate()}.png',
        bytes: screenshot,
        mimeType: MimeType.png,
      );
    }
  };
}

void showControls(WidgetRef ref, bool callTimer) {
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
