import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/dialog/dialog.dart';
import 'package:looseleaf_ui/src/components/drawer/drawer.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sheet/sheet.dart';
import 'package:looseleaf_ui/src/components/tape/tape.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The slip a [Drawer] pulls out: flat paper (a slip by default) along the
/// drawer's edge. A bottom drawer is torn along its top edge and wears a
/// strip of kraft tape as its grab tab.
///
/// Top and bottom drawers are full width and at most 80 % of the window
/// tall (keeping 96 px of it clear); left and right ones are full height
/// and three quarters of the window wide (at most 384 px from 640 px up).
/// The [children] stack with no gap or padding: [DrawerHeader] and
/// [DrawerFooter] bring theirs, and a footer in a side drawer sits at the
/// bottom.
///
/// Mirrors `DrawerContent` in upstream `src/components/ui/drawer.tsx`.
class DrawerContent extends StatefulWidget {
  const DrawerContent({
    super.key,
    required this.children,
    this.stock = StockName.slip,
    this.edge,
    this.tapeKind = TapeKind.kraft,
    this.tapeColor,
    this.seed,
    this.semanticLabel,
  });

  /// The header, the content and the footer, top to bottom.
  final List<Widget> children;

  /// The paper stock.
  final StockName stock;

  /// The edges; torn at the top of a bottom drawer, cut otherwise, when
  /// null.
  final EdgeSpec? edge;

  /// The grab tab's tape.
  final TapeKind tapeKind;

  /// The grab tab's colour.
  final Accent? tapeColor;

  /// Pins the paper and the tape.
  final String? seed;

  /// Names the drawer for screen readers when it has no title.
  final String? semanticLabel;

  /// A top or bottom drawer's tallest share: `max-h-[80vh]`.
  static const double edgeShare = 0.8;

  /// The window kept clear of a top or bottom drawer: `mt-24`.
  static const double edgeClearance = Spacing.d96;

  @override
  State<DrawerContent> createState() => _DrawerContentState();
}

class _DrawerContentState extends State<DrawerContent> with InkSeed {
  static const double _tapeLength = 92;
  static const double _tapeHeight = 22;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final seed = inkSeed(widget.seed);
    final direction = DrawerScope.directionOf(context);
    final sideways = !direction.vertical;
    final media = MediaQuery.maybeOf(context);
    final window = media?.size ?? Size.infinite;
    final full = window.width >= DialogMetrics.phoneBreakpoint;
    final width = switch (full) {
      true => math.min(
        window.width * SheetContent.sideShare,
        SheetContent.maxSideWidth,
      ),
      false => window.width * SheetContent.sideShare,
    };
    final tallest = math.min(
      window.height * DrawerContent.edgeShare,
      window.height - DrawerContent.edgeClearance,
    );
    final children = [
      for (final child in widget.children) ...[
        if (sideways && child is DrawerFooter) const Spacer(),
        child,
      ],
    ];
    final paper = Paper(
      stock: widget.stock,
      edge:
          widget.edge ??
          switch (direction) {
            OverlaySide.bottom => const EdgeSpec(top: EdgeKind.torn),
            _ => const EdgeSpec.all(EdgeKind.cut),
          },
      tilt: false,
      rules: RuleName.none,
      seed: seed,
      padding: EdgeInsets.only(
        bottom: switch (direction) {
          OverlaySide.top => 0,
          _ => media?.padding.bottom ?? 0,
        },
      ),
      child: Column(
        mainAxisSize: switch (sideways) {
          true => MainAxisSize.max,
          false => MainAxisSize.min,
        },
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
    return Semantics(
      container: true,
      explicitChildNodes: true,
      scopesRoute: true,
      namesRoute: widget.semanticLabel != null,
      label: widget.semanticLabel,
      child: DialogContentScope(
        closeMark: false,
        phone: !full,
        child: DefaultTextStyle.merge(
          style: theme.typography.interface(color: theme.colors.ink),
          child: ConstrainedBox(
            constraints: switch (sideways) {
              true => BoxConstraints.tightFor(width: width),
              false => BoxConstraints(maxHeight: tallest),
            },
            child: Stack(
              fit: StackFit.passthrough,
              clipBehavior: Clip.none,
              children: [
                paper,
                if (direction == OverlaySide.bottom)
                  Positioned(
                    top: -Spacing.d12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Tape(
                        kind: widget.tapeKind,
                        color: widget.tapeColor,
                        length: _tapeLength,
                        height: _tapeHeight,
                        angle: -1.5,
                        seed: '$seed:grab',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
