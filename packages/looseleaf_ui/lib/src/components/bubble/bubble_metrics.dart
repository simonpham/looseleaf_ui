import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Sizes, stocks and text styles of a bubble, from upstream
/// `src/components/ui/bubble.tsx`.
abstract final class BubbleMetrics {
  /// `max-w-[80%]`: a bubble's share of its row.
  static const double maxWidthFactor = 0.8;

  /// `gap-1` between a bubble's content and what follows it.
  static const double gap = Spacing.d4;

  /// `gap-2` between the bubbles of a group.
  static const double groupGap = Spacing.d8;

  /// `px-4 py-2.5 compact:px-3.5 compact:py-2 calm:px-3 calm:py-1.5`.
  static const ByDensity<EdgeInsets> padding = ByDensity(
    comfortable: EdgeInsets.symmetric(
      horizontal: Spacing.d16,
      vertical: Spacing.d10,
    ),
    compact: EdgeInsets.symmetric(
      horizontal: Spacing.d14,
      vertical: Spacing.d8,
    ),
    calm: EdgeInsets.symmetric(horizontal: Spacing.d12, vertical: Spacing.d6),
  );

  /// `start-3` / `end-3`: how far a reaction chip sits in from a corner.
  static const double reactionsInset = Spacing.d12;

  /// `min-h-6`.
  static const double reactionsMinHeight = Spacing.d24;

  /// `px-2 py-0.5`.
  static const EdgeInsets reactionsPadding = EdgeInsets.symmetric(
    horizontal: Spacing.d8,
    vertical: Spacing.d2,
  );

  /// `-translate-y-3/4` / `translate-y-3/4`: how far a chip hangs off the
  /// edge, as a share of its height.
  static const double reactionsOverhang = 0.75;

  /// `NOTE_STOCK`: the slip each variant folds a note from.
  static StockName noteStock(BubbleVariant variant) => switch (variant) {
    BubbleVariant.primary => StockName.slip,
    BubbleVariant.secondary => StockName.indexCard,
    BubbleVariant.muted => StockName.paper,
    BubbleVariant.tinted => StockName.card,
    BubbleVariant.outline => StockName.graph,
    BubbleVariant.ghost => StockName.slip,
    BubbleVariant.destructive => StockName.slip,
  };

  /// `STICKY_STOCK`: the sticky note colour of each variant.
  static StockName stickyStock(BubbleVariant variant) => switch (variant) {
    BubbleVariant.primary => StockName.stickyOrange,
    BubbleVariant.secondary => StockName.stickyYellow,
    BubbleVariant.muted => StockName.stickyBlue,
    BubbleVariant.tinted => StockName.stickyPink,
    BubbleVariant.outline => StockName.stickyGreen,
    BubbleVariant.ghost => StockName.stickyYellow,
    BubbleVariant.destructive => StockName.stickyPink,
  };

  /// The text colour on a cloud of [variant]: paper on the marker and red
  /// fills, ink on the rest.
  static Color textColor(LooseleafColors colors, BubbleVariant variant) =>
      switch (variant) {
        BubbleVariant.primary || BubbleVariant.destructive => colors.paper,
        _ => colors.ink,
      };

  /// `font-hand text-base leading-relaxed`.
  static TextStyle hand(LooseleafThemeData theme, Color color) =>
      theme.typography.face(
        KevinSansFace.hand,
        cssSize: 16,
        cssLineHeight: 1.625,
        color: color,
      );

  /// `font-script text-[1.35rem] leading-snug`: notes, stickies and
  /// `pen: you`.
  static TextStyle script(LooseleafThemeData theme, Color color) =>
      theme.typography.face(
        KevinSansFace.script,
        cssSize: 21.6,
        cssLineHeight: 1.375,
        color: color,
      );

  /// `font-hand text-sm`: a reaction chip.
  static TextStyle reactions(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: 14,
    cssLineHeight: 20 / 14,
  );
}
