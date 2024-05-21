import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/extensions/padding.dart';

class ImageThumbnail extends ConsumerWidget {
  final FileElement file;
  final String url;

  const ImageThumbnail(this.file, {required this.url, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String basicAuth = 'Basic ${base64.encode(utf8.encode('${ref.read(httpServerStateProvider).username}:${ref.read(httpServerStateProvider).password}'))}';
    String readableFile = Uri.decodeComponent(file.filename);
    String imgUrl = ref.read(httpServerStateProvider).url + ref.read(pathStateProvider) + url;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(imgUrl, headers: {
                      "authorization": basicAuth,
                    }),
                    fit: BoxFit.cover,
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
                  maxLines: 3,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ).pa(5),
              )
            ],
          ),
        ),
      ],
    );
  }
}
