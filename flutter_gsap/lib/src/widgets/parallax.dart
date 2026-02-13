import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Parallax: moves child at a different rate than scroll ([factor]).
/// factor > 1 = faster, 0 = fixed, < 0 = opposite direction.
class GParallax extends StatefulWidget {
  const GParallax({
    super.key,
    required this.child,
    this.factor = 0.5,
  });

  final Widget child;
  final double factor;

  @override
  State<GParallax> createState() => _GParallaxState();
}

class _GParallaxState extends State<GParallax> {
  double _offset = 0.0;
  ScrollPosition? _position;
  final GlobalKey _key = GlobalKey();

  void _onScroll() {
    if (!mounted || _position == null) return;
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final viewport = RenderAbstractViewport.of(box);
    if (viewport == null) return;
    final scrollOffset = _position!.pixels;
    setState(() {
      _offset = scrollOffset * widget.factor;
    });
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
        builder: (context) {
          WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
          return Transform.translate(
            key: _key,
            offset: Offset(0, -_offset * 0.5),
            child: widget.child,
          );
        },
      ),
    );
  }
}
