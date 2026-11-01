import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/handwritten/handwritten.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A margin note: a few handwritten words in blue script and a drawn arrow
/// pointing away from them, at whatever sits in that [direction]. The
/// words sit on the arrow's tail.
///
/// With [animate] the words fade in after [delay] and the arrow draws on
/// 250 ms later; [show] false hides the note (toggle it to replay).
///
/// ```dart
/// Row(children: [Text('the total'), Callout('check the date!')])
/// Callout('so true', direction: ArrowDirection.down)
/// ```
///
/// Mirrors upstream `src/components/ui/callout.tsx`.
class Callout extends StatefulWidget {
  const Callout(
    this.text, {
    super.key,
    this.direction = ArrowDirection.left,
    this.curve = ArrowCurve.curved,
    this.head = ArrowHead.v,
    this.tone = MarkPen.blue,
    this.weight = MarkWeight.regular,
    this.bend = ArrowBend.up,
    this.arrow = true,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  /// The words.
  final String text;

  /// Where the arrow points.
  final ArrowDirection direction;
  final ArrowCurve curve;
  final ArrowHead head;

  /// The arrow's pen.
  final MarkPen tone;
  final MarkWeight weight;

  /// Which way a curved arrow bows.
  final ArrowBend bend;

  /// False leaves just the words.
  final bool arrow;

  /// Fades the words in and draws the arrow on, once mounted.
  final bool animate;

  /// False hides the note.
  final bool show;

  /// The wait before the words appear.
  final Duration delay;

  /// Pins the hand; the arrow is seeded `<seed>:arrow`.
  final String? seed;

  @override
  State<Callout> createState() => _CalloutState();
}

class _CalloutState extends State<Callout> with InkSeed {
  static const _arrowLag = Duration(milliseconds: 250);

  Timer? _timer;
  var _shown = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_shown || _timer != null) return;
    if (!widget.animate || InkMotion.reducedIn(context)) {
      _shown = true;
      return;
    }
    _timer = Timer(widget.delay, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _vertical => switch (widget.direction) {
    ArrowDirection.up || ArrowDirection.down => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    final theme = LooseleafTheme.of(context);
    final style = theme.typography.face(
      KevinSansFace.script,
      cssSize: 22,
      cssLineHeight: 1.05,
      color: theme.colors.inkYou,
    );
    final text = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: _ch(style, _vertical).ceilToDouble(),
      ),
      child: Handwritten(
        widget.text,
        style: style,
        seed: widget.seed,
        textAlign: switch (_vertical) {
          true => TextAlign.center,
          false => null,
        },
      ),
    );
    final words = AnimatedOpacity(
      opacity: switch (_shown) {
        true => 1,
        false => 0,
      },
      duration: InkMotion.of(context, InkMotion.sheet),
      curve: InkMotion.easeOut,
      child: text,
    );
    return Semantics(
      container: true,
      label: widget.text,
      excludeSemantics: true,
      child: _layout(words, switch (widget.arrow) {
        true => _arrow(),
        false => null,
      }),
    );
  }

  /// `max-w-[16ch]`, `max-w-[22ch]` when stacked: the width of that many
  /// zeros in [style].
  static double _ch(TextStyle style, bool vertical) {
    final painter = TextPainter(
      text: TextSpan(text: '0' * _chars(vertical), style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    final width = painter.width;
    painter.dispose();
    return width;
  }

  static int _chars(bool vertical) => switch (vertical) {
    true => 22,
    false => 16,
  };

  Widget _arrow() {
    final params = ArrowParams(
      direction: widget.direction,
      curve: widget.curve,
      head: widget.head,
      tone: widget.tone,
      weight: widget.weight,
      bend: widget.bend,
      mirror: true,
      animate: widget.animate,
    );
    return IgnorePointer(
      child: InkMarkSurface(
        source: RecipeInkSource(arrowRecipe, params, json: params.toJson()),
        seed: '${inkSeed(widget.seed)}:arrow',
        animate: widget.animate,
        delay: widget.delay + _arrowLag,
        child: const SizedBox(width: Spacing.d56, height: Spacing.d40),
      ),
    );
  }

  /// Upstream's `LAYOUT` table: the words on the arrow's tail.
  Widget _layout(Widget words, Widget? arrow) {
    final children = [words, ?arrow];
    final reversed = children.reversed.toList();
    Widget row(List<Widget> items, CrossAxisAlignment align) => Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: align,
      spacing: Spacing.d6,
      children: items,
    );
    Widget column(List<Widget> items) => Column(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.d2,
      children: items,
    );
    return switch (widget.direction) {
      ArrowDirection.right => row(children, CrossAxisAlignment.center),
      ArrowDirection.left => row(reversed, CrossAxisAlignment.center),
      ArrowDirection.down => column(children),
      ArrowDirection.up => column(reversed),
      ArrowDirection.downRight => row(children, CrossAxisAlignment.start),
      ArrowDirection.downLeft => row(reversed, CrossAxisAlignment.start),
      ArrowDirection.upRight => row(children, CrossAxisAlignment.end),
      ArrowDirection.upLeft => row(reversed, CrossAxisAlignment.end),
    };
  }
}
