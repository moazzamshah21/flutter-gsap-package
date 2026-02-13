import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Widget that rebuilds with scroll progress 0–1 as the trigger enters/leaves viewport.
/// Use [builder] to drive custom animations from [progress] (e.g. GSAP-style scrub).
class GScrollProgress extends StatefulWidget {
  const GScrollProgress({
    super.key,
    required this.builder,
    this.start = 0.0,
    this.end = 1.0,
  });

  final Widget Function(BuildContext context, double progress) builder;
  final double start;
  final double end;

  @override
  State<GScrollProgress> createState() => _GScrollProgressState();
}

class _GScrollProgressState extends State<GScrollProgress> {
  double _progress = 0.0;
  ScrollPosition? _position;
  final GlobalKey _key = GlobalKey();

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
    final viewportTop = scrollOffset;
    final viewportBottom = scrollOffset + viewportHeight;
    if (triggerHeight + viewportHeight <= 0) return;
    final total = triggerHeight + viewportHeight;
    final passed = scrollOffset - (triggerTop - viewportHeight);
    double p = (passed / total).clamp(0.0, 1.0);
    p = ((p - widget.start) / (widget.end - widget.start).clamp(0.001, 1.0))
        .clamp(0.0, 1.0);
    setState(() => _progress = p);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _position = Scrollable.maybeOf(context)?.position;
    _onScroll();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (n) {
        _onScroll();
        return false;
      },
      child: Builder(
        key: _key,
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
          return widget.builder(context, _progress);
        },
      ),
    );
  }
}
