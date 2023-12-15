import 'package:flutter/material.dart';

class COutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const COutlinedButton(this.text, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
