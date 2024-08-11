import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/components/primary_button.dart';
import 'package:soda/widgets/components/text_button.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../widgets/components/dialogs/toast_overlay.dart';

void addServerModal(WidgetRef ref, BuildContext context) {
  final showPasswordStateProvider = StateProvider<bool>((ref) => false);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext innerContext) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add new server',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextField(
                  // autofocus: true,
                  decoration: const InputDecoration(labelText: 'Server url', border: OutlineInputBorder()),
                  keyboardType: TextInputType.url,
                  onChanged: (url) => ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: url)),
                ).pb(20).pt(20),
                ExpansionTile(
                  title: const Text(
                    'Credentials (Optional)',
                  ),
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
                      onChanged: (username) => ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(username: username)),
                    ).pb(5).pt(10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                            icon: Icon(
                              ref.watch(showPasswordStateProvider) ? Icons.visibility : Icons.visibility_off,
                            ),
                            onPressed: () => setState(
                                  () {
                                    ref.read(showPasswordStateProvider.notifier).update((state) => !state);
                                  },
                                )),
                      ),
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !ref.watch(showPasswordStateProvider),
                      onChanged: (password) => ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(password: password)),
                    ).pb(10).pt(5),
                  ],
                ).pb(20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CTextButton(
                      'Cancel',
                      onPressed: () {
                        Navigator.pop(context); // Closes the dialog
                      },
                    ),
                    PrimaryButton(
                      'Add',
                      onPressed: () {
                        ref.invalidate(pathStateProvider);
                        LoadingScreen(context).show();
                        ref.read(contentControllerProvider).getPageContent().then(
                          (_) async {
                            if (!context.mounted) return;
                            showToast(context, ToastType.success, 'Success');

                            LoadingScreen(context).hide();
                            Navigator.of(context).pop();
                            // save server details into shared preferences
                            ref.read(contentControllerProvider).updateServerList();
                            ref.invalidate(serverListStateProvider);

                            Uri serverUri = Uri.parse(ref.read(httpServerStateProvider).url);
                            ref.read(pathStateProvider.notifier).state = serverUri.path;
                            ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: serverUri.origin));
                          },
                        ).catchError(
                          (err, st) {
                            if (!context.mounted) return;
                            LoadingScreen(context).hide();
                            Navigator.of(context).pop();
                            showToast(context, ToastType.error, "$err", extent: true);
                          },
                        );
                      },
                    )
                  ],
                )
              ],
            ).pa(20),
          );
        },
      );
    },
  );
}
