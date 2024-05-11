import 'package:flutter/material.dart';
import 'package:soda/widgets/extensions/padding.dart';

extension WidgetRowExtension on Widget {
  Widget btnRow([double padding = 40]) {
    return Row(
      children: [
        Expanded(
          child: px(padding),
        ),
      ],
    );
  }
}
