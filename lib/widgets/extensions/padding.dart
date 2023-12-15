import 'package:flutter/material.dart';

extension WidgetPaddingExtension on Widget {
  Widget pa(double padding) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: this,
    );
  }

  Widget pl(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(padding, 0, 0, 0),
      child: this,
    );
  }

  Widget pt(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, padding, 0, 0),
      child: this,
    );
  }

  Widget pr(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, padding, 0),
      child: this,
    );
  }

  Widget pb(double padding) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0, 0, padding),
      child: this,
    );
  }

  Widget px(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  Widget py(double padding) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }

  Widget pltrb(double leftpad, double toppad, double rightpad, double bottompad) {
    return Padding(
      padding: EdgeInsets.fromLTRB(leftpad, toppad, rightpad, bottompad),
      child: this,
    );
  }

}
