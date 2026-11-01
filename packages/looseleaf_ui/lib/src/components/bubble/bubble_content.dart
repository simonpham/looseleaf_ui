import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_creases.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_metrics.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_paper.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_scope.dart';
import 'package:looseleaf_ui/src/components/bubble/bubble_shape.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/message/message.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The body of a [Bubble] and the part that is drawn: real text with the
/// felt outline and fill behind it, or a [Paper] note or sticky note.
///
/// Its look comes from the enclosing [Bubble] (variant, side, shape, pen).
/// With [onPressed] it is a button (upstream `asChild` on a `<button>`):
/// drop lines on hover, a drawn focus ring, Enter and Space press it.
///
/// ```dart
/// Bubble(
///   variant: .outline,
///   align: .end,
///   tail: false,
///   children: [
///     BubbleContent(
///       seed: 'diff',
///       onPressed: () => pick('diff'),
///       child: const Text('Show me the diff'),
///     ),
///   ],
/// )
/// ```
///
/// Mirrors `BubbleContent` in upstream `src/components/ui/bubble.tsx`.
class BubbleContent extends StatefulWidget {
  const BubbleContent({
    super.key,
    required this.child,
    this.onPressed,
    this.paper = const BubblePaper(),
    this.padding,
    this.minHeight,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The words, usually a [Text].
  final Widget child;

  /// Makes the bubble a button; null keeps it a plain body.
  final VoidCallback? onPressed;

  /// The sheet of a note or sticky note.
  final BubblePaper paper;

  /// Overrides the density's padding (`px-4 py-2.5`).
  final EdgeInsetsGeometry? padding;

  /// A minimum height, like the docs' `min-h-14` notes.
  final double? minHeight;

  /// Pins the hand: the same seed always draws the same bubble.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// Names an interactive bubble when its content is not text.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<BubbleContent> createState() => _BubbleContentState();
}

class _BubbleContentState extends State<BubbleContent> with InkSeed {
  @override
  Widget build(BuildContext context) {
    final scope = BubbleScope.maybeOf(context);
    final variant = scope?.variant ?? BubbleVariant.primary;
    final shape = scope?.shape ?? BubbleShape.cloud;
    final theme = LooseleafTheme.of(context);
    final text = _text(theme, scope, variant, shape);
    if (shape != BubbleShape.cloud) {
      return _sheet(context, text, variant, shape);
    }
    if (variant == BubbleVariant.ghost) {
      return _interactive((states) => text(widget.child));
    }
    final padding =
        widget.padding ?? BubbleMetrics.padding.resolve(theme.density);
    final params = BubbleParams(
      variant: variant,
      tail: switch (scope?.align ?? ChatAlign.start) {
        ChatAlign.start => BubbleTail.start,
        ChatAlign.end => BubbleTail.end,
      },
      pen: scope?.pen ?? BubblePen.ink,
      interactive: widget.onPressed != null,
    );
    final InkSource source = RecipeInkSource(
      bubbleRecipe,
      params,
      json: params.toJson(),
    );
    final drawn = switch (scope?.tail ?? true) {
      true => source,
      false => WithoutPartInkSource(source, 'tail'),
    };
    return _interactive(
      (states) => InkSurface(
        source: drawn,
        seed: inkSeed(widget.seed),
        states: states,
        still: true,
        child: _sized(Padding(padding: padding, child: text(widget.child))),
      ),
    );
  }

  Widget Function(Widget) _text(
    LooseleafThemeData theme,
    BubbleScope? scope,
    BubbleVariant variant,
    BubbleShape shape,
  ) {
    final you = scope?.pen == BubblePen.you;
    final colors = theme.colors;
    final style = switch ((shape, you)) {
      (_, true) => BubbleMetrics.script(theme, colors.inkYou),
      (BubbleShape.cloud, false) => BubbleMetrics.hand(
        theme,
        BubbleMetrics.textColor(colors, variant),
      ),
      (_, false) => BubbleMetrics.script(theme, colors.ink),
    };
    return (child) => InkContent(style: style, child: child);
  }

  Widget _sized(Widget child) => switch (widget.minHeight) {
    final height? => ConstrainedBox(
      constraints: BoxConstraints(minHeight: height),
      child: child,
    ),
    null => child,
  };

  Widget _sheet(
    BuildContext context,
    Widget Function(Widget) text,
    BubbleVariant variant,
    BubbleShape shape,
  ) {
    final theme = LooseleafTheme.of(context);
    final sticky = shape == BubbleShape.sticky;
    final paper = widget.paper;
    final sheet = Paper(
      stock: switch (sticky) {
        true => BubbleMetrics.stickyStock(variant),
        false => BubbleMetrics.noteStock(variant),
      },
      curl: paper.curl,
      tilt: paper.tilt,
      tiltDegrees: paper.tiltDegrees,
      fastener: paper.fastener,
      tape: paper.tape,
      edge: paper.edge,
      seed: inkSeed(widget.seed),
      padding: widget.padding ?? BubbleMetrics.padding.resolve(theme.density),
      decor: switch (sticky) {
        true => null,
        false => const BubbleCreases(),
      },
      child: _sized(text(widget.child)),
    );
    return _interactive((states) => sheet);
  }

  Widget _interactive(Widget Function(Set<InkState> states) builder) {
    final onPressed = widget.onPressed;
    if (onPressed == null) return builder(widget.forcedStates);
    return Semantics(
      container: true,
      button: true,
      enabled: true,
      label: widget.semanticLabel,
      child: InkInteraction(
        onActivate: onPressed,
        states: widget.forcedStates,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => builder(states),
      ),
    );
  }
}
