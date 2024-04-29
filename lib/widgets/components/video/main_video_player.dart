import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:video_player/video_player.dart';

class MainVideoPlayer extends ConsumerStatefulWidget {
  final String url;
  const MainVideoPlayer(this.url, {super.key});

  @override
  ConsumerState<MainVideoPlayer> createState() => _MainVideoPlayerState();
}

class _MainVideoPlayerState extends ConsumerState<MainVideoPlayer> {
  bool showVideoControl = false, isFullScreen = false;
  Timer? _timer;
  final Duration _duration = const Duration(milliseconds: 550); // Set the duration for pointer stop

  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();
    String basicAuth = 'Basic ${base64.encode(utf8.encode('${ref.read(httpServerStateProvider).username}:${ref.read(httpServerStateProvider).password}'))}';
    player.open(
      Media(
        ref.read(httpServerStateProvider).url + ref.read(pathStateProvider) + widget.url,
        httpHeaders: {
          "authorization": basicAuth,
        },
      ),
    );
    _timer = Timer.periodic(_duration, (Timer timer) {});
  }

  @override
  void dispose() {
    player.pause();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Uri.decodeComponent(widget.url),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Scaffold(
                  body: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Listener(
                        onPointerHover: (event) {
                          showVideoControl = true;
                          setState(() {});
                          _timer?.cancel();
                          _timer = Timer(_duration, () {
                            showVideoControl = false;
                            setState(() {});
                          });
                        },
                        child: Video(
                          controller: controller,
                          // Provide custom builder for controls.
                          controls: (state) {
                            return StreamBuilder(
                              stream: state.widget.controller.player.stream.playing,
                              builder: (context, playing) => GestureDetector(
                                onSecondaryTapDown: (_) async {
                                  player.state.playing ? player.pause() : player.play();
                                },
                              ),
                            );
                          },
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
                            onEnter: (event) => setState(() {
                              _timer?.cancel();
                              showVideoControl = true;
                            }),
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
            ),
          ],
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
    final double controlsOverlaySize = videoPlayerSize * 0.45;

    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      width: controlsOverlaySize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        // color: const Color.fromARGB(217, 239, 239, 239),
        color: const Color.fromARGB(173, 239, 239, 239),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 6),
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
                  const Positioned(
                    top: 13,
                    left: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 10),
                          child: Icon(
                            Icons.volume_up,
                            size: 20,
                          ),
                        ),
                        SizedBox(
                          width: 55,
                          child: VolumeSlider(),
                        )
                      ],
                    ),
                  ),
                  const Positioned(
                    top: 13,
                    right: 0,
                    child: Icon(
                      Icons.playlist_play_rounded,
                      size: 20,
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 5),
                      child: LinearProgressIndicator(
                        value: player.state.position.inMilliseconds.toDouble(),
                        color: const Color.fromARGB(176, 76, 78, 81),
                        backgroundColor: const Color.fromARGB(174, 158, 158, 158),
                      ),
                    ),
                  ),
                  Text(
                    durationToStringWithoutMilliseconds(player.state.duration),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
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

class VolumeSlider extends StatefulWidget {
  const VolumeSlider({super.key});

  @override
  State<VolumeSlider> createState() => _VolumeSliderState();
}

class _VolumeSliderState extends State<VolumeSlider> {
  double _volume = 1.0;
  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderThemeData(
        overlayShape: SliderComponentShape.noOverlay,
        thumbShape: SliderComponentShape.noThumb,
      ),
      child: Slider(
        value: _volume,
        onChanged: (value) => setState(() {
          _volume = value;
        }),
        activeColor: Colors.blueAccent,
        inactiveColor: const Color.fromARGB(229, 199, 198, 198),
      ),
    );
  }
}
