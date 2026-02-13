import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// ScrollTrigger: ties animation progress to scroll position (GSAP ScrollTrigger style).
/// Use [ScrollTriggerController] to drive a tween/timeline from scroll, or use
/// [GScrollTrigger] widget for declarative scroll-linked animations.
class ScrollTriggerController extends ChangeNotifier {
  ScrollTriggerController({
    this.start = 0.0,
    this.end = 1.0,
    this.scrub = false,
    this.scrubSmoothness = 0.0,
    this.pin = false,
  });

  /// Start progress (0–1) when trigger activates.
  double start;
  /// End progress (0–1) when trigger completes.
  double end;
  /// If true, animation progress follows scroll (scrub). If [scrubSmoothness] > 0, smooth follow.
  bool scrub;
  /// Smooth follow in seconds when scrub is true (0 = instant).
  double scrubSmoothness;
  /// Pin the trigger element while in range (implemented by widget).
  bool pin;

  double _progress = 0.0;
  double _targetProgress = 0.0;

  double get progress => _progress;

  void setProgress(double value) {
    _targetProgress = value.clamp(0.0, 1.0);
    if (!scrub || scrubSmoothness == 0) {
      _progress = _targetProgress;
      notifyListeners();
    }
  }

  void tick(double dt) {
    if (scrub && scrubSmoothness > 0 && (_progress - _targetProgress).abs() > 0.001) {
      _progress += (_targetProgress - _progress) * math.min(1, dt / scrubSmoothness);
      notifyListeners();
    }
  }
}

/// Injected scroll position and viewport info for ScrollTrigger.
class ScrollTriggerData {
  ScrollTriggerData({
    required this.scrollOffset,
    required this.viewportHeight,
    required this.contentHeight,
    this.triggerOffset = 0.0,
    this.triggerHeight = 0.0,
  });

  final double scrollOffset;
  final double viewportHeight;
  final double contentHeight;
  final double triggerOffset;
  final double triggerHeight;

  /// Progress 0–1 based on when [triggerOffset] enters viewport.
  /// [start] and [end] are in 0–1 (e.g. start=0 "top of viewport", end=1 "bottom of viewport").
  double progressInViewport({double start = 0.0, double end = 1.0}) {
    final viewportTop = scrollOffset;
    final viewportBottom = scrollOffset + viewportHeight;
    final triggerTop = triggerOffset;
    final triggerBottom = triggerOffset + triggerHeight;
    final rangeStart = viewportTop + viewportHeight * start;
    final rangeEnd = viewportTop + viewportHeight * end;
    if (triggerBottom <= rangeStart) return 0.0;
    if (triggerTop >= rangeEnd) return 1.0;
    final span = rangeEnd - rangeStart;
    if (span <= 0) return 0.5;
    final visibleStart = math.max(triggerTop, rangeStart);
    final visibleEnd = math.min(triggerBottom, rangeEnd);
    return ((visibleStart - rangeStart) / span).clamp(0.0, 1.0);
  }

  /// Progress 0–1: 0 when trigger top hits viewport bottom, 1 when trigger bottom hits viewport top.
  double progressScroll() {
    final viewportTop = scrollOffset;
    final viewportBottom = scrollOffset + viewportHeight;
    final triggerTop = triggerOffset;
    final triggerBottom = triggerOffset + triggerHeight;
    if (triggerBottom <= viewportTop) return 0.0;
    if (triggerTop >= viewportBottom) return 1.0;
    final total = triggerHeight + viewportHeight;
    final passed = scrollOffset - (triggerOffset - viewportHeight);
    return (passed / total).clamp(0.0, 1.0);
  }
}
