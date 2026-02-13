import 'package:flutter/material.dart';

import 'gtween.dart';

/// GSAP-style timeline: sequence multiple tweens, control as one.
class GTimeline {
  GTimeline({
    required TickerProvider vsync,
    this.onComplete,
    this.paused = false,
  }) : _vsync = vsync;

  final VoidCallback? onComplete;
  final bool paused;
  final TickerProvider _vsync;
  AnimationController? _controller;
  final List<_TimelineEntry> _entries = [];
  bool _built = false;
  bool _killed = false;

  /// Total duration of the timeline in seconds (latest end time of any entry).
  double get totalDurationSeconds {
    if (_entries.isEmpty) return 0;
    double end = 0;
    for (final e in _entries) {
      final t = e.startTime + e.duration;
      if (t > end) end = t;
    }
    return end;
  }

  Duration get totalDuration =>
      Duration(milliseconds: (totalDurationSeconds * 1000).round());

  /// Current progress 0.0 → 1.0.
  double get progress {
    final c = _controller;
    if (c == null || totalDurationSeconds <= 0) return 1.0;
    return (c.value * totalDurationSeconds) / totalDurationSeconds;
  }

  void _ensureBuilt() {
    if (_built) return;
    _built = true;
    final total = totalDuration;
    if (total.inMilliseconds > 0) {
      _controller = AnimationController(
        vsync: _vsync,
        duration: total,
        debugLabel: 'GTimeline',
      )..addStatusListener((s) {
          if (s == AnimationStatus.completed) onComplete?.call();
        })
        ..addListener(_driveTweens);
      if (!paused) _controller!.forward();
    }
  }

  /// Add a tween that starts at [start] seconds. Returns the same [Gtween].
  Gtween add(Gtween tween, {double start = 0}) {
    if (_killed) return tween;
    _entries.add(_TimelineEntry(
      startTime: start,
      duration: tween.duration.inMilliseconds / 1000.0,
      tween: tween,
    ));
    tween.pause();
    _built = false;
    _ensureBuilt();
    return tween;
  }

  /// Add a callback at [time] (in seconds).
  void addCallback(double time, VoidCallback callback) {
    _entries.add(_TimelineEntry(
      startTime: time,
      duration: 0,
      callback: callback,
    ));
    _built = false;
  }

  void play() {
    if (_killed) return;
    _ensureBuilt();
    _controller?.forward();
  }

  void pause() {
    _controller?.stop();
  }

  void seek(double progress) {
    if (_killed) return;
    _ensureBuilt();
    final c = _controller;
    if (c != null) c.value = progress.clamp(0.0, 1.0);
  }

  void _driveTweens() {
    final c = _controller;
    if (c == null) return;
    final t = c.value * totalDurationSeconds;
    for (final e in _entries) {
      if (e.tween != null) {
        final localStart = e.startTime;
        final localEnd = localStart + e.duration;
        if (t >= localEnd) {
          e.tween!.seek(1.0);
        } else if (t > localStart && e.duration > 0) {
          e.tween!.seek((t - localStart) / e.duration);
        } else {
          e.tween!.seek(0.0);
        }
      }
    }
  }

  void kill() {
    _killed = true;
    _controller?.removeListener(_driveTweens);
    for (final e in _entries) {
      e.tween?.kill();
    }
    _controller?.dispose();
    _controller = null;
  }
}

class _TimelineEntry {
  _TimelineEntry({
    required this.startTime,
    required this.duration,
    this.tween,
    this.callback,
  });
  final double startTime;
  final double duration;
  final Gtween? tween;
  final VoidCallback? callback;
}
