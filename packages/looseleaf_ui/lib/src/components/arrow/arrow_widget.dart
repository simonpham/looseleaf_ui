import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart'
    show
        ArrowBend,
        ArrowCurve,
        ArrowDirection,
        ArrowHead,
        ArrowParams,
        MarkPen,
        MarkWeight,
        arrowRecipe;
import 'package:looseleaf_ui/src/components/arrow/arrow.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn arrow in an 80 × 40 box: straight, bowed or curled, in any
/// of eight directions, with an optional handwritten [label] behind its
/// tail. With [pointAt] it sits in a 24 px box and aims at that widget.
///
/// ```dart
/// const Arrow(direction: .left, curve: .curved, label: Text('ha, true'))
/// ```
///
/// Mirrors upstream `src/components/ui/arrow.tsx`.
class Arrow extends StatefulWidget {
  const Arrow({
    super.key,
    this.direction = ArrowDirection.right,
    this.curve = ArrowCurve.straight,
    this.head = ArrowHead.v,
    this.tone = MarkPen.ink,
    this.weight = MarkWeight.regular,
    this.bend = ArrowBend.up,
    this.mirror = true,
    this.pointAt,
    this.gap = Spacing.d6,
    this.label,
    this.animate = false,
    this.show = true,
    this.delay = Duration.zero,
    this.seed,
  });

  final ArrowDirection direction;
  final ArrowCurve curve;
  final ArrowHead head;
  final MarkPen tone;
  final MarkWeight weight;

  /// Which way a bowed arrow bends.
  final ArrowBend bend;

  /// Flip the direction in right-to-left text.
  final bool mirror;

  /// The widget to aim at; the arrow stops [gap] short of its edge. Until
  /// both are laid out the arrow is not drawn.
  final GlobalKey? pointAt;
  final double gap;

  /// A handwritten note at the tail, usually a [Text].
  final Widget? label;

  /// Hold the arrow back and draw it on once shown. Reduced motion just
  /// shows it.
  final bool animate;

  /// Show or hide the arrow, keeping its room.
  final bool show;

  /// The wait before the arrow draws on.
  final Duration delay;

  /// Pins the hand.
  final String? seed;

  @override
  State<Arrow> createState() => _ArrowState();
}

class _ArrowState extends State<Arrow> with InkSeed {
  Offset? _vector;

  void _aim() {
    final target = widget.pointAt?.currentContext?.findRenderObject();
    final host = context.findRenderObject();
    if (target is! RenderBox || host is! RenderBox) return;
    if (!target.hasSize || !host.hasSize) return;
    final next = arrowVector(
      host.localToGlobal(Offset.zero) & host.size,
      target.localToGlobal(Offset.zero) & target.size,
      widget.gap,
    );
    if (next == _vector) return;
    setState(() => _vector = next);
  }

  @override
  Widget build(BuildContext context) {
    final aimed = widget.pointAt != null;
    if (aimed) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) _aim();
      });
    }
    final vector = _vector;
    final params = ArrowParams(
      direction: widget.direction,
      curve: widget.curve,
      head: widget.head,
      tone: widget.tone,
      weight: widget.weight,
      bend: widget.bend,
      mirror: widget.mirror,
      dx: switch (aimed) {
        true => vector?.dx,
        false => null,
      },
      dy: switch (aimed) {
        true => vector?.dy,
        false => null,
      },
      animate: widget.animate,
    );
    final room = switch (aimed) {
      true => const SizedBox.square(dimension: Spacing.d24),
      false => const SizedBox(width: Spacing.d80, height: Spacing.d40),
    };
    final ready = widget.show && !(aimed && vector == null);
    final label = widget.label;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        switch (ready) {
          true => IgnorePointer(
            child: ExcludeSemantics(
              child: InkMarkSurface(
                source: RecipeInkSource(
                  arrowRecipe,
                  params,
                  json: params.toJson(),
                ),
                seed: inkSeed(widget.seed),
                animate: widget.animate,
                delay: widget.delay,
                child: room,
              ),
            ),
          ),
          false => room,
        },
        if (label != null) _label(context, label, aimed: aimed),
      ],
    );
  }

  Widget _label(BuildContext context, Widget label, {required bool aimed}) {
    final theme = LooseleafTheme.of(context);
    final text = DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: 20,
        cssLineHeight: 1,
        color: theme.colors.inkYou,
      ),
      softWrap: false,
      child: label,
    );
    const beside = Spacing.d80 + Spacing.d8;
    const wide = Spacing.d80 * 4;
    if (aimed) {
      return PositionedDirectional(
        start: Spacing.d24 + Spacing.d8,
        top: 0,
        bottom: 0,
        child: Center(child: text),
      );
    }
    return switch (widget.direction) {
      ArrowDirection.right => PositionedDirectional(
        end: beside,
        top: 0,
        bottom: 0,
        child: Center(child: text),
      ),
      ArrowDirection.left => PositionedDirectional(
        start: beside,
        top: 0,
        bottom: 0,
        child: Center(child: text),
      ),
      ArrowDirection.up => Positioned(
        top: Spacing.d40 + Spacing.d4,
        left: -wide,
        right: -wide,
        child: Align(alignment: Alignment.topCenter, child: text),
      ),
      ArrowDirection.down => Positioned(
        bottom: Spacing.d40 + Spacing.d4,
        left: -wide,
        right: -wide,
        child: Align(alignment: Alignment.bottomCenter, child: text),
      ),
      ArrowDirection.upRight => PositionedDirectional(
        end: beside,
        bottom: 0,
        child: text,
      ),
      ArrowDirection.upLeft => PositionedDirectional(
        start: beside,
        bottom: 0,
        child: text,
      ),
      ArrowDirection.downRight => PositionedDirectional(
        end: beside,
        top: 0,
        child: text,
      ),
      ArrowDirection.downLeft => PositionedDirectional(
        start: beside,
        top: 0,
        child: text,
      ),
    };
  }
}
