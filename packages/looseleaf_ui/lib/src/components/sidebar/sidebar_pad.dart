import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/components/sidebar/sidebar.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Where a [SidebarPad]'s binder clip goes.
enum SidebarClipPlace {
  /// No clip.
  none,

  /// Hanging in the gutter above the pad (docked).
  hanging,

  /// Standing on the paper (the phone sheet, a static pad).
  inside,
}

/// The pad of a [Sidebar]: a flat sheet of [stock] with no rules, the
/// [children] in a column, and a binder clip at the top centre. A docked
/// pad casts its shadow sideways toward the page instead of the stock's.
///
/// Mirrors the `Paper` and `SidebarClip` of upstream
/// `src/components/ui/sidebar.tsx`.
class SidebarPad extends StatelessWidget {
  const SidebarPad({
    super.key,
    required this.stock,
    required this.seed,
    required this.children,
    this.clip = SidebarClipPlace.none,
    this.tilt = false,
    this.dockedSide,
    this.topPadding = 0,
  });

  /// What the pad is made of.
  final StockName stock;

  /// Pins the tear, tooth and clip.
  final String seed;

  /// The pad's parts.
  final List<Widget> children;

  /// Where the binder clip goes.
  final SidebarClipPlace clip;

  /// Turns the pad a little (the floating variant).
  final bool tilt;

  /// The side a docked pad hangs on: its shadow falls the other way.
  final SidebarSide? dockedSide;

  /// Space above the first part.
  final double topPadding;

  /// The docked shadow: `7px 0 18px -6px` at 0.34 and `1px 0 1.5px` at
  /// 0.24 of `--ll-shade`, scaled by `--ll-shadow-k`, toward the page.
  static List<BoxShadow> dockedShadow(
    LooseleafThemeData theme,
    SidebarSide side,
  ) {
    final toward = switch (side) {
      SidebarSide.left => 1.0,
      SidebarSide.right => -1.0,
    };
    final shade = theme.colors.shade;
    final k = theme.shadowK;
    return [
      BoxShadow(
        color: shade.withValues(alpha: (0.34 * k).clamp(0, 1)),
        offset: Offset(7 * toward, 0),
        blurRadius: 18,
        spreadRadius: -6,
      ),
      BoxShadow(
        color: shade.withValues(alpha: (0.24 * k).clamp(0, 1)),
        offset: Offset(toward, 0),
        blurRadius: 1.5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final showClip =
        clip != SidebarClipPlace.none &&
        !PaperInk.calm(theme) &&
        !SidebarPanelScope.iconsOf(context);
    final paper = Paper(
      stock: stock,
      tilt: tilt,
      rules: RuleName.none,
      seed: seed,
      shadow: switch (dockedSide) {
        null => PaperShadow.stock,
        _ => PaperShadow.none,
      },
      padding: EdgeInsets.only(top: topPadding),
      child: SizedBox.expand(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      fit: StackFit.expand,
      children: [
        if (dockedSide case final side?)
          DecoratedBox(
            decoration: BoxDecoration(boxShadow: dockedShadow(theme, side)),
          ),
        paper,
        if (showClip)
          Positioned(
            top: switch (clip) {
              SidebarClipPlace.inside => SidebarMetrics.clipInside,
              _ => -SidebarMetrics.clipHang,
            },
            left: 0,
            right: 0,
            child: Center(
              child: PaperFastener(
                kind: FastenerKind.binderClip,
                size: SidebarMetrics.clipSize,
                seed: '$seed|clip',
              ),
            ),
          ),
      ],
    );
  }
}
