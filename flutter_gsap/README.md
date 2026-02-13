# flutter_gsap

A **GSAP-style** animation package for Flutter: tweens, timelines, scroll-triggered animations, parallax, and stagger.

## Features

| Feature | Description |
|--------|-------------|
| **Gtween** | Animate with `duration`, `delay`, `curve`, `onComplete`, `repeat`, `yoyo`. Control with `play()`, `pause()`, `seek(progress)`, `kill()`. |
| **GTimeline** | Sequence multiple tweens; `add(tween, start: 0)`, `play()`, `pause()`, `seek()`. |
| **GScrollAnimate** | Trigger fade/slide/scale when widget enters viewport. Optional **scrub** (progress tied to scroll). |
| **GScrollProgress** | Builder that receives scroll progress `0.0 → 1.0` for custom scroll-driven animations. |
| **GParallax** | Move child at a different rate than scroll (`factor`). |
| **GStagger** | Stagger children with per-item delay. |
| **GEase** | GSAP-like curve names: `power1Out`, `backOut`, `elasticOut`, `bounceOut`, etc. |

## Installation

```yaml
dependencies:
  flutter_gsap:
    path: ../flutter_gsap  # or publish and use version
```

## Quick usage

### Scroll-triggered (animate once when in view)

```dart
ListView(
  children: [
    GScrollAnimate(
      offset: Offset(0, 80),
      duration: Duration(milliseconds: 800),
      child: Card(child: Text('Animates when visible')),
    ),
  ],
)
```

### Scroll-scrub (progress tied to scroll, like GSAP ScrollTrigger scrub)

```dart
GScrollAnimate(
  scrub: true,
  start: 0.0,
  end: 1.0,
  offset: Offset(100, 0),
  child: Image.network('...'),
)
```

### Staggered list

```dart
GStagger(
  staggerDelay: Duration(milliseconds: 100),
  children: [
    Tile(...),
    Tile(...),
    Tile(...),
  ],
)
```

### Parallax

```dart
GParallax(
  factor: 0.3,
  child: Image.asset('background.png'),
)
```

### Scroll progress builder (custom scrub animations)

```dart
GScrollProgress(
  builder: (context, progress) {
    return Transform.translate(
      offset: Offset(progress * 100, 0),
      child: Text('Moves with scroll'),
    );
  },
)
```

### Programmatic tween (with TickerProvider from State)

```dart
class _MyState extends State<MyPage> with SingleTickerProviderStateMixin {
  late Gtween _tween;

  @override
  void initState() {
    super.initState();
    _tween = Gtween(
      vsync: this,
      duration: Duration(seconds: 1),
      curve: GEase.elasticOut,
      onUpdate: (p) => setState(() {}),
      onComplete: () => print('Done'),
    );
  }

  @override
  void dispose() {
    _tween.kill();
    super.dispose();
  }
}
```

### Timeline

```dart
final tl = GTimeline(vsync: this);
tl.add(Gtween(vsync: this, duration: Duration(seconds: 1), ...), start: 0);
tl.add(Gtween(vsync: this, duration: Duration(seconds: 0.5), ...), start: 1.2);
tl.play();
```

## API overview

- **GEase** – `none`, `power1Out`, `power2InOut`, `backOut`, `elasticOut`, `bounceOut`, `expoOut`, `circOut`, etc.
- **Gtween** – `play()`, `pause()`, `reverse()`, `seek(progress)`, `progress`, `restart()`, `kill()`.
- **GTimeline** – `add(tween, start: 0)`, `addCallback(time, callback)`, `play()`, `pause()`, `seek(progress)`, `kill()`.
- **GScrollAnimate** – `duration`, `delay`, `offset`, `beginScale`/`endScale`, `beginOpacity`/`endOpacity`, `curve`, `animateOnce`, `scrub`, `start`/`end`.
- **GScrollProgress** – `builder(context, progress)`, `start`, `end`.
- **GParallax** – `factor`.
- **GStagger** – `children`, `staggerDelay`, `duration`, `offset`, etc.

## License

MIT.
