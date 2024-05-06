import 'package:flutter/material.dart';

extension WidgetPaddingExtension on Widget {
  Widget pa(num padding) {
    return Padding(
      padding: EdgeInsets.all(padding.toDouble()),
      child: this,
    );
  }

  Widget pl(num padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding.toDouble(), 0, 0, 0),
      child: this,
    );
  }

  Widget pt(num padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, padding.toDouble(), 0, 0),
      child: this,
    );
  }

  Widget pr(num padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, padding.toDouble(), 0),
      child: this,
    );
  }

  Widget pb(num padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, padding.toDouble()),
      child: this,
    );
  }

  Widget px(num padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding.toDouble()),
      child: this,
    );
  }

  Widget py(num padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding.toDouble()),
      child: this,
    );
  }

  Widget pltrb(num leftpad, num toppad, num rightpad, num bottompad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftpad.toDouble(), toppad.toDouble(), rightpad.toDouble(), bottompad.toDouble()),
      child: this,
    );
  }

}
