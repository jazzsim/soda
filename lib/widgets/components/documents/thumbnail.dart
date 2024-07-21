import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/documents/pdf_viewer.dart';
import 'package:soda/widgets/components/documents/pdf_viewer.m.dart';
import 'package:soda/widgets/extensions/padding.dart';

class DocumentThumbnail extends ConsumerStatefulWidget {
  final FileElement file;
  const DocumentThumbnail(this.file, {super.key});

  @override
  ConsumerState<DocumentThumbnail> createState() => _DocumentThumbnailState();
}

class _DocumentThumbnailState extends ConsumerState<DocumentThumbnail> {
  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(widget.file.filename);

    return GestureDetector(
      onTap: isPDFFile(widget.file.filename)
          ? () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  if (Platform.isAndroid || Platform.isIOS) {
                    return MobilePDFViwer(widget.file);
                  }
                  return PDFViwer(
                    widget.file,
                  );
                }),
              );
            }
          : null,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                isPDFFile(widget.file.filename)
                    ? PdfViewerWidget(widget.file.filename)
                    : const Center(
                        child: Icon(
                          Icons.description,
                          color: Colors.teal,
                          size: 60,
                        ),
                      ),
                Container(
                  foregroundDecoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(229, 0, 0, 0),
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
      ),
    );
  }
}

bool isPDFFile(String filename) {
  // Ensure the filename is not empty
  if (filename.isEmpty) {
    return false;
  }

  // Get the lowercase version of the filename
  String lowercaseFilename = filename.toLowerCase();

  // Check if the filename ends with ".pdf"
  return lowercaseFilename.endsWith('.pdf');
}

class PdfViewerWidget extends ConsumerStatefulWidget {
  final String filename;
  const PdfViewerWidget(this.filename, {super.key});

  @override
  ConsumerState<PdfViewerWidget> createState() => _PdfViewerWidgetState();
}

class _PdfViewerWidgetState extends ConsumerState<PdfViewerWidget> {
  final controller = PdfViewerController();
  bool zoomed = false;

  @override
  Widget build(BuildContext context) {
    // delay for zoom animation
    controller.addListener(() async {
      if (controller.isReady && !zoomed) {
        controller.zoomUp();
        zoomed = true;
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      }
    });
    return Opacity(
      opacity: zoomed ? 1 : 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: PdfViewer.uri(
          controller: controller,
          Uri.parse(
            ref.read(contentControllerProvider).getUrl(ref.read(baseURLStateProvider) + widget.filename),
          ),
        ),
      ),
    );
  }
}
