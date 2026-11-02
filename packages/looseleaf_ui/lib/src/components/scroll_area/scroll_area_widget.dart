import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/scroll_area/scroll_bar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Which ways a [ScrollArea] scrolls.
enum ScrollAreaOrientation { vertical, horizontal, both }

/// When a [ScrollArea] shows its scroll marks (Radix `type`).
enum ScrollAreaType {
  /// While the content overflows.
  auto,

  /// Always, as long as there is something to scroll.
  always,

  /// While scrolling, fading 600 ms after it stops.
  scroll,

  /// While the pointer is over the area or it scrolls (the default).
  hover,
}

/// A scrolling region marked with a pencil scroll mark instead of a
/// platform bar. By default ([ScrollAreaType.hover]) the mark fades in
/// while the pointer is over the area or it scrolls, and fades out 600 ms
/// after; [type] keeps it shown or shows it only while scrolling.
///
/// The viewport takes keyboard focus (arrows and page keys scroll it) and
/// shows a blue ring while focused from the keyboard. [bleed] pads the
/// content 12 so drawings near the edge are not cut off.
///
/// ```dart
/// SizedBox(height: 288, child: ScrollArea(child: TagList()))
/// ```
///
/// Mirrors `ScrollArea` in upstream `src/components/ui/scroll-area.tsx`.
class ScrollArea extends StatefulWidget {
  const ScrollArea({
    super.key,
    required this.child,
    this.orientation = ScrollAreaOrientation.vertical,
    this.bleed = false,
    this.type = ScrollAreaType.hover,
    this.controller,
    this.horizontalController,
    this.seed,
  });

  final Widget child;
  final ScrollAreaOrientation orientation;

  /// Pads the content 12 (upstream `p-3`).
  final bool bleed;

  /// When the scroll marks show.
  final ScrollAreaType type;

  /// Drives the vertical scroll (the only one when horizontal).
  final ScrollController? controller;

  /// Drives the horizontal scroll when [orientation] is
  /// [ScrollAreaOrientation.both].
  final ScrollController? horizontalController;

  /// Pins the hand of the scroll marks.
  final String? seed;

  /// Radix's `scrollHideDelay`.
  static const Duration hideDelay = Duration(milliseconds: 600);

  @override
  State<ScrollArea> createState() => _ScrollAreaState();
}

class _ScrollAreaState extends State<ScrollArea> {
  ScrollController? _ownMain;
  ScrollController? _ownCross;
  bool _hovered = false;
  bool _scrolling = false;
  bool _focusVisible = false;
  Timer? _hide;

  ScrollController get _main =>
      widget.controller ?? (_ownMain ??= ScrollController());

  ScrollController get _cross =>
      widget.horizontalController ?? (_ownCross ??= ScrollController());

  bool _onScroll(ScrollNotification notification) {
    _hide?.cancel();
    if (!_scrolling) setState(() => _scrolling = true);
    _hide = Timer(ScrollArea.hideDelay, () {
      if (mounted) setState(() => _scrolling = false);
    });
    return false;
  }

  @override
  void dispose() {
    _hide?.cancel();
    _ownMain?.dispose();
    _ownCross?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orientation = widget.orientation;
    final visible = switch (widget.type) {
      ScrollAreaType.auto || ScrollAreaType.always => true,
      ScrollAreaType.scroll => _scrolling,
      ScrollAreaType.hover => _hovered || _scrolling,
    };
    final focus = LooseleafTheme.of(context).colors.focus;
    final content = FocusableActionDetector(
      onShowFocusHighlight: (shown) => setState(() => _focusVisible = shown),
      child: switch (widget.bleed) {
        true => Padding(
          padding: const EdgeInsets.all(Spacing.d12),
          child: widget.child,
        ),
        false => widget.child,
      },
    );
    final viewport = switch (orientation) {
      ScrollAreaOrientation.vertical => SingleChildScrollView(
        controller: _main,
        child: content,
      ),
      ScrollAreaOrientation.horizontal => SingleChildScrollView(
        controller: _main,
        scrollDirection: Axis.horizontal,
        child: content,
      ),
      ScrollAreaOrientation.both => SingleChildScrollView(
        controller: _main,
        child: SingleChildScrollView(
          controller: _cross,
          scrollDirection: Axis.horizontal,
          child: content,
        ),
      ),
    };
    final horizontalController = switch (orientation) {
      ScrollAreaOrientation.horizontal => _main,
      _ => _cross,
    };
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: Stack(
          children: [
            DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(
                border: switch (_focusVisible) {
                  true => Border.all(color: focus, width: Spacing.d2),
                  false => null,
                },
              ),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(
                  context,
                ).copyWith(scrollbars: false),
                child: viewport,
              ),
            ),
            if (orientation != ScrollAreaOrientation.horizontal)
              PositionedDirectional(
                top: 0,
                bottom: switch (orientation) {
                  ScrollAreaOrientation.both => ScrollBar.thickness,
                  _ => 0,
                },
                end: 0,
                width: ScrollBar.thickness,
                child: ScrollBar(
                  controller: _main,
                  visible: visible,
                  seed: _seed('v'),
                ),
              ),
            if (orientation != ScrollAreaOrientation.vertical)
              PositionedDirectional(
                start: 0,
                end: switch (orientation) {
                  ScrollAreaOrientation.both => ScrollBar.thickness,
                  _ => 0,
                },
                bottom: 0,
                height: ScrollBar.thickness,
                child: ScrollBar(
                  controller: horizontalController,
                  orientation: ScrollOrientation.horizontal,
                  visible: visible,
                  seed: _seed('h'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String? _seed(String axis) => switch (widget.seed) {
    null => null,
    final seed => '$seed|$axis',
  };
}
