import 'package:flutter/material.dart';

/// GSAP-style ease names mapped to Flutter [Curve]s.
/// Use with [Gtween] and [GTimeline] for familiar easing.
class GEase {
  GEase._();

  static const Curve none = Curves.linear;
  static const Curve power1Out = Curves.easeOut;
  static const Curve power1In = Curves.easeIn;
  static const Curve power1InOut = Curves.easeInOut;
  static const Curve power2Out = Curves.easeOutCubic;
  static const Curve power2In = Curves.easeInCubic;
  static const Curve power2InOut = Curves.easeInOutCubic;
  static const Curve power3Out = Curves.easeOutCubic;
  static const Curve power3In = Curves.easeInCubic;
  static const Curve power3InOut = Curves.easeInOutCubic;
  static const Curve power4Out = Curves.easeOutQuart;
  static const Curve power4In = Curves.easeInQuart;
  static const Curve power4InOut = Curves.easeInOutQuart;

  static const Curve backOut = Curves.easeOutBack;
  static const Curve backIn = Curves.easeInBack;
  static const Curve backInOut = Curves.easeInOutBack;

  static const Curve elasticOut = Curves.elasticOut;
  static const Curve elasticIn = Curves.elasticIn;
  static const Curve elasticInOut = Curves.elasticInOut;

  static const Curve bounceOut = Curves.bounceOut;
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceInOut = Curves.bounceInOut;

  static const Curve expoOut = Curves.easeOutExpo;
  static const Curve expoIn = Curves.easeInExpo;
  static const Curve expoInOut = Curves.easeInOutExpo;

  static const Curve circOut = Curves.easeOutCirc;
  static const Curve circIn = Curves.easeInCirc;
  static const Curve circInOut = Curves.easeInOutCirc;

  /// Default ease (power1.out).
  static const Curve defaultEase = power1Out;
}
