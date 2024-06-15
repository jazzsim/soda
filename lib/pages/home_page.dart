import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/content_controller.dart';
import '../providers/preferences_service.dart';
import '../widgets/components/dialogs/loading_dialog.dart';
import '../widgets/components/dialogs/toast_overlay.dart';
import 'desktop/home_page.d.dart';
import 'mobile/home_page.m.dart';
import 'responsive_layout.dart';
import 'tablet/home_page.t.dart';

final selectedIndexStateProvvider = StateProvider<int?>((ref) => null);

final volumeStateProvider = StateProvider<double>((ref) => 100);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int height = await windowManager.getTitleBarHeight();
      ref.read(titleBarHeight.notifier).update((state) => height);
      windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      mobileLayout: HomePageMobile(),
      tabletLayout: HomePageTablet(),
      dekstopLayout: HomePageDekstop(),
    );
  }
}

void selectServerFunc(WidgetRef ref, BuildContext context, int index) {
  ref.read(selectedIndexStateProvvider.notifier).update((state) => index);
  String url = ref.watch(serverListStateProvider)[index];

  if (ref.read(httpServerStateProvider).url != url) {
    LoadingScreen(context).show();
    Uri serverUri = ref.read(contentControllerProvider).selectServer(url);
    ref.invalidate(pageContentStateProvider);
    ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: serverUri.origin));
    ref.read(pathStateProvider.notifier).state = serverUri.path;

    ref.read(contentControllerProvider).getPageContent().then((_) {
      // showToast(context, ToastType.success, 'Connected');
      Navigator.of(context).pop();
    }).catchError((err, st) {
      LoadingScreen(context).hide();
      showToast(context, ToastType.error, err);
    });
  }
}

Future<void> updateFolderPref() async {
  bool gridFolderView = PreferencesService().getGridFolder();
  gridFolderView = !gridFolderView;
  await PreferencesService().setGridFolder(gridFolderView);
}

void selectFolderFunc(WidgetRef ref, BuildContext context, String folder) {
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
}
