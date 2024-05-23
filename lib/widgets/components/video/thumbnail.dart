import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/extensions/padding.dart';

class VideoThumbnail extends ConsumerWidget {
  final FileElement file;
  const VideoThumbnail(this.file, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String readableFile = Uri.decodeComponent(file.filename);
    String url = ref.read(httpServerStateProvider).url + ref.read(pathStateProvider) + file.filename;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainVideoPlayer(file.filename),
          ),
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ref.watch(thumbnailFutureProvider(url)).when(
                      data: (data) {
                        if (data != null) {
                          return Container(
                            foregroundDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              image: DecorationImage(
                                image: data.image,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }
                        return Center(
                          child: const Icon(
                            Icons.play_circle_fill,
                            color: Color.fromARGB(255, 160, 112, 184),
                            size: 100,
                          ).pb(40),
                        );
                      },
                      error: (err, st) => const Center(child: Icon(Icons.error)),
                      loading: () => const Center(child: CircularProgressIndicator()),
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
