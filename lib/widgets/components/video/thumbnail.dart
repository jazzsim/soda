import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/video/main_video_player.dart';
import 'package:soda/widgets/extensions/padding.dart';

class VideoThumbnail extends ConsumerWidget {
  final FileElement file;
  final String url;
  const VideoThumbnail(this.file, {required this.url, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String readableFile = Uri.decodeComponent(file.filename);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MainVideoPlayer(url),
          ),
        );
      },
      child: Card(
        shadowColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            SizedBox(
                height: 120,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 9.0 / 16.0,
                  child: const ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(10.0),
                    ),
                    child: SizedBox(
                      child: Icon(
                        Icons.aspect_ratio,
                        size: 100,
                      ),
                    ),
                  ),
                )),
            const Spacer(),
            Text(
              readableFile,
              style: Theme.of(context).textTheme.titleSmall,
              maxLines: 2,
            ).pa(12),
          ],
        ),
      ),
    );
  }
}
