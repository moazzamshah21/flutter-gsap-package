import 'dart:ui' show Offset;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../eases.dart';
import '../scroll_trigger.dart';

/// GSAP-style scroll-triggered animation: fade, slide, scale when entering viewport.
/// Set [scrub] true to tie progress to scroll (reverse when scrolling up).
class GScrollAnimate extends StatefulWidget {
  const GScrollAnimate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.offset = const Offset(0, 50),
    this.beginScale = 1.0,
    this.endScale = 1.0,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.curve = GEase.defaultEase,
    this.animateOnce = true,
    this.scrub = false,
    this.scrubSmoothness = 0.0,
    this.start = 0.0,
    this.end = 1.0,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;
  final Curve curve;
  final bool animateOnce;
  final bool scrub;
  final double scrubSmoothness;
  final double start;
  final double end;

  @override
  State<GScrollAnimate> createState() => _GScrollAnimateState();
}

class _GScrollAnimateState extends State<GScrollAnimate> {
  double _progress = 0.0;
  bool _hasAnimated = false;
  ScrollPosition? _position;
  final GlobalKey _key = GlobalKey();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position = Scrollable.maybeOf(context)?.position;
  }

  void _onScroll() {
    if (!mounted || _position == null) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final viewport = RenderAbstractViewport.of(box);
    if (viewport == null) return;
    final viewportRect = box.localToGlobal(Offset.zero, ancestor: viewport);
    final viewportHeight = viewport.paintBounds.size.height;
    final scrollOffset = _position!.pixels;
    final triggerTop = viewportRect.dy + scrollOffset;
    final triggerHeight = box.size.height;
    final data = ScrollTriggerData(
      scrollOffset: scrollOffset,
      viewportHeight: viewportHeight,
      contentHeight: _position!.maxScrollExtent + viewportHeight,
      triggerOffset: triggerTop - viewportHeight,
      triggerHeight: triggerHeight,
    );
    double p = data.progressScroll();
    p = (p - widget.start) / (widget.end - widget.start).clamp(0.001, 1.0);
    p = p.clamp(0.0, 1.0);
    if (widget.scrub) {
      setState(() => _progress = p);
    } else if (!widget.animateOnce || !_hasAnimated) {
      if (p > 0) {
        setState(() {
          _progress = 1.0;
          _hasAnimated = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        _onScroll();
        return false;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
          return _AnimatedChild(
            key: _key,
            progress: _progress,
            duration: widget.duration,
            delay: widget.delay,
            curve: widget.curve,
            offset: widget.offset,
            beginScale: widget.beginScale,
            endScale: widget.endScale,
            beginOpacity: widget.beginOpacity,
            endOpacity: widget.endOpacity,
            scrub: widget.scrub,
            child: widget.child,
          );
        },
      ),
    );
  }
}

class _AnimatedChild extends StatelessWidget {
  const _AnimatedChild({
    super.key,
    required this.progress,
    required this.duration,
    required this.delay,
    required this.curve,
    required this.offset,
    required this.beginScale,
    required this.endScale,
    required this.beginOpacity,
    required this.endOpacity,
    required this.scrub,
    required this.child,
  });

  final double progress;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final Offset offset;
  final double beginScale;
  final double endScale;
  final double beginOpacity;
  final double endOpacity;
  final bool scrub;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double t = progress;
    if (!scrub) {
      if (t <= 0) {
        t = 0;
      } else {
        t = curve.transform(t);
      }
    } else {
      t = curve.transform(t);
    }
    final opacity = beginOpacity + (endOpacity - beginOpacity) * t;
    final translate = Offset(
      offset.dx * (1 - t),
      offset.dy * (1 - t),
    );
    final scale = beginScale + (endScale - beginScale) * t;
    return Opacity(
      opacity: opacity.clamp(0.0, 1.0),
      child: Transform.translate(
        offset: translate,
        child: Transform.scale(
          scale: scale,
          child: child,
        ),
      ),
    );
  }
}
