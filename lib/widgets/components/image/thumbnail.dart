// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/extensions/padding.dart';

class ImageThumbnail extends StatelessWidget {
  final FileElement file;
  final String url;

  const ImageThumbnail(this.file, {required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(file.filename);
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: const [
                      Colors.black,
                      Colors.transparent,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0, 0.4],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    fit: BoxFit.cover,
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
        // Text
      ],
    );
  }
}
