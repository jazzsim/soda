import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/providers/preferences_service.dart';
import 'package:soda/widgets/components/contents/grid_folders.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/components/dialogs/toast_overlay.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../controllers/content_controller.dart';
import '../../modals/page_content.dart';
import '../../widgets/components/contents/list_folders.dart';
import '../../widgets/components/image/thumbnail.dart';
import '../../widgets/components/others/thumbnail.dart';
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
        bottom: PreferredSize(preferredSize: const Size(40, 20), child: Text(ref.watch(titleStateProvider))),
      ),
      drawer: NavigationDrawer(
          selectedIndex: ref.watch(selectedIndexStateProvvider),
          onDestinationSelected: (int index) {
            Navigator.of(context).pop();

            ref.read(selectedIndexStateProvvider.notifier).update((state) => index);
            String url = ref.watch(serverListStateProvider)[index];

            if (ref.read(httpServerStateProvider).url != url) {
              LoadingScreen(context).show();
              Uri serverUri = ref.read(contentControllerProvider).selectServer(url);
              ref.read(pathStateProvider.notifier).state = serverUri.path;
              ref.read(titleStateProvider.notifier).state = serverUri.pathSegments.last;
              ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: serverUri.origin));

              ref
                  .read(contentControllerProvider)
                  .getPageContent()
                  .then((_) => showToast(context, ToastType.success, 'Connected'))
                  .catchError((err, st) => showToast(context, ToastType.error, err));
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
                    (e) => NavigationDrawerDestination(
                      icon: const Icon(Icons.dns),
                      label: Expanded(
                        child: OverflowBox(
                          child: Text(
                            e,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
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

class PageContentSection extends ConsumerStatefulWidget {
  const PageContentSection({super.key});

  @override
  ConsumerState<PageContentSection> createState() => _PageContentSectionState();
}

class _PageContentSectionState extends ConsumerState<PageContentSection> {
  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    bool gridFolderView = PreferencesService().getGridFolder();
    final folderScrollController = ScrollController();

    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Folders',
            style: Theme.of(context).textTheme.titleMedium,
          ).pa(10),
          IconButton(
            onPressed: () async {
              gridFolderView = !gridFolderView;
              await PreferencesService().setGridFolder(gridFolderView);
              setState(() {});
            },
            icon: Icon(
              gridFolderView ? Icons.grid_on_rounded : Icons.list,
            ),
          ),
        ],
      ),
      SizedBox(
        height: screenSize.height * 0.2,
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Scrollbar(
            controller: folderScrollController,
            thumbVisibility: true,
            child: gridFolderView
                ? GridFolder(
                    scrollController: folderScrollController,
                  )
                : ListFolder(
                    scrollController: folderScrollController,
                  ),
          ),
        ),
      ),
      if (ref.watch(pageContentStateProvider).files.isNotEmpty)
        SizedBox(
          height: screenSize.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Files',
                style: Theme.of(context).textTheme.titleMedium,
              ).pltrb(10, 20, 10, 10),
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
    final scrollController = ScrollController();
    super.build(context);
    return Scrollbar(
      controller: scrollController,
      thumbVisibility: true,
      child: GridView.builder(
        controller: scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: ref.watch(widget.contentStateProvider).length,
        itemBuilder: (BuildContext context, int index) {
          final file = ref.watch(widget.contentStateProvider)[index];
          final media = file.media.toLowerCase();
          final url = '${ref.watch(httpServerStateProvider).url}${ref.watch(pathStateProvider)}${file.filename}';
          switch (media) {
            case 'image':
              return ImageThumbnail(file, url: url);
            case 'video':
              return VideoThumbnail(file, url: url);
            case 'documents':
              return const SizedBox();
            default:
              return OthersThumbnail(file);
          }
        },
      ).px(10).pt(8),
    );
  }
}
