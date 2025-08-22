
import 'dart:math' as math;
import 'package:flutter/material.dart';

class FlipAnimation extends StatefulWidget {
  final Widget child;
  final VoidCallback? onFlipDone;
  final AnimationController controller;

  const FlipAnimation({
    super.key,
    required this.child,
    required this.controller,
    this.onFlipDone,
  });

  @override
  State<FlipAnimation> createState() => _FlipAnimationState();
}

class _FlipAnimationState extends State<FlipAnimation> {
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: widget.controller,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onFlipDone?.call();
          // Optionally reset the controller if you want the animation to be repeatable
          // widget.controller.reset();
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final isFront = _animation.value < 0.5;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // Perspective
          ..rotateY(math.pi * _animation.value);

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: isFront
              ? widget.child
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi), // Flip back
                  alignment: Alignment.center,
                  child: widget.child,
                ),
        );
      },
    );
  }
}
