import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soda/widgets/components/dialogs/loading_dialog.dart';
import 'package:soda/widgets/extensions/padding.dart';

enum ToastType { success, warning, error }

class ToastDialog {
  final BuildContext context;
  ToastDialog(this.context);

  void show({ToastType type = ToastType.success, String? text, bool extent = false}) {
    // close loading dialog if exist
    if (ModalRoute.of(context)?.isCurrent != true) {
      LoadingScreen(context).hide();
    }

    Timer closingTimer = Timer(Duration(seconds: extent ? 4 : 2), () {
      try {
        Navigator.of(context).pop();
        // ignore: empty_catches
      } catch (e) {}
    });
    showDialog(
        barrierDismissible: true,
        barrierColor: Colors.transparent,
        context: context,
        builder: (_) {
          closingTimer;
          return PopScope(
            onPopInvoked: (_) {
              closingTimer.cancel();
            },
            child: Padding(
              padding: text?.isEmpty ?? true ? EdgeInsets.all(MediaQuery.of(context).size.width * 0.22) : EdgeInsets.all(MediaQuery.of(context).size.width * 0.2),
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
                          children: dialogMessage(type, text),
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

  List<Widget> dialogMessage(ToastType type, String? text) {
    List<Widget> widgetList = [];
    switch (type) {
      case ToastType.success:
        widgetList.add(
          const Icon(
            Icons.check_circle_outline,
            size: 45.0,
            color: Colors.lightGreenAccent,
          ).pltrb(0, 8, 0, 8),
        );
        break;
      case ToastType.warning:
        widgetList.add(
          const Icon(
            Icons.warning_amber_rounded,
            size: 45.0,
            color: Colors.yellowAccent,
          ).pltrb(0, 8, 0, 8),
        );
        break;
      case ToastType.error:
        widgetList.add(
          const Icon(
            Icons.error_outline,
            size: 45.0,
            color: Colors.redAccent,
          ).pltrb(0, 8, 0, 8),
        );
        break;
      default:
    }

    if (text?.isNotEmpty ?? false) {
      widgetList.add(Text(
        text!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15.0,
          fontWeight: FontWeight.bold,
        ),
      ).pltrb(8, 0, 8, 8));
    }
    return widgetList;
  }

  void hide() {
    Navigator.of(context).pop();
  }
}
