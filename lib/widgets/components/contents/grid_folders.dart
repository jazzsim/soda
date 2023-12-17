import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../../controllers/content_controller.dart';
import '../dialogs/loading_dialog.dart';
import '../dialogs/toast_overlay.dart';

class GridFolder extends ConsumerWidget {
  final ScrollController scrollController;
  const GridFolder({required this.scrollController, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 4.4,
        crossAxisCount: 2,
        crossAxisSpacing: 2.0,
        mainAxisSpacing: 0,
      ),
      itemCount: ref.watch(pageContentStateProvider).folders.length,
      itemBuilder: (BuildContext context, int index) {
        final folder = ref.watch(pageContentStateProvider).folders[index];
        String readableFolder = Uri.decodeComponent(folder);

        return GestureDetector(
          onTap: () {
            LoadingScreen(context).show();
            if (folder == '../') {
              Uri uri = ref.read(contentControllerProvider).handleReverse();
              ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: uri.origin));
              ref.read(pathStateProvider.notifier).update((state) => "${uri.path}/");
            } else {
              ref.watch(pathStateProvider.notifier).update((state) => '$state$folder');
            }
            ref.read(titleStateProvider.notifier).update((state) => readableFolder);
            ref.read(contentControllerProvider).getPageContent().then((value) {
              LoadingScreen(context).hide();
            }).catchError((err, st) {
              showToast(context, ToastType.error, err);
            });
          },
          child: Card(
            shadowColor: Colors.transparent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.folder,
                  color: Color.fromARGB(255, 117, 117, 117),
                ).pltrb(10, 0, 5, 0),
                Expanded(
                  child: OverflowBox(
                    child: Text(
                      readableFolder,
                      overflow: TextOverflow.ellipsis,
                    ).pl(5),
                  ),
                ),
              ],
            ).py(8),
          ),
        );
      },
    ).px(10);
  }
}
