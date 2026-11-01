import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/paper/paper.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/textures/textures.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The sheet itself, filling its parent: the stock's colour, tooth and sheen,
/// its shadow, its printed rules and its resting tilt. Put it behind any
/// content (in a `Stack` with `Positioned.fill`) to make that content sit on
/// paper; [Paper] does exactly that.
///
/// A plain cut sheet is painted directly (upstream's `.ll-paper::before`);
/// torn, deckled, crimped, zigzag, perforated, scalloped or curled sheets are
/// drawn by the engine's `paper-sheet` recipe and their faces painted under
/// the outline (upstream's `SheetLayers`). Calm density cuts every edge,
/// flattens the curl and the tilt, and drops shadows to a hairline.
///
/// Only the sheet turns with the tilt; content laid over it stays upright.
///
/// Mirrors the sheet layers of upstream `src/components/ui/paper.tsx`.
class PaperBackground extends StatelessWidget {
  const PaperBackground({
    super.key,
    required this.seed,
    this.stock = StockName.paper,
    this.edge,
    this.shadow = PaperShadow.stock,
    this.tilt = true,
    this.tiltDegrees,
    this.rules,
    this.rulesOffset,
    this.mirrorRules = false,
    this.curl = false,
  });

  /// Upstream's curl size: a curled bottom-right corner of 34 px.
  static const double curlSize = 34;

  static const Set<RuleName> _ruled = {
    RuleName.ruled,
    RuleName.ruledHand,
    RuleName.indexCard,
    RuleName.pad,
    RuleName.ledger,
  };

  /// Seeds the outline, the tooth offsets and the tilt.
  final String seed;

  /// The paper stock.
  final StockName stock;

  /// The edges; the stock's when null.
  final EdgeSpec? edge;

  /// The shadow.
  final PaperShadow shadow;

  /// False to lay the sheet flat.
  final bool tilt;

  /// A fixed tilt in degrees; seeded within the stock's when null.
  final double? tiltDegrees;

  /// The printed rules; the stock's when null.
  final RuleName? rules;

  /// `--ll-rule-offset` in px.
  final double? rulesOffset;

  /// Flips the rules for right-to-left pages.
  final bool mirrorRules;

  /// A curled bottom-right corner.
  final bool curl;

  /// The resting tilt in degrees (before the theme's clamp) of a sheet of
  /// [stock] with [rules], seeded by [seed].
  static double restingTilt(String seed, StockName stock, RuleName rules) {
    final max =
        stockOf(stock).tilt *
        switch (_ruled.contains(rules)) {
          true => 0.45,
          false => 1.0,
        };
    return tiltFor(seed, max);
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = PaperInk.calm(theme);
    final def = stockOf(stock);
    final requested = switch (calm) {
      true => const EdgeSpec(),
      false => edge ?? def.edge,
    };
    final curled = curl && !calm;
    final drawn = !isCutEdge(requested) || curled;
    final ruleName = rules ?? def.rules;
    final degrees = switch (tilt) {
      false => 0.0,
      true => tiltDegrees ?? restingTilt(seed, stock, ruleName),
    };
    final angle = PaperInk.tilt(context, degrees);
    final kind = shadow.resolve(stock, calm: calm);
    final inset = switch (drawn) {
      true => edgeInset(requested).ceilToDouble() + 1,
      false => 0.0,
    };
    final Widget sheet = switch (drawn) {
      true => _drawn(requested, curled, kind),
      false => CustomPaint(
        painter: _CutSheetPainter(
          stock: stock,
          seed: seed,
          shadow: kind,
          theme: theme,
        ),
        child: const SizedBox.expand(),
      ),
    };
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Transform.rotate(angle: angle, child: sheet),
            if (ruleName != RuleName.none)
              Positioned.fill(
                left: inset,
                top: inset,
                right: inset,
                bottom: inset,
                child: Transform.rotate(
                  angle: angle,
                  child: PaperRules(
                    kind: ruleName,
                    seed: seed,
                    pad: stock == StockName.pad,
                    offset: rulesOffset,
                    mirror: mirrorRules,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _drawn(EdgeSpec edge, bool curled, SheetShadowKind? kind) {
    final params = SheetParams(
      stock: stock,
      edge: edge,
      chamfer: switch (curled) {
        true => curlSize,
        false => null,
      },
      shadow: switch (shadow) {
        PaperShadow.stock || PaperShadow.none => null,
        _ => kind,
      },
      noShadow: shadow == PaperShadow.none,
    );
    return InkSurface(
      source: RecipeInkSource(sheetRecipe, params, json: params.toJson()),
      seed: seed,
      still: true,
    );
  }
}

class _CutSheetPainter extends CustomPainter {
  _CutSheetPainter({
    required this.stock,
    required this.seed,
    required this.shadow,
    required this.theme,
  }) : super(repaint: InkTextures.instance);

  static const Radius _radius = Radius.circular(1);

  final StockName stock;
  final String seed;
  final SheetShadowKind? shadow;
  final LooseleafThemeData theme;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final box = RRect.fromRectAndRadius(Offset.zero & size, _radius);
    if (shadow case final kind?) {
      PaperShadowPainter.paint(
        canvas,
        box,
        PaperShadowPainter.layersOf(kind),
        theme: theme,
      );
    }
    PaperFacePainter.paint(
      canvas,
      Path()..addRRect(box),
      stock: stock,
      seed: seed,
      theme: theme,
    );
  }

  @override
  bool shouldRepaint(_CutSheetPainter oldDelegate) =>
      oldDelegate.stock != stock ||
      oldDelegate.seed != seed ||
      oldDelegate.shadow != shadow ||
      oldDelegate.theme != theme;
}
