import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:soda/controllers/content_controller.dart';

class MainVideoPlayer extends ConsumerStatefulWidget {
  final String url;
  const MainVideoPlayer(this.url, {super.key});

  @override
  ConsumerState<MainVideoPlayer> createState() => _MainVideoPlayerState();
}

class _MainVideoPlayerState extends ConsumerState<MainVideoPlayer> {
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
  }

  @override
  void dispose() {
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
                child: Video(
                  wakelock: false,
                  subtitleViewConfiguration: const SubtitleViewConfiguration(),
                  onExitFullscreen: () => SystemChrome.setPreferredOrientations(
                    [DeviceOrientation.portraitUp],
                  ),
                  controller: controller,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
