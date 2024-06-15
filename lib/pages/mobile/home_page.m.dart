import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/providers/preferences_service.dart';
import 'package:soda/widgets/components/contents/grid_folders.dart';
import 'package:soda/widgets/components/dialogs/toast_overlay.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../controllers/content_controller.dart';
import '../../modals/page_content.dart';
import '../../widgets/components/contents/list_folders.dart';
import '../../widgets/components/documents/thumbnail.dart';
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
      drawer: NavigationDrawer(selectedIndex: ref.watch(selectedIndexStateProvvider), children: [
        Consumer(builder: (context, ref, child) {
          return ListTile(
            title: const Text(
              'New Server',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            trailing: const Icon(Icons.add_circle_rounded),
            onTap: () => addServer(ref, context, MediaQuery.of(context).size.width),
          );
        }),
        const Divider(),
        if (ref.watch(serverListStateProvider).isNotEmpty) ...[
          ...ref.watch(serverListStateProvider).asMap().entries.map(
                (MapEntry<int, String> server) => ListTile(
                  leading: const Icon(Icons.dns),
                  onTap: () => selectServerFunc(ref, context, server.key),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(120)),
                  onLongPress: () => deleteServerDialog(ref, context, server.key),
                  selected: ref.watch(selectedIndexStateProvvider) == server.key,
                  selectedTileColor: const Color(0xFFD8E2F7),
                  title: Text(
                    server.value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ).px(5),
              ),
        ]
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
              updateFolderPref();
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

bool deleteServerDialog(WidgetRef ref, BuildContext context, int index) {
  bool delete = false;
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this item?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(contentControllerProvider).deleteServer(index).then((value) {
                  showToast(context, ToastType.success, "Server removed", extent: true);
                });
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      });
  return delete;
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
          // final url = file.filename;
          switch (media) {
            case 'image':
              return ImageThumbnail(
                file,
                index: index,
              );
            case 'video':
              return VideoThumbnail(file);
            case 'document':
              return DocumentThumbnail(file);
            default:
              return OthersThumbnail(file);
          }
        },
      ).px(10).pt(8),
    );
  }
}
