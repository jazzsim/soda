// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/extensions/padding.dart';

class OthersThumbnail extends StatelessWidget {
  final FileElement file;
  const OthersThumbnail(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(file.filename);

    return Card(
      shadowColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Center(
            child: Icon(
              Icons.description,
              color: Colors.blue,
              size: 60,
            ),
          ),
          const Spacer(),
          Text(
            readableFile,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 3,
          ).pa(12),
        ],
      ),
    );
  }
}
