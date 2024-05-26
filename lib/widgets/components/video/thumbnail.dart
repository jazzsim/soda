import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/extensions/padding.dart';

class VideoThumbnail extends ConsumerStatefulWidget {
  final FileElement file;
  const VideoThumbnail(this.file, {super.key});

  @override
  ConsumerState<VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends ConsumerState<VideoThumbnail> {
  String thumbnailUrl = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      String url = ref.read(httpServerStateProvider).url + ref.read(pathStateProvider) + widget.file.filename;
      await ref.read(contentControllerProvider).vidThumbnail(url, widget.file.filename).then((value) {
        if (mounted) {
          setState(() {
            thumbnailUrl = value;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(widget.file.filename);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainVideoPlayer(widget.file.filename),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: thumbnailUrl == ""
                      ? const Icon(
                          Icons.play_circle_fill,
                          color: Color.fromARGB(255, 160, 112, 184),
                          size: 100,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ExtendedImage.network(
                            thumbnailUrl,
                            fit: BoxFit.cover,
                            height: 200,
                            cache: true,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(
                                12.0,
                              ),
                            ),
                          ),
                        ),
                ),
                Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Colors.black,
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      stops: [0, 0.4],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Text(
                    readableFile,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                        ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ).pa(15),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
