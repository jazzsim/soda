import 'package:flutter/material.dart';
import 'package:soda/widgets/extensions/padding.dart';

enum ToastType { success, error }

void showToast(BuildContext context, ToastType type, String message, {bool? extent}) {
  // // close loading dialog if exist
  // if (ModalRoute.of(context)?.isCurrent != true) {
  //   LoadingScreen(context).hide();
  // }

  OverlayEntry overlayEntry;

  // Create a controller for the fade-out animation
  AnimationController controller = AnimationController(
    duration: Duration(milliseconds: extent ?? false ? 2800 : 1800),
    vsync: Overlay.of(context),
  );

  // Create a fade-out animation
  Animation<double> animation = Tween<double>(begin: 3.0, end: 0.0).animate(
    CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ),
  );

  // Show overlay with fade-out animation
  overlayEntry = OverlayEntry(
    builder: (BuildContext context) => Center(
      child: FadeTransition(
        opacity: animation,
        child: Material(
          color: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15.0),
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 200,
                minHeight: 100,
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(150, 0, 0, 0),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: overlayMessage(type, message),
              ),
            ),
          ).pa(20),
        ),
      ),
    ).pt(25),
  );

  // Insert overlay into the widget tree
  Overlay.of(context).insert(overlayEntry);

  // Start fade-out animation and remove overlay when completed
  controller.forward();
  controller.addStatusListener((status) {
    if (status == AnimationStatus.completed) {
      overlayEntry.remove();
      controller.dispose();
    }
  });
}

List<Widget> overlayMessage(ToastType type, String? text) {
  List<Widget> widgetList = [];
  switch (type) {
    case ToastType.success:
      widgetList.add(
        const Icon(
          Icons.check_circle_outline,
          size: 42.0,
          color: Colors.lightGreenAccent,
        ).pltrb(0, 8, 0, 8),
      );
      break;
    case ToastType.error:
      widgetList.add(
        const Icon(
          Icons.error_outline,
          size: 42.0,
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
