import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/painter/painter.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A sheet's printed rules, filling its parent: CSS-style rules for every
/// [RuleName], or for `ruled-hand` blue lines drawn with a ruler (plain
/// `ruled` when calm). Decorative and pointer-transparent.
///
/// [offset] is upstream's `--ll-rule-offset` (rules sit that far above the
/// text baseline); [mirror] flips the margin to the right, as a page does in
/// right-to-left layouts.
///
/// Mirrors the `paper-rules` layers of upstream `src/components/ui/paper.tsx`.
class PaperRules extends StatelessWidget {
  const PaperRules({
    super.key,
    required this.kind,
    required this.seed,
    this.pad = false,
    this.offset,
    this.mirror = false,
  });

  /// The rules.
  final RuleName kind;

  /// Seeds the hand-ruled lines.
  final String seed;

  /// Hand rules in faint you-ink, as on an order pad.
  final bool pad;

  /// `--ll-rule-offset` in px; each rule kind's own when null.
  final double? offset;

  /// Flips the rules horizontally.
  final bool mirror;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    if (kind == RuleName.ruledHand && !calm) return _hand(calm);
    final printed = switch (kind) {
      RuleName.ruledHand => RuleName.ruled,
      _ => kind,
    };
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _RulesPainter(
            kind: printed,
            theme: theme,
            offset: offset,
            mirror: mirror,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }

  Widget _hand(bool calm) {
    final params = HandRulesParams(
      paper: switch (pad) {
        true => HandRulesPaper.pad,
        false => HandRulesPaper.ruled,
      },
    );
    final base = ruleGeometry(RuleName.ruled, calm: calm).offset;
    Widget rules = InkSurface(
      source: RecipeInkSource(handRulesRecipe, params, json: params.toJson()),
      seed: '$seed|rules',
      still: true,
    );
    if (mirror) rules = Transform.flip(flipX: true, child: rules);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Transform.translate(
          offset: Offset(0, base - (offset ?? base)),
          child: rules,
        ),
      ),
    );
  }
}

class _RulesPainter extends CustomPainter {
  _RulesPainter({
    required this.kind,
    required this.theme,
    required this.offset,
    required this.mirror,
  });

  final RuleName kind;
  final LooseleafThemeData theme;
  final double? offset;
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) => PaperRulesPainter.paint(
    canvas,
    Offset.zero & size,
    kind,
    theme: theme,
    calm: theme.density == LooseleafDensity.calm,
    offset: offset,
    mirror: mirror,
  );

  @override
  bool shouldRepaint(_RulesPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.theme != theme ||
      oldDelegate.offset != offset ||
      oldDelegate.mirror != mirror;
}
