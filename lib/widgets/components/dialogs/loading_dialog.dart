import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'loading_view.dart';

class LoadingScreen {
  final BuildContext context;

  LoadingScreen(this.context);

  void show() {
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (_) {
          return PopScope(
            canPop: false,
            child: Padding(
              padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
              child: Consumer(
                builder: (context, ref, child) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    backgroundColor: const Color.fromARGB(150, 0, 0, 0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Container(
                        constraints: const BoxConstraints(minHeight: 90.0, minWidth: 120.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 8.0),
                              child: LoadingView(35),
                            ),
                            const Text(
                              'Loading',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white, fontSize: 15.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        });
  }

  void hide() {
    Navigator.of(context).pop();
  }
}
