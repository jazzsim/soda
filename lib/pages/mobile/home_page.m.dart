import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/components/dialogs/toast_dialog.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../controllers/content_controller.dart';
import '../../modals/page_content.dart';
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

            LoadingScreen(context).show();
            ref.read(contentControllerProvider).selectServer(url);
            ref
                .read(contentControllerProvider)
                .getPageContent()
                .then((_) => ToastDialog(context).show(type: ToastType.success, text: 'Connected', extent: true))
                .catchError((err, st) => ToastDialog(context).show(type: ToastType.error, text: err));
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
    final scrollController = ScrollController();

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
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Wrap(
                children: ref.watch(pageContentStateProvider).folders.map(
                  (String folder) {
                    return SizedBox(
                      width: MediaQuery.of(context).size.width / 2.11,
                      child: Card(
                        shadowColor: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.folder,
                              color: Color.fromARGB(255, 117, 117, 117),
                            ).pltrb(10, 8, 5, 8),
                            Text(folder).pltrb(5, 8, 0, 8),
                          ],
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),
            ).px(10),
          ),
        ),
      ),
      Text(
        'Files',
        style: Theme.of(context).textTheme.titleMedium,
      ).pa(10).pt(10),
      ref.watch(pageContentStateProvider).files.isEmpty
          ? const Center(
              child: Text('No files found'),
            )
          : Expanded(
              flex: 8,
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
                            const Icon(Icons.play_circle),
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
    ]);
  }
}

class ContentsTabView extends ConsumerWidget {
  final StateProvider<List<FileElement>> contentStateProvider;
  const ContentsTabView(this.contentStateProvider, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MediaQuery.removePadding(
      context: context,
      child: Scrollbar(
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, 
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: ref.watch(contentStateProvider).length,
          itemBuilder: (BuildContext context, int index) {
            final file = ref.watch(contentStateProvider)[index];
            return FileCard(file.filename);
          },
        ).px(10).pt(8),
      ),
    );
  }
}

class FileCard extends StatelessWidget {
  final String filename;
  const FileCard(this.filename, {super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      child: Text(filename),
    );
  }
}
