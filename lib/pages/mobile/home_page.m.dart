import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/components/dialogs/toast_dialog.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../controllers/content_controller.dart';
import '../../modals/page_content.dart';
import '../../widgets/components/video/thumbnail.dart';
import '../add_server.func.dart';
import '../home_page.dart';

class HomePageMobile extends ConsumerWidget {
  const HomePageMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Soda'),
      ),
      drawer: NavigationDrawer(
          selectedIndex: ref.watch(selectedIndexStateProvvider),
          onDestinationSelected: (int index) {
            Navigator.of(context).pop();

            ref.read(selectedIndexStateProvvider.notifier).update((state) => index);
            String url = ref.watch(serverListStateProvider)[index];

            if (ref.read(httpServerStateProvider).url != url) {
              LoadingScreen(context).show();
              String serverOrigin = ref.read(contentControllerProvider).selectServer(url);
              ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: serverOrigin));

              ref
                  .read(contentControllerProvider)
                  .getPageContent()
                  .then((_) => ToastDialog(context).show(type: ToastType.success, text: 'Connected'))
                  .catchError((err, st) => ToastDialog(context).show(type: ToastType.error, text: err));
            }
          },
          children: [
            ListTile(
              title: const Text(
                'Server List',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Consumer(
                builder: (context, ref, child) {
                  return IconButton(
                    tooltip: "Add a new Server",
                    onPressed: () => addServer(ref, context, MediaQuery.of(context).size.width),
                    icon: const Icon(Icons.add_circle_rounded),
                  );
                },
              ),
            ),
            const Divider(),
            if (ref.watch(serverListStateProvider).isEmpty)
              const Column(children: [
                Text(
                  'No server yet',
                ),
              ])
            else
              ...ref
                  .watch(serverListStateProvider)
                  .map(
                    (e) => NavigationDrawerDestination(icon: const Icon(Icons.dns), label: Text(e)),
                  )
                  .toList()
          ]),
      body: ref.watch(pageContentStateProvider).files.isEmpty && ref.watch(pageContentStateProvider).folders.isEmpty
          ? Center(
              child: const Text(
                'Select a server or\n + a new server',
                textAlign: TextAlign.center,
              ).pa(20),
            )
          : const PageContentSection(),
    );
  }
}

class PageContentSection extends ConsumerWidget {
  const PageContentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final folderScrollController = ScrollController();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        'Folders',
        style: Theme.of(context).textTheme.titleMedium,
      ).pa(10),
      Expanded(
        flex: 2,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Scrollbar(
            controller: folderScrollController,
            thumbVisibility: true,
            child: GridView.builder(
              controller: folderScrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 3,
                crossAxisCount: 3, // Adjust the number of columns as needed
                crossAxisSpacing: 8.0, // Adjust the spacing between columns
                mainAxisSpacing: 8.0, // Adjust the spacing between rows
              ),
              itemCount: ref.watch(pageContentStateProvider).folders.length, // Replace with the actual number of items in your list
              itemBuilder: (BuildContext context, int index) {
                final folder = ref.watch(pageContentStateProvider).folders[index];
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
                    ref.read(contentControllerProvider).getPageContent().then((value) {
                      LoadingScreen(context).hide();
                    }).catchError((err, st) {
                      ToastDialog(context).show(type: ToastType.error, text: err);
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
                              folder,
                              overflow: TextOverflow.ellipsis,
                            ).pl(5),
                          ),
                        ),
                      ],
                    ).py(8),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      if (ref.watch(pageContentStateProvider).files.isNotEmpty)
        Expanded(
          flex: 8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  'Files',
                  style: Theme.of(context).textTheme.titleMedium,
                ).pltrb(10, 20, 10, 10),
              ),
              Flexible(
                child: DefaultTabController(
                  length: 4,
                  child: Column(children: [
                    TabBar(
                      tabs: <Widget>[
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.image),
                              Text(
                                ref.watch(imagesContentStateProvider).isEmpty ? '-' : '${ref.watch(imagesContentStateProvider).length}',
                              ).pl(5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.play_circle,
                              ),
                              Text(
                                ref.watch(videosContentStateProvider).isEmpty ? '-' : '${ref.watch(videosContentStateProvider).length}',
                              ).pl(5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.description),
                              Text(
                                ref.watch(documentsContentStateProvider).isEmpty ? '-' : '${ref.watch(documentsContentStateProvider).length}',
                              ).pl(5),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.quiz),
                              Text(
                                ref.watch(othersContentStateProvider).isEmpty ? '-' : '${ref.watch(othersContentStateProvider).length}',
                              ).pl(5),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        ContentsTabView(imagesContentStateProvider),
                        ContentsTabView(videosContentStateProvider),
                        ContentsTabView(documentsContentStateProvider),
                        ContentsTabView(othersContentStateProvider),
                      ]),
                    ),
                  ]),
                ),
              )
            ],
          ),
        ),
    ]);
  }
}

class ContentsTabView extends ConsumerStatefulWidget {
  final StateProvider<List<FileElement>> contentStateProvider;
  const ContentsTabView(this.contentStateProvider, {super.key});

  @override
  ConsumerState<ContentsTabView> createState() => _ContentsTabViewState();
}

class _ContentsTabViewState extends ConsumerState<ContentsTabView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MediaQuery.removePadding(
      context: context,
      child: Scrollbar(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: ref.watch(widget.contentStateProvider).length,
          itemBuilder: (BuildContext context, int index) {
            final file = ref.watch(widget.contentStateProvider)[index];
            return FileCard(file.filename);
          },
        ).px(10).pt(8),
      ),
    );
  }
}

class FileCard extends ConsumerWidget {
  final String filename;
  const FileCard(this.filename, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shadowColor: Colors.transparent,
      child: Column(
        children: [
          VideoThumbnail(
            vidUrl: '${ref.watch(httpServerStateProvider).url}${ref.watch(pathStateProvider)}$filename',
          ),
          Text(
            filename,
            maxLines: 2,
          ).pa(15),
        ],
      ),
    );
  }
}
