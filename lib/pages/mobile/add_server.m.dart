import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/controllers/content_controller.dart';
import 'package:soda/pages/add_server.func.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/components/primary_button.dart';
import 'package:soda/widgets/components/text_button.dart';
import 'package:soda/widgets/extensions/padding.dart';

import '../../widgets/components/dialogs/toast_dialog.dart';

void addServerModal(WidgetRef ref, BuildContext context) {
  final showPasswordStateProvider = StateProvider<bool>((ref) => true);

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    isScrollControlled: true,
    builder: (BuildContext context) {
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
              decoration: const InputDecoration(labelText: 'Server url', border: OutlineInputBorder()),
              keyboardType: TextInputType.url,
              onChanged: (url) => ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(url: url)),
            ).pb(20).pt(20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Credentials (Optional)',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.start,
                ),
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
                      onPressed: () => ref.read(showPasswordStateProvider.notifier).update((state) => !state),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: ref.watch(showPasswordStateProvider),
                  onChanged: (password) => ref.read(httpServerStateProvider.notifier).update((state) => state.copyWith(password: password)),
                ).pb(10).pt(5),
              ],
            ),
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
                    LoadingScreen(context).show();
                    ref.read(contentControllerProvider).getPageContent().then((_) async {
                      ToastDialog(context).show(type: ToastType.success, text: 'Success', extent: true);

                      // save server details into shared preferences
                      ref.read(contentControllerProvider).updateServerList();
                    }).catchError((err, st) {
                      ToastDialog(context).show(type: ToastType.error, text: 'Error', extent: true);
                    });
                  },
                )
              ],
            )
          ],
        ).pa(20),
      );
    },
  );
}