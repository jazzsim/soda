import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/extensions/padding.dart';

class PDFViwer extends StatefulWidget {
  final FileElement file;
  final PdfControllerPinch pdfController;
  const PDFViwer({required this.file, required this.pdfController, super.key});

  @override
  State<PDFViwer> createState() => _PDFViwerState();
}

class _PDFViwerState extends State<PDFViwer> {
  int totalPage = 1, currentPage = 1;
  bool loading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(Uri.decodeComponent(widget.file.filename)),
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            duration: const Duration(
              milliseconds: 500,
            ),
            opacity: loading ? 1 : 0,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: PdfViewPinch(
                  onPageChanged: (page) => setState(() {
                    currentPage = page;
                  }),
                  onDocumentLoaded: (document) => setState(() {
                    totalPage = document.pagesCount;
                    loading = false;
                  }),
                  controller: widget.pdfController,
                ),
              ),
              SafeArea(
                child: Center(
                  child: loading
                      ? Text(
                          'Loading document',
                        ).py(10)
                      : Text('$currentPage / $totalPage').py(10),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
