import 'dart:async';
import 'dart:ui';

import 'package:anydrawer/anydrawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/services/device_size.dart';
import 'package:soda/widgets/components/video/video_player.m.dart';
import 'package:soda/widgets/extensions/padding.dart';

final showVideoControlProvider = StateProvider<bool>((ref) => false);

final timerProvider = StateProvider<Timer?>((ref) => null);

final durationProvider = StateProvider<Duration>((ref) => const Duration(milliseconds: 1450));

final endDrawerWidthProvider = StateProvider<bool>((ref) => false);

final endDrawerVisibilityProvider = StateProvider<bool>((ref) => false);

class MobileVideoControlWidget extends ConsumerStatefulWidget {
  final Player player;
  final VideoState state;
  const MobileVideoControlWidget({required this.player, required this.state, super.key});

  @override
  ConsumerState<MobileVideoControlWidget> createState() => _MobileVideoControlWidgetState();
}

class _MobileVideoControlWidgetState extends ConsumerState<MobileVideoControlWidget> {
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
      },
      child: FocusScope(
        autofocus: true,
        onFocusChange: (value) async {
          // trigger to hide controls when video enter&exit fullscreen
          if (value) {
            await Future.delayed(const Duration(milliseconds: 1000));
            showControls(ref, callTimer: true);
          }
        },
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                if (ref.watch(showVideoControlProvider) == false) {
                  showControls(ref, callTimer: true);
                }
              },
              onDoubleTap: () => widget.state.toggleFullscreen(),
              child: Container(
                color: Colors.transparent,
                width: DeviceSizeService.device.size.width,
                height: DeviceSizeService.device.size.height,
              ),
            ),
            Positioned(
              top: ref.read(titleBarHeight).toDouble() + 10,
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
                    size: 28,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: DeviceSizeService.device.isHorizontal() ? DeviceSizeService.device.height - 430 : DeviceSizeService.device.height - 630,
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
            // Positioned(
            //   bottom: (DeviceSizeService.device.height - 100) + 0,
            //   left: 0,
            //   right: 0,
            //   child: StreamBuilder<List<String>>(
            //       stream: widget.player.stream.subtitle,
            //       builder: (context, snapshot) {
            //         if (snapshot.hasData) {
            //           for (String element in snapshot.data ?? []) {
            //             return SubtitleWidget(subtitle: element).py(40);
            //           }
            //         }
            //         return Container();
            //       }),
            // ),
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedOpacity(
                opacity: ref.watch(showVideoControlProvider) ? 1 : 0,
                curve: Curves.decelerate,
                duration: const Duration(
                  milliseconds: 180,
                ),
                child: GestureDetector(
                  onTap: () {
                    if (ref.watch(showVideoControlProvider) == false) {
                      showControls(ref, callTimer: true);
                    } else {
                      null;
                    }
                  },
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
            fontSize: 0.2 * 100,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 4
              ..color = Colors.black,
          ),
        ),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 0.2 * 100,
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
    double controlsOverlaySize = DeviceSizeService.device.width / 6;

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
                      height: 76,
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: IconButton(
                              onPressed: () {
                                if (ref.read(showVideoControlProvider) == false) {
                                  showControls(ref, callTimer: true);
                                  return;
                                }
                                if (player.state.playing) {
                                  showControls(ref);
                                } else {
                                  showControls(ref, callTimer: true);
                                }
                                player.state.playing ? player.pause() : player.play();
                              },
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
                            top: 0,
                            right: 0,
                            child: IconButton(
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onPressed: () {
                                showDrawer(
                                  context,
                                  builder: (context) => MobileEndDrawerWidget(player: player),
                                  onClose: () => showControls(
                                    ref,
                                  ),
                                  config: const DrawerConfig(
                                    widthPercentage: 0.75,
                                    closeOnClickOutside: true,
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
                                  height: 43,
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
                                    height: 43,
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

void showControls(WidgetRef ref, {bool callTimer = false}) {
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

class ProgressBar extends ConsumerStatefulWidget {
  const ProgressBar({
    super.key,
    required this.player,
  });

  final Player player;

  @override
  ConsumerState<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends ConsumerState<ProgressBar> {
  late double position, timeStampsDouble;
  Duration? timeStamps;
  bool onHover = false;

  @override
  Widget build(BuildContext context) {
    final playbackPosition = widget.player.state.position.inSeconds / widget.player.state.duration.inSeconds;

    return SizedBox(
      height: 42,
      child: Stack(
        children: [
          Align(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onPanUpdate: (details) {
                    if (ref.read(showVideoControlProvider) == false) {
                      showControls(ref, callTimer: true);
                      return;
                    }
                    showControls(ref);
                    onHover = true;
                    position = details.localPosition.dx / constraints.maxWidth;
                    timeStampsDouble = position * widget.player.state.duration.inSeconds;
                    timeStamps = Duration(seconds: timeStampsDouble.toInt());
                    ref.read(onHoverDurationProvider.notifier).update((state) {
                      return timeStamps.toString().substring(0, 7);
                    });
                    setState(() {});
                  },
                  onPanEnd: (_) {
                    if (ref.read(showVideoControlProvider) == false) {
                      showControls(ref, callTimer: true);
                      return;
                    }
                    showControls(ref, callTimer: true);
                    if (onHover && timeStamps != null) {
                      widget.player.seek(timeStamps!);
                      ref.read(onHoverDurationProvider.notifier).update((state) => null);
                      onHover = false;
                      setState(() {});
                    }
                  },
                  onTapDown: (details) {
                    if (ref.read(showVideoControlProvider) == false) {
                      showControls(ref, callTimer: true);
                      return;
                    }
                    position = details.localPosition.dx / constraints.maxWidth;
                    timeStampsDouble = position * widget.player.state.duration.inSeconds;
                    timeStamps = Duration(seconds: timeStampsDouble.toInt());
                    widget.player.seek(timeStamps!);
                  },
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        color: const Color.fromARGB(121, 2, 2, 2),
                        backgroundColor: const Color.fromARGB(123, 129, 127, 127),
                        value: widget.player.state.position.inSeconds != 0 ? playbackPosition : 0,
                        borderRadius: BorderRadius.circular(12),
                        minHeight: 8,
                      ).py(5),
                      Positioned(
                        left: widget.player.state.position.inSeconds != 0 ? (playbackPosition * constraints.maxWidth) - 2 : 0,
                        child: Container(
                          height: 22,
                          width: 3.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              width: 0.07,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ).pltrb(60, 0, 60, 0),
          ),
        ],
      ),
    );
  }
}
