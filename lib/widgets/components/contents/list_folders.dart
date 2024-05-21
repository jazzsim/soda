import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../../controllers/content_controller.dart';
import '../dialogs/loading_dialog.dart';
import '../dialogs/toast_overlay.dart';

class ListFolder extends ConsumerWidget {
  final ScrollController scrollController;
  const ListFolder({required this.scrollController, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: scrollController,
      itemCount: ref.watch(pageContentStateProvider).folders.length,
      itemBuilder: (BuildContext context, int index) {
        final folder = ref.watch(pageContentStateProvider).folders[index];
        String readableFolder = Uri.decodeComponent(folder);

        return FolderListTile(folder: folder, readableFolder: readableFolder);
      },
    );
  }
}

class FolderListTile extends ConsumerWidget {
  const FolderListTile({
    super.key,
    required this.folder,
    required this.readableFolder,
  });

  final String folder;
  final String readableFolder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      onTap: () {
        LoadingScreen(context).show();
        if (folder == '../') {
          Uri uri = ref.read(contentControllerProvider).handleReverse();
          ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: uri.origin));
          ref.read(pathStateProvider.notifier).update((state) => "${uri.path}/");
        } else {
          ref.watch(pathStateProvider.notifier).update((state) => '$state$folder');
        }
        ref.read(contentControllerProvider).getPageContent().then((value) {
          LoadingScreen(context).hide();
        }).catchError((err, st) {
          showToast(context, ToastType.error, err);
        });
      },
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder,
            color: Color.fromARGB(255, 117, 117, 117),
          ).pltrb(10, 0, 5, 0),
          Expanded(
            child: Text(
              readableFolder,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ).px(5),
          ),
        ],
      ).py(8),
    );
  }
}
