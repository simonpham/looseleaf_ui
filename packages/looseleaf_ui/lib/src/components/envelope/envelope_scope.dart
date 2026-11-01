import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';

/// What an `Envelope` hands its parts: what it is made of, its seed and
/// tilt, whether it is open, and how to open or close it.
class EnvelopeScope extends InheritedWidget {
  const EnvelopeScope({
    super.key,
    required this.stock,
    required this.stamp,
    required this.postmark,
    required this.airmail,
    required this.seed,
    required this.tilt,
    required this.open,
    required this.disabled,
    required this.toggle,
    required super.child,
  });

  /// The envelope's paper.
  final StockName stock;

  /// The stamp's colour; none when null.
  final Accent? stamp;

  /// Whether the stamp is cancelled.
  final bool postmark;

  /// Whether the airmail border is drawn.
  final bool airmail;

  /// The envelope's seed; the front draws from it too.
  final String seed;

  /// The turn of the drawings, in radians.
  final double tilt;

  /// Whether the letter is out.
  final bool open;

  /// Whether the envelope is sealed.
  final bool disabled;

  /// Opens a closed envelope and closes an open one.
  final VoidCallback toggle;

  /// The nearest envelope's scope, if any.
  static EnvelopeScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EnvelopeScope>();

  @override
  bool updateShouldNotify(EnvelopeScope oldWidget) =>
      oldWidget.stock != stock ||
      oldWidget.stamp != stamp ||
      oldWidget.postmark != postmark ||
      oldWidget.airmail != airmail ||
      oldWidget.seed != seed ||
      oldWidget.tilt != tilt ||
      oldWidget.open != open ||
      oldWidget.disabled != disabled ||
      oldWidget.toggle != toggle;
}

/// The size of an `EnvelopeFront`, for parts placed by a share of it.
class EnvelopeFrontScope extends InheritedWidget {
  const EnvelopeFrontScope({
    super.key,
    required this.size,
    required super.child,
  });

  /// The front panel's size.
  final Size size;

  /// The nearest front's scope, if any.
  static EnvelopeFrontScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EnvelopeFrontScope>();

  @override
  bool updateShouldNotify(EnvelopeFrontScope oldWidget) =>
      oldWidget.size != size;
}
