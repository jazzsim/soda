import 'package:flutter/material.dart';
import 'package:soda/widgets/extensions/padding.dart';

extension WidgetRowExtension on Widget {
  Widget btnRow() {
    return Row(
      children: [
        Expanded(
          child: px(40),
        ),
      ],
    );
  }
}
