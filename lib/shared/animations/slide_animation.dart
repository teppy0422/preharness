
import 'package:flutter/material.dart';

class SlideAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSlideDone;
  final AnimationController controller;

  const SlideAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.onSlideDone,
  });

  @override
  State<SlideAnimation> createState() => _SlideAnimationState();
}

class _SlideAnimationState extends State<SlideAnimation> {
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onSlideDone?.call();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: widget.child,
    );
  }
}
