import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';
import 'package:pdfx/pdfx.dart';
import 'package:soda/modals/page_content.dart';
import 'package:soda/widgets/components/documents/pdf_viewer.dart';
import 'package:soda/widgets/extensions/padding.dart';

class DocumentThumbnail extends StatelessWidget {
  final FileElement file;
  final String url;
  const DocumentThumbnail(this.file, {required this.url, super.key});

  @override
  Widget build(BuildContext context) {
    String readableFile = Uri.decodeComponent(file.filename);

    return GestureDetector(
      onTap: isPDFFile(file.filename)
          ? () {
              PdfControllerPinch pdfController = PdfControllerPinch(
                document: PdfDocument.openData(InternetFile.get(url)),
              );
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => PDFViwer(file: file, pdfController: pdfController),
              ));
            }
          : () {},
      child: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                isPDFFile(file.filename)
                    ? FutureBuilder<Map<int, Uint8List>>(
                        future: pdfThumbnail(url),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final images = snapshot.data!;
                            final image = images[1];
                            return Container(
                              foregroundDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey[200],
                                image: DecorationImage(
                                  image: MemoryImage(image!),
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            );
                          } else {
                            return Center(
                              child: const CircularProgressIndicator().px(40),
                            );
                          }
                        })
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

Future<Map<int, Uint8List>> pdfThumbnail(String url) async {
  final images = <int, Uint8List>{};
  final doc = await PdfDocument.openData(InternetFile.get(url));
  final page = await doc.getPage(1);
  final pageImage = await page.render(
    width: page.width,
    height: page.height,
  );
  images[1] = pageImage!.bytes;
  await page.close();
  return images;
}

class DocumentThumbnailDekstop extends StatelessWidget {
  final FileElement file;
  const DocumentThumbnailDekstop(this.file, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const SizedBox(
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(10.0),
                ),
                child: Center(
                  child: Icon(
                    Icons.description,
                    color: Colors.teal,
                    size: 60,
                  ),
                ),
              )),
          const Spacer(),
          Text(
            Uri.decodeComponent(file.filename),
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
          ).pa(12),
        ],
      ),
    );
  }
}
