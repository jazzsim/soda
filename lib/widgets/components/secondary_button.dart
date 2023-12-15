import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const SecondaryButton(this.text, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
