import 'dart:ui' show Offset;

import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';

import 'eases.dart';

/// GSAP-style tween: animate with duration, ease, callbacks.
/// Control with [play], [pause], [reverse], [seek], [progress], [kill].
/// For use with a [TickerProvider] (e.g. from State).
class Gtween {
  Gtween({
    required TickerProvider vsync,
    required this.duration,
    this.delay = Duration.zero,
    this.curve = GEase.defaultEase,
    this.onStart,
    this.onUpdate,
    this.onComplete,
    this.onReverseComplete,
    this.repeat = 0,
    this.yoyo = false,
    this.repeatDelay = Duration.zero,
    this.paused = false,
  })  : _vsync = vsync,
        _duration = duration,
        _delay = delay {
    _controller = AnimationController(
      vsync: vsync,
      duration: duration + delay,
      debugLabel: 'Gtween',
    );
    final delayT = delay.inMilliseconds / (duration + delay).inMilliseconds;
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayT, 1.0, curve: curve),
    );
    _controller.addStatusListener(_onStatus);
    _controller.addListener(_onTick);
    if (!paused) _playAfterDelay();
  }

  final Duration duration;
  final Duration delay;
  final Curve curve;
  final VoidCallback? onStart;
  final void Function(double progress)? onUpdate;
  final VoidCallback? onComplete;
  final VoidCallback? onReverseComplete;
  final int repeat;
  final bool yoyo;
  final Duration repeatDelay;
  final bool paused;

  final TickerProvider _vsync;
  final Duration _duration;
  final Duration _delay;

  late final AnimationController _controller;
  late final Animation<double> _anim;
  bool _startFired = false;
  int _repeatCount = 0;
  bool _killed = false;

  void _onStatus(AnimationStatus status) {
    if (_killed) return;
    if (status == AnimationStatus.completed) {
      if (repeat < 0 || _repeatCount < repeat) {
        _repeatCount++;
        Future.delayed(repeatDelay, () {
          if (_killed) return;
          if (yoyo && _repeatCount.isOdd) {
            _controller.reverse();
          } else {
            _controller.forward(from: 0);
          }
        });
      } else {
        onComplete?.call();
      }
    } else if (status == AnimationStatus.dismissed) {
      onReverseComplete?.call();
    }
  }

  void _onTick() {
    if (_killed) return;
    if (!_startFired && _controller.value > 0) {
      _startFired = true;
      onStart?.call();
    }
    onUpdate?.call(progress);
  }

  void _playAfterDelay() {
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(delay, () {
        if (!_killed) _controller.forward();
      });
    }
  }

  /// Current progress 0.0 → 1.0 (of the main tween, not delay).
  double get progress => _anim.value;

  /// Total duration including delay.
  Duration get totalDuration =>
      duration + delay + (repeat > 0 ? repeatDelay * repeat : Duration.zero);

  void play() {
    if (_killed) return;
    _controller.forward();
  }

  void pause() {
    _controller.stop();
  }

  void reverse() {
    if (_killed) return;
    _controller.reverse();
  }

  void seek(double progress) {
    if (_killed) return;
    progress = progress.clamp(0.0, 1.0);
    _controller.value = progress;
  }

  /// Set progress (0.0–1.0). Alias for [seek].
  void set progress(double value) => seek(value);

  void restart() {
    if (_killed) return;
    _controller.reset();
    _repeatCount = 0;
    _startFired = false;
    _controller.forward();
  }

  void kill() {
    if (_killed) return;
    _killed = true;
    _controller.removeStatusListener(_onStatus);
    _controller.removeListener(_onTick);
    _controller.dispose();
  }

  bool get isActive =>
      !_killed &&
      (_controller.isAnimating ||
          (_controller.value > 0 && _controller.value < 1));
}

/// Build a tween that animates [child] with opacity, offset, scale, rotation.
class GtweenWidget extends StatefulWidget {
  const GtweenWidget({
    super.key,
    required this.child,
    this.from = const GtweenProps(),
    this.to = const GtweenProps(),
    this.duration = const Duration(milliseconds: 600),
    this.delay = Duration.zero,
    this.curve = GEase.defaultEase,
    this.autoPlay = true,
    this.onComplete,
  });

  final Widget child;
  final GtweenProps from;
  final GtweenProps to;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final bool autoPlay;
  final VoidCallback? onComplete;

  @override
  State<GtweenWidget> createState() => _GtweenWidgetState();
}

class _GtweenWidgetState extends State<GtweenWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration + widget.delay,
    );
    final delayT = widget.delay.inMilliseconds /
        (widget.duration + widget.delay).inMilliseconds;
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Interval(delayT, 1.0, curve: widget.curve),
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onComplete?.call();
    });
    if (widget.autoPlay) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final t = _anim.value;
        final opacity =
            widget.from.opacity + (widget.to.opacity - widget.from.opacity) * t;
        final offset = Offset(
          widget.from.offset.dx +
              (widget.to.offset.dx - widget.from.offset.dx) * t,
          widget.from.offset.dy +
              (widget.to.offset.dy - widget.from.offset.dy) * t,
        );
        final scale =
            widget.from.scale + (widget.to.scale - widget.from.scale) * t;
        final rotation = widget.from.rotation +
            (widget.to.rotation - widget.from.rotation) * t;
        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: offset,
            child: Transform.scale(
              scale: scale,
              child: Transform.rotate(
                angle: rotation,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animatable properties (opacity, offset, scale, rotation).
class GtweenProps {
  const GtweenProps({
    this.opacity = 1.0,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  final double opacity;
  final Offset offset;
  final double scale;
  final double rotation;
}
