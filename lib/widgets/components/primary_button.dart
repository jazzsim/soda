import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  const PrimaryButton(this.text, {super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}

class WebPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon? icon;
  final String text;
  const WebPrimaryButton(this.text, {super.key, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
          minimumSize: const Size(180, 55),
          maximumSize: const Size(180, 55),
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              6,
            ),
          )),
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                icon!,
                Text(text),
              ],
            )
          : Text(text),
    );
  }
}
