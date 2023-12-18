import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/pages/desktop/home_page.d.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../../controllers/content_controller.dart';
import '../../../pages/home_page.dart';

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

        return GestureDetector(
          onTap: () => selectFolderFunc(ref, context, folder),
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
                      Uri.decodeComponent(folder),
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

class GridFolderDekstop extends ConsumerWidget {
  final ScrollController scrollController;
  const GridFolderDekstop({required this.scrollController, super.key});
  static const double minItemWidth = 370.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int columnsCount = (MediaQuery.of(context).size.width / minItemWidth).floor();

    return GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columnsCount,
        childAspectRatio: ref.watch(sidebarStateProvider) ? 4.2 : 5.0,
        crossAxisSpacing: 0.0,
        mainAxisSpacing: 12.0,
      ),
      itemCount: ref.watch(pageContentStateProvider).folders.length,
      itemBuilder: (BuildContext context, int index) {
        final folder = ref.watch(pageContentStateProvider).folders[index];
        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFECF1F8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => selectFolderFunc(ref, context, folder),
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
                    Uri.decodeComponent(folder),
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ).pl(10),
                ),
              ),
            ],
          ),
        ).pr(25);
      },
    );
  }
}
