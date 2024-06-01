import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/extensions/padding.dart';

class PDFViwer extends ConsumerStatefulWidget {
  final FileElement file;
  const PDFViwer(this.file, {super.key});

  @override
  ConsumerState<PDFViwer> createState() => _PDFViwerState();
}

class _PDFViwerState extends ConsumerState<PDFViwer> {
  final controller = PdfViewerController();
  int currentPage = 1;
  double zoom = 1.0;
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    controller.addListener(() async {
      if (controller.isReady) {
        if (!ready) {
          ready = true;
          controller.setZoom(controller.centerPosition, zoom);
          await Future.delayed(const Duration(milliseconds: 500));
          setState(() {});
        }
        if (controller.pageNumber != currentPage) {
          currentPage = controller.pageNumber ?? 1;
          setState(() {});
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Uri.decodeComponent(widget.file.filename),
        ),
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey,
          ),
          Opacity(
            opacity: ready ? 1 : 0,
            child: Stack(
              children: [
                PdfViewer.uri(
                  controller: controller,
                  headers: ref.read(contentControllerProvider).authHeader(),
                  Uri.parse(ref.read(baseURLStateProvider) + widget.file.filename),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      color: Colors.black,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.zoom_in,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            zoom += 0.2;
                            controller.setZoom(controller.centerPosition, zoom);
                            setState(() {});
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.zoom_out,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            zoom -= 0.2;
                            controller.setZoom(controller.centerPosition, zoom);
                            setState(() {});
                          },
                        )
                      ],
                    ).px(10),
                  ),
                ),
                if (controller.isReady)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        "Page ${controller.pageNumber} / ${controller.pages.length}",
                        style: const TextStyle(color: Colors.white),
                      ).px(15).py(5),
                    ).pb(15),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
