import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/pages/mobile/add_server.m.dart';
import 'package:soda/services/device_size.dart';
import 'package:soda/services/preferences_service.dart';
import 'package:soda/widgets/components/contents/grid_folders.dart';
import 'package:soda/widgets/components/documents/thumbnail.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../controllers/content_controller.dart';
import '../../modals/page_content.dart';
import '../../widgets/components/contents/list_folders.dart';
import '../../widgets/components/image/thumbnail.dart';
import '../../widgets/components/others/thumbnail.dart';
import '../../widgets/components/video/thumbnail.dart';
import '../home_page.dart';

final sidebarStateProvider = StateProvider<bool>((ref) => true);

final contentVisibleStateProvider = StateProvider<bool>((ref) => true);

final titleBarHeight = StateProvider<int>((ref) => 0);

class HomePageDekstop extends ConsumerStatefulWidget {
  const HomePageDekstop({super.key});

  @override
  ConsumerState<HomePageDekstop> createState() => _HomePageDekstopState();
}

class _HomePageDekstopState extends ConsumerState<HomePageDekstop> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(
              milliseconds: 80,
            ),
            curve: Curves.easeIn,
            width: ref.watch(sidebarStateProvider) ? 350 : 0,
            child: Drawer(
              shape: const LinearBorder(),
              child: Visibility(
                visible: ref.watch(contentVisibleStateProvider),
                child: Column(
                  children: [
                    ListTile(
                      onTap: () => addServerModal(ref, context),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'New Server',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const Icon(
                            Icons.add,
                          ),
                        ],
                      ).py(12),
                    ).pt(ref.watch(titleBarHeight)),
                    ...ref.watch(serverListStateProvider).asMap().entries.map(
                          (e) => ListTile(
                            leading: const Icon(
                              Icons.dns,
                            ),
                            title: Text(
                              e.value,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => selectServerFunc(ref, context, e.key),
                          ),
                        )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                SizedBox(
                  child: ref.watch(pageContentStateProvider).files.isEmpty && ref.watch(pageContentStateProvider).folders.isEmpty
                      ? Center(
                          child: const Text(
                            'Select a server or\n + a new server',
                            textAlign: TextAlign.center,
                          ).pa(20),
                        )
                      : const PageContentSectionDesktop(),
                ).pltrb(40, 10 + ref.watch(titleBarHeight), 20, 0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      shape: const LinearBorder(),
                      splashFactory: NoSplash.splashFactory,
                      highlightColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    icon: ref.watch(contentVisibleStateProvider)
                        ? const Icon(
                            Icons.chevron_left,
                            size: 30,
                          )
                        : const Icon(
                            Icons.chevron_right,
                            size: 30,
                          ),
                    onPressed: () async {
                      if (ref.watch(sidebarStateProvider)) {
                        ref.read(contentVisibleStateProvider.notifier).update((state) => false);
                        ref.read(sidebarStateProvider.notifier).update((state) => false);
                      } else {
                        ref.read(sidebarStateProvider.notifier).update((state) => true);
                        await Future.delayed(const Duration(milliseconds: 70), () {
                          ref.read(contentVisibleStateProvider.notifier).update((state) => true);
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class PageContentSectionDesktop extends ConsumerStatefulWidget {
  const PageContentSectionDesktop({super.key});

  @override
  ConsumerState<PageContentSectionDesktop> createState() => _PageContentSectionDesktopState();
}

class _PageContentSectionDesktopState extends ConsumerState<PageContentSectionDesktop> {
  final folderScrollController = ScrollController();
  bool gridFolderView = PreferencesService().getGridFolder();

  @override
  Widget build(BuildContext context) {
    final Size screenSize = DeviceSizeService.device.size;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            Uri.decodeComponent(ref.watch(pathStateProvider)),
            style: Theme.of(context).textTheme.titleLarge,
          ).pltrb(10, 10, 0, 10),
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
                  gridFolderView = PreferencesService().getGridFolder();
                  setState(() {});
                },
                icon: Icon(
                  gridFolderView ? Icons.grid_on_rounded : Icons.list,
                ).pr(8),
              ),
            ],
          ),
          SizedBox(
            height: screenSize.height,
            child: VerticalSplitView(
              top: SizedBox(
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: gridFolderView
                      ? GridFolderDekstop(
                          scrollController: folderScrollController,
                        )
                      : ListFolder(
                          scrollController: folderScrollController,
                        ),
                ),
              ),
              bottom: ref.watch(pageContentStateProvider).files.isNotEmpty
                  ? SizedBox(
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
                    )
                  : Container(),
              ratio: 0.3,
            ),
          ),
        ]),
      ),
    );
  }
}

class VerticalSplitView extends StatefulWidget {
  final Widget top;
  final Widget bottom;
  final double ratio;

  const VerticalSplitView({super.key, required this.top, required this.bottom, this.ratio = 0.5})
      : assert(ratio >= 0),
        assert(ratio <= 1);

  @override
  State<VerticalSplitView> createState() => _VerticalSplitViewState();
}

class _VerticalSplitViewState extends State<VerticalSplitView> {
  final _dividerHeight = 16.0;

  late double _ratio;
  double? _maxHeight;

  get _height1 => _ratio * (_maxHeight ?? 200);

  get _height2 => (1 - _ratio) * (_maxHeight ?? 410);

  @override
  void initState() {
    super.initState();
    _ratio = widget.ratio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, BoxConstraints constraints) {
      assert(_ratio <= 1);
      assert(_ratio >= 0);
      _maxHeight ??= constraints.maxHeight;
      if (_maxHeight != constraints.maxHeight) {
        _maxHeight = constraints.maxHeight - _dividerHeight;
      }

      return SizedBox(
        height: constraints.maxHeight,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: _height1 - 120,
              child: widget.top,
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              child: const SizedBox(
                height: 20,
                child: RotationTransition(
                  turns: AlwaysStoppedAnimation(0),
                  child: Icon(Icons.drag_handle),
                ),
              ),
              onPanUpdate: (DragUpdateDetails details) {
                setState(
                  () {
                    if (_ratio < 0.25) {
                      _ratio = 0.25;
                      return;
                    } else if (_ratio > 0.65) {
                      _ratio = 0.65;
                      return;
                    }
                    _ratio += details.delta.dy / (_maxHeight ?? 0);
                  },
                );
              },
            ),
            SizedBox(
              height: _height2,
              child: widget.bottom,
            ),
          ],
        ),
      );
    });
  }
}

class ContentsTabView extends ConsumerStatefulWidget {
  final StateProvider<List<FileElement>> contentStateProvider;
  const ContentsTabView(this.contentStateProvider, {super.key});

  @override
  ConsumerState<ContentsTabView> createState() => _ContentsTabViewState();
}

class _ContentsTabViewState extends ConsumerState<ContentsTabView> with AutomaticKeepAliveClientMixin {
  static const double minItemWidth = 300;
  int currentIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final scrollController = ScrollController();
    int columnsCount = (DeviceSizeService.device.width / minItemWidth).floor();

    return SingleChildScrollView(
      controller: scrollController,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columnsCount,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12.0,
          mainAxisSpacing: 12.0,
        ),
        itemCount: ref.read(widget.contentStateProvider).length,
        itemBuilder: (BuildContext context, int index) {
          final file = ref.read(widget.contentStateProvider)[index];
          final media = file.media.toLowerCase();
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
      ),
    );
  }
}
