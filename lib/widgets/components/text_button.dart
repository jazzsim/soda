import 'package:flutter/material.dart';

class CTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const CTextButton(this.text, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
