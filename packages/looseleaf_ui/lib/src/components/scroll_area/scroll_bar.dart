import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A pencil scroll mark for [controller]'s scrollable: a faint gutter with
/// a graphite thumb that slides along it. Drag the thumb to scroll; tap
/// the gutter to page towards the tap. It shows while [visible].
///
/// [ScrollArea] places these itself; use one directly to mark a scrollable
/// of your own.
///
/// Mirrors `ScrollBar` in upstream `src/components/ui/scroll-area.tsx`.
class ScrollBar extends StatefulWidget {
  const ScrollBar({
    super.key,
    required this.controller,
    this.orientation = ScrollOrientation.vertical,
    this.visible = true,
    this.seed,
  });

  final ScrollController controller;
  final ScrollOrientation orientation;

  /// Fades the mark in and out (upstream `data-state=visible|hidden`).
  final bool visible;

  /// Pins the hand of the gutter and thumb.
  final String? seed;

  /// `w-2.5` / `h-2.5`: the bar's thickness.
  static const double thickness = Spacing.d10;

  /// Radix's smallest thumb.
  static const double minThumb = 18;

  @override
  State<ScrollBar> createState() => _ScrollBarState();
}

class _ScrollBarState extends State<ScrollBar> with InkSeed {
  bool _hovered = false;

  bool get _vertical => widget.orientation == ScrollOrientation.vertical;

  ScrollPosition? get _position => switch (widget.controller.hasClients) {
    true => widget.controller.position,
    false => null,
  };

  void _drag(double delta, double track, double thumb) {
    final position = _position;
    if (position == null || track <= thumb) return;
    final range = position.maxScrollExtent - position.minScrollExtent;
    position.jumpTo(
      (position.pixels + delta * range / (track - thumb)).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  void _page(double at, double thumbStart, double thumb) {
    final position = _position;
    if (position == null) return;
    final towardsEnd = at > thumbStart + thumb;
    final step =
        position.viewportDimension *
        switch (towardsEnd) {
          true => 1,
          false => -1,
        };
    position.jumpTo(
      (position.pixels + step).clamp(
        position.minScrollExtent,
        position.maxScrollExtent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final params = ScrollBarParams(orientation: widget.orientation);
    final seed = widget.seed;
    final track = InkSurface(
      source: RecipeInkSource(scrollTrackRecipe, params, json: params.toJson()),
      seed: switch (seed) {
        null => '${inkSeed(null)}|track',
        _ => '$seed|track',
      },
      still: true,
    );
    final thumbSource = RecipeInkSource(
      scrollThumbRecipe,
      params,
      json: params.toJson(),
    );
    return AnimatedOpacity(
      opacity: switch (widget.visible) {
        true => 1,
        false => 0,
      },
      duration: InkMotion.of(context, InkMotion.fade),
      child: ExcludeSemantics(
        child: ListenableBuilder(
          listenable: widget.controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, constraints) => _bar(
              constraints,
              track,
              thumbSource,
              seed,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bar(
    BoxConstraints constraints,
    Widget track,
    InkSource thumbSource,
    String? seed,
  ) {
    final position = _position;
    final length =
        switch (_vertical) {
          true => constraints.maxHeight,
          false => constraints.maxWidth,
        } -
        Spacing.d2;
    if (position == null ||
        !position.hasContentDimensions ||
        !position.hasViewportDimension ||
        position.maxScrollExtent <= position.minScrollExtent ||
        length <= 0) {
      return const SizedBox.shrink();
    }
    final content =
        position.maxScrollExtent -
        position.minScrollExtent +
        position.viewportDimension;
    final thumb = math.min(
      length,
      math.max(
        ScrollBar.minThumb,
        length * position.viewportDimension / content,
      ),
    );
    final progress =
        (position.pixels - position.minScrollExtent) /
        (position.maxScrollExtent - position.minScrollExtent);
    final start = (length - thumb) * progress.clamp(0, 1);
    final thumbWidget = MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        dragStartBehavior: DragStartBehavior.down,
        onVerticalDragUpdate: switch (_vertical) {
          true => (details) => _drag(details.delta.dy, length, thumb),
          false => null,
        },
        onHorizontalDragUpdate: switch (_vertical) {
          true => null,
          false => (details) => _drag(details.delta.dx, length, thumb),
        },
        child: InkSurface(
          source: thumbSource,
          seed: switch (seed) {
            null => '${inkSeed(null)}|thumb',
            _ => '$seed|thumb',
          },
          states: {if (_hovered) InkState.hovered},
          still: true,
        ),
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (details) => _page(
        switch (_vertical) {
          true => details.localPosition.dy,
          false => details.localPosition.dx,
        },
        start,
        thumb,
      ),
      child: Stack(
        children: [
          Positioned.fill(child: track),
          switch (_vertical) {
            true => Positioned(
              top: Spacing.d1 + start,
              height: thumb,
              left: Spacing.d2,
              right: Spacing.d1,
              child: thumbWidget,
            ),
            false => Positioned(
              left: Spacing.d1 + start,
              width: thumb,
              top: Spacing.d2,
              bottom: Spacing.d1,
              child: thumbWidget,
            ),
          },
        ],
      ),
    );
  }
}
