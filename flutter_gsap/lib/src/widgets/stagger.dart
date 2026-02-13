import 'dart:ui' show Offset;

import 'package:flutter/widgets.dart';

import '../eases.dart';
import 'scroll_animate.dart';

/// Stagger: wrap multiple children and animate each with [staggerDelay] between indices.
class GStagger extends StatelessWidget {
  const GStagger({
    super.key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.duration = const Duration(milliseconds: 500),
    this.offset = const Offset(0, 30),
    this.beginScale = 1.0,
    this.endScale = 1.0,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.curve = GEase.defaultEase,
    this.animateOnce = true,
    this.scrub = false,
  });

  final List<Widget> children;
  final Duration staggerDelay;
  final Duration duration;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;
  final Curve curve;
  final bool animateOnce;
  final bool scrub;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(children.length, (i) {
        return GScrollAnimate(
          key: ValueKey(i),
          duration: duration,
          delay: Duration(milliseconds: staggerDelay.inMilliseconds * i),
          offset: offset,
          beginScale: beginScale,
          endScale: endScale,
          beginOpacity: beginOpacity,
          endOpacity: endOpacity,
          curve: curve,
          animateOnce: animateOnce,
          scrub: scrub,
          child: children[i],
        );
      }),
    );
  }
}
