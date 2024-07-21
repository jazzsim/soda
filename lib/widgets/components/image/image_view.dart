import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/services/device_size.dart';
import 'package:soda/widgets/extensions/padding.dart';

class ImageView extends ConsumerStatefulWidget {
  final int index;
  const ImageView(this.index, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ImageViewState();
}

class _ImageViewState extends ConsumerState<ImageView> {
  String filename = "";
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    currentIndex = widget.index;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      filename = Uri.decodeComponent(ref.watch(imagesContentStateProvider)[currentIndex].filename);
      pageController.jumpToPage(currentIndex);
      setState(() {});
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
          Column(
            children: [
              const SizedBox(
                height: 60,
              ),
              Stack(
                children: [
                  SizedBox(
                    height: DeviceSizeService.device.height * 0.9,
                    child: PageView(
                      controller: pageController,
                      onPageChanged: (value) {
                        currentIndex = value;
                        filename = Uri.decodeComponent(ref.watch(imagesContentStateProvider)[currentIndex].filename);
                        setState(() {});
                      },
                      children: [
                        ...ref.watch(imagesContentStateProvider).map((e) {
                          return ExtendedImage.network(
                            ref.watch(baseURLStateProvider) + e.filename,
                            fit: BoxFit.contain,
                            mode: ExtendedImageMode.gesture,
                          );
                        }),
                      ],
                    ),
                  ).pt(ref.read(titleBarHeight)),
                ],
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: currentIndex == 0
                  ? null
                  : () {
                      currentIndex--;
                      pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {});
                    },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  height: DeviceSizeService.device.height,
                  width: 150,
                  child: Center(
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: currentIndex == 0 ? Colors.grey : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: currentIndex == ref.read(imagesContentStateProvider).length
                  ? null
                  : () {
                      currentIndex++;
                      pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                      setState(() {});
                    },
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  color: Colors.black.withOpacity(0.2),
                  height: DeviceSizeService.device.height,
                  width: 150,
                  child: Center(
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: currentIndex == ref.read(imagesContentStateProvider).length ? Colors.grey : Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
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
                  message: Uri.decodeComponent(filename),
                  textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                  child: SizedBox(
                    width: 400,
                    child: Text(
                      Uri.decodeComponent(filename),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                          ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
