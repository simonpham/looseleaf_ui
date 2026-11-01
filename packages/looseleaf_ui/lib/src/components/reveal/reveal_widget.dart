import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart' show PaintKey;
import 'package:looseleaf_ui/src/components/reveal/reveal.dart';

/// Brings content onto the page once it appears: wiped in, soaked in like
/// wet ink, dropped, popped or tossed. A wipe can carry a fountain-pen
/// [nib] along its bottom edge; [Reveal.stagger] brings children in one
/// after another.
///
/// The content is laid out and read by screen readers from the start; only
/// its painting is animated. Reduced motion just shows it.
///
/// ```dart
/// Reveal(effect: .drop, child: Text('Hello'))
/// ```
///
/// Mirrors upstream `src/components/ui/reveal.tsx`. Upstream waits until
/// the content scrolls into view; this plays when it is first built, and a
/// new [Key] replays it.
class Reveal extends StatelessWidget {
  const Reveal({
    super.key,
    required Widget this.child,
    this.effect = RevealEffect.wipe,
    this.from = RevealFrom.start,
    this.delay = Duration.zero,
    this.nib = false,
    this.nibColor = PaintKey.tomato,
  }) : children = const [],
       stagger = Duration.zero,
       direction = Axis.vertical,
       spacing = 0,
       crossAxisAlignment = CrossAxisAlignment.start;

  /// Lays [children] out along [direction] and reveals them one after
  /// another, [stagger] apart (upstream `stagger`, at most 16 steps).
  const Reveal.stagger({
    super.key,
    required this.children,
    this.stagger = const Duration(milliseconds: 120),
    this.effect = RevealEffect.wipe,
    this.from = RevealFrom.start,
    this.delay = Duration.zero,
    this.direction = Axis.vertical,
    this.spacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : child = null,
       nib = false,
       nibColor = PaintKey.tomato;

  final Widget? child;
  final List<Widget> children;
  final RevealEffect effect;

  /// Which edge a wipe starts from.
  final RevealFrom from;

  /// The wait before revealing.
  final Duration delay;

  /// The wait between one child and the next.
  final Duration stagger;

  /// Draw a nib riding the wipe (only with [RevealEffect.wipe]).
  final bool nib;
  final PaintKey nibColor;

  final Axis direction;
  final double spacing;
  final CrossAxisAlignment crossAxisAlignment;

  static const int _maxSteps = 16;

  @override
  Widget build(BuildContext context) {
    final fromEnd = from == RevealFrom.end;
    final single = child;
    if (single == null) {
      return Flex(
        direction: direction,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        spacing: spacing,
        children: [
          for (final (index, item) in children.indexed)
            RevealMotion(
              effect: effect,
              fromEnd: fromEnd,
              delay: delay + stagger * (index % _maxSteps),
              child: item,
            ),
        ],
      );
    }
    final motion = RevealMotion(
      effect: effect,
      fromEnd: fromEnd,
      delay: delay,
      child: single,
    );
    if (!nib || effect != RevealEffect.wipe) return motion;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        motion,
        Positioned.fill(
          child: RevealNib(color: nibColor, delay: delay, fromEnd: fromEnd),
        ),
      ],
    );
  }
}

/// The edge a wipe starts from, in reading order.
enum RevealFrom { start, end }
