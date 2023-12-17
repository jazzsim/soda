import 'package:flutter/material.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/dialogs/toast_overlay.dart';
import 'package:soda/widgets/extensions/padding.dart';
import 'package:video_player/video_player.dart';

class VideoThumbnail extends StatefulWidget {
  final FileElement file;
  final String url;
  const VideoThumbnail(this.file, {required this.url, super.key});

  @override
  State<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<VideoThumbnail> {
  late VideoPlayerController _controller;
  String error = '';
  List<DurationRange> bufferHealth = [];

  bool init = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    )..initialize().then((_) {
        loadThumbnail();
      }).catchError((err, st) {
        error = err;
        showToast(context, ToastType.error, err);
      });
  }

  Future<void> loadThumbnail() async {
    double videoPlaytimeInSeconds = _controller.value.duration.inMilliseconds / 1000;
    // create thumbnail at 38% mark
    int thumbnailPosition = (videoPlaytimeInSeconds * 0.38).toInt();
    _controller.setVolume(0);
    _controller.seekTo(Duration(seconds: thumbnailPosition));

    // Add a listener to listen for changes in playback
    _controller.addListener(() async {
      generateThumbnail(_controller);
      evaluateBufferHealth(_controller);
    });
    _controller.play();
  }

  void generateThumbnail(VideoPlayerController controller) async {
    if (_controller.value.isPlaying) {
      if (!init && _controller.value.buffered.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 600));
        await _controller.pause();
        init = true;
      }
    }
  }

  void evaluateBufferHealth(VideoPlayerController controller) {
    if (_controller.value.isInitialized || _controller.value.isPlaying) {
      bufferHealth = _controller.value.buffered;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(widget.file.filename);
    return Card(
      shadowColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Stack(
            children: [
              SizedBox(
                height: 120,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10.0),
                          ),
                          child: VideoPlayer(
                            _controller,
                          ),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.video_file,
                              color: Colors.redAccent,
                              size: 60,
                            ),
                            if (error.isNotEmpty)
                              Text(
                                error,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.red,
                                    ),
                              )
                          ],
                        ),
                      ),
              ),
              Positioned(
                  bottom: 0,
                  right: 0,
                  child: error.isNotEmpty
                      ? const Icon(
                          Icons.signal_cellular_nodata_rounded,
                          color: Colors.redAccent,
                        )
                      : bufferHealth.isNotEmpty
                          ? bufferHealthIndicator(_controller, bufferHealth).pltrb(0, 0, 4, 4)
                          : const SizedBox()),
            ],
          ),
          const Spacer(),
          Text(
            readableFile,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
          ).pa(12),
        ],
      ),
    );
  }
}

Widget bufferHealthIndicator(VideoPlayerController controller, List<DurationRange> buffer) {
  late double bufferStart;
  late Widget bufferHealth;

  // uses DurationRange from video_player to determine network quality
  if (controller.value.position.compareTo(buffer.first.start) > 0) {
    bufferStart = controller.value.position.inMilliseconds / 1000;
  } else {
    bufferStart = buffer.first.start.inMilliseconds / 1000;
  }

  double bufferEnd = buffer.first.end.inMilliseconds / 1000;

  // 15 seconds threshold
  double healthThreshold = 15;
  double bufferedProgress = bufferEnd - bufferStart;

  if (bufferedProgress > healthThreshold * 5) {
    bufferHealth = const Icon(
      Icons.signal_cellular_alt_rounded,
      color: Colors.greenAccent,
    );
  } else if (bufferedProgress > healthThreshold * 3 && bufferedProgress < healthThreshold * 4) {
    bufferHealth = const Icon(
      Icons.signal_cellular_alt_rounded,
      color: Colors.lightGreen,
    );
  } else if (bufferedProgress > healthThreshold * 2 && bufferedProgress < healthThreshold * 3) {
    bufferHealth = const Icon(
      Icons.signal_cellular_alt_2_bar_rounded,
      color: Colors.orange,
    );
  } else if (bufferedProgress > healthThreshold && bufferedProgress < healthThreshold * 2) {
    bufferHealth = const Icon(
      Icons.signal_cellular_alt_1_bar_rounded,
      color: Colors.yellow,
    );
  } else {
    bufferHealth = const Icon(
      Icons.signal_cellular_connected_no_internet_0_bar,
      color: Colors.red,
    );
  }

  return bufferHealth;
}
