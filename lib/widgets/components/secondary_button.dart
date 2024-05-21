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

class WebSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Icon? icon;
  final String text;
  const WebSecondaryButton(this.text, {super.key, this.icon, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: 120,
      child: FilledButton.tonal(
        style: FilledButton.styleFrom(
          minimumSize: const Size(180, 55),
          maximumSize: const Size(180, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              4,
            ),
          ),
        ),
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
      ),
    );
  }
}
