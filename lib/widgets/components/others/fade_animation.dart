import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FadeTransitionWidget extends ConsumerStatefulWidget {
  final Widget child;
  final Duration fadeDuration;
  final Function()? onFade;

  const FadeTransitionWidget({
    super.key,
    required this.child,
    required this.fadeDuration,
    this.onFade,
  });

  @override
  ConsumerState<FadeTransitionWidget> createState() => _FadeTransitionWidgetState();
}

class _FadeTransitionWidgetState extends ConsumerState<FadeTransitionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_animationController.isDismissed) {
      // Start the fade-in animation
      _animationController.forward().then((_) {
        // Start a timer to trigger fade-out after 2 seconds
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) {
            setState(() {});
            _animationController.reverse();
            widget.onFade ?? ();
          }
        });
      });
    }
    return FadeTransition(
      opacity: _opacityAnimation,
      child: widget.child,
    );
  }
}
