import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hang tag: cut card with clipped corners ([TagShape.price]), an arched
/// top ([TagShape.round]) or a luggage tag's clipped end
/// ([TagShape.luggage], hung from the start edge, mirrored right to left),
/// with a hole, its reinforcing patch, an [eyelet] and a loop of [twine]
/// reaching [string] px out. The tag keeps that much margin on its hanging
/// side. The whole silhouette is one drawn sheet that turns on its eyelet
/// (a seeded turn within 2°, flat when calm); the content stays upright.
///
/// [children] ([LabelTagTitle], [LabelTagDescription], [LabelTagPrice])
/// stack under the eyelet on a 128 px wide, at least 160 px tall tag, or
/// sit in a row on a 96 px tall, at least 176 px wide luggage tag.
///
/// With [onPressed] the tag is a button (upstream `asChild` with a link or
/// a button): tap, Enter and Space press it, hovering swings it 2.6° on its
/// eyelet and lights a glint on the metal.
///
/// ```dart
/// const LabelTag(
///   twine: Accent.tomato,
///   children: [
///     LabelTagTitle(Text('Sale')),
///     LabelTagDescription(Text('while stocks last')),
///     LabelTagPrice(Text('12.00')),
///   ],
/// )
/// ```
///
/// Mirrors `LabelTag` in upstream `src/components/ui/label-tag.tsx`.
class LabelTag extends StatefulWidget {
  const LabelTag({
    super.key,
    this.stock = StockName.kraft,
    this.shape = TagShape.price,
    this.string = defaultString,
    this.twine,
    this.eyelet = TagEyelet.brass,
    this.width,
    this.height,
    this.tilt = true,
    this.tiltDegrees,
    this.onPressed,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
    this.children = const [],
  });

  /// How far the twine hangs out by default.
  static const double defaultString = 36;

  /// The largest seeded turn, in degrees.
  static const double tiltMax = 2;

  /// The swing on hover, in degrees.
  static const double swing = -2.6;

  /// What the tag is cut from.
  final StockName stock;

  /// The cut.
  final TagShape shape;

  /// How far the loop of twine hangs out, in px.
  final double string;

  /// The string's colour; natural twine when null.
  final Accent? twine;

  /// The metal ring in the hole, or a bare hole.
  final TagEyelet eyelet;

  /// The tag's width: fixed (128 by default) for the hanging shapes, the
  /// least width (176) for a luggage tag.
  final double? width;

  /// The tag's height: the least height (160 by default) for the hanging
  /// shapes, fixed (96) for a luggage tag.
  final double? height;

  /// False hangs it straight.
  final bool tilt;

  /// A fixed turn in degrees, clamped to the tilt budget; seeded within 2°
  /// when null.
  final double? tiltDegrees;

  /// Makes the tag a button, called on tap, Enter and Space.
  final VoidCallback? onPressed;

  /// Pins the cut, the twine and the turn.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name, for a pressable tag or a tag read as one group.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  /// The parts.
  final List<Widget> children;

  @override
  State<LabelTag> createState() => _LabelTagState();
}

class _LabelTagState extends State<LabelTag> with InkSeed {
  bool get _horizontal => widget.shape == TagShape.luggage;

  Offset _pivot(Size size, TextDirection direction) {
    final eyelet = labelTag.eyelet;
    return switch ((widget.shape, direction)) {
      (TagShape.luggage, TextDirection.ltr) => Offset(
        eyelet + 2,
        size.height / 2,
      ),
      (TagShape.luggage, TextDirection.rtl) => Offset(
        size.width - eyelet - 2,
        size.height / 2,
      ),
      (TagShape.round, _) => Offset(size.width / 2, eyelet + 2),
      (TagShape.price, _) => Offset(size.width / 2, eyelet),
    };
  }

  EdgeInsetsDirectional get _padding => switch (widget.shape) {
    TagShape.luggage => const EdgeInsetsDirectional.fromSTEB(
      Spacing.d44,
      Spacing.d12,
      Spacing.d20,
      Spacing.d12,
    ),
    TagShape.round => const EdgeInsetsDirectional.fromSTEB(
      Spacing.d12,
      Spacing.d48,
      Spacing.d12,
      Spacing.d16,
    ),
    TagShape.price => const EdgeInsetsDirectional.fromSTEB(
      Spacing.d12,
      Spacing.d44,
      Spacing.d12,
      Spacing.d16,
    ),
  };

  Widget _content() {
    if (_horizontal) {
      return SizedBox(
        height: widget.height ?? Spacing.d96,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: widget.width ?? Spacing.d176),
          child: IntrinsicWidth(
            child: Padding(
              padding: _padding,
              child: Row(
                spacing: Spacing.d8,
                children: widget.children,
              ),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: widget.width ?? Spacing.d128,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: widget.height ?? Spacing.d160),
        child: IntrinsicHeight(
          child: Padding(
            padding: _padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.d4,
              children: widget.children,
            ),
          ),
        ),
      ),
    );
  }

  Widget _tag(BuildContext context, Set<InkState> states) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final swings =
        widget.onPressed != null &&
        !PaperInk.calm(theme) &&
        states.contains(InkState.hovered);
    final degrees = switch (widget.tilt) {
      false => 0.0,
      true => widget.tiltDegrees ?? tiltFor(seed, LabelTag.tiltMax),
    };
    final angle = switch (swings) {
      true => LabelTag.swing * math.pi / 180,
      false => PaperInk.tilt(context, degrees),
    };
    final params = LabelTagParams(
      stock: widget.stock,
      shape: widget.shape,
      string: widget.string,
      twine: widget.twine,
      eyelet: widget.eyelet,
    );
    final source = RecipeInkSource(
      labelTagRecipe,
      params,
      json: params.toJson(),
    );
    final direction = Directionality.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, constraints) => TweenAnimationBuilder<double>(
              tween: Tween(end: angle),
              duration: InkMotion.of(context, InkMotion.hover),
              curve: InkMotion.settle,
              builder: (context, turn, child) => Transform(
                transform: Matrix4.rotationZ(turn),
                origin: _pivot(constraints.biggest, direction),
                child: child,
              ),
              child: InkSurface(
                source: source,
                seed: seed,
                states: states,
                still: true,
              ),
            ),
          ),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(color: theme.colors.ink),
          child: _content(),
        ),
        if (states.contains(InkState.focused))
          Positioned(
            left: -Spacing.d4,
            top: -Spacing.d4,
            right: -Spacing.d4,
            bottom: -Spacing.d4,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: theme.colors.focus,
                    width: Spacing.d2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final margin = switch (_horizontal) {
      true => EdgeInsetsDirectional.only(start: widget.string),
      false => EdgeInsetsDirectional.only(top: widget.string),
    };
    final onPressed = widget.onPressed;
    if (onPressed == null) {
      return Padding(
        padding: margin,
        child: Semantics(
          container: true,
          label: widget.semanticLabel,
          child: _tag(context, widget.forcedStates),
        ),
      );
    }
    return Padding(
      padding: margin,
      child: Semantics(
        container: true,
        button: true,
        label: widget.semanticLabel,
        child: InkInteraction(
          onActivate: onPressed,
          states: widget.forcedStates,
          focusNode: widget.focusNode,
          autofocus: widget.autofocus,
          builder: _tag,
        ),
      ),
    );
  }
}
