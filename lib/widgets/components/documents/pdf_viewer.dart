import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
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
  void initState() {
    super.initState();

    // onpostframe
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                if (controller.isReady)
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: Text(
                        "Page ${controller.pageNumber} / ${controller.pageCount}",
                        style: const TextStyle(color: Colors.white),
                      ).px(15).py(5),
                    ).pb(15),
                  ),
              ],
            ).pt(ref.read(titleBarHeight) + 25),
          ),
          Positioned(
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.black,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () async => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  Tooltip(
                    message: Uri.decodeComponent(widget.file.filename),
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                    child: SizedBox(
                      width: 400,
                      child: Text(
                        Uri.decodeComponent(widget.file.filename),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  Container(
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
                ],
              ),
            ),
          ),
        ],
      ).pt(ref.read(titleBarHeight)),
    );
  }
}
