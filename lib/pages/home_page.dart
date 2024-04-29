import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/content_controller.dart';
import '../providers/preferences_service.dart';
import '../widgets/components/dialogs/loading_dialog.dart';
import '../widgets/components/dialogs/toast_overlay.dart';
import 'desktop/home_page.d.dart';
import 'mobile/home_page.m.dart';
import 'responsive_layout.dart';
import 'tablet/home_page.t.dart';

final selectedIndexStateProvvider = StateProvider<int?>((ref) => null);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
    ref.read(pathStateProvider.notifier).state = serverUri.path;
    if (serverUri.pathSegments.isNotEmpty) {
      ref.read(titleStateProvider.notifier).state = serverUri.pathSegments.last;
    }

    ref.read(contentControllerProvider).getPageContent().then((_) {
      // showToast(context, ToastType.success, 'Connected');
      Navigator.of(context).pop();
    }).catchError((err, st) {
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
  String readableFolder = Uri.decodeComponent(folder);

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
}
