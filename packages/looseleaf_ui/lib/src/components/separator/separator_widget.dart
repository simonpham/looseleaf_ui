import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/separator/separator.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A hand-drawn divider: a pencil line, dashes, a wavy ink line, dots, a
/// strip of kraft tape, stitches or a torn paper strip (the last three are
/// pencil when calm), horizontal or vertical. With a [child] it becomes a
/// labelled divider: two rules and a word between them.
///
/// A horizontal separator fills the width it is given, a vertical one the
/// height (give it a bounded height, like upstream's `h-5`). It is
/// [decorative] by default: hidden from screen readers except for its label.
///
/// ```dart
/// const Separator(variant: SeparatorVariant.dashed, child: Text('or'))
/// ```
///
/// Mirrors upstream `src/components/ui/separator.tsx`.
class Separator extends StatelessWidget {
  const Separator({
    super.key,
    this.orientation = SeparatorOrientation.horizontal,
    this.decorative = true,
    this.variant = SeparatorVariant.pencil,
    this.seed,
    this.child,
  });

  /// Which way it runs.
  final SeparatorOrientation orientation;

  /// Hidden from screen readers when true; announced as a divider otherwise.
  final bool decorative;

  /// How the rule is drawn.
  final SeparatorVariant variant;

  /// Pins the drawing; a labelled separator seeds its rules `seed:a` and
  /// `seed:b`.
  final String? seed;

  /// The label between the rules, if any.
  final Widget? child;

  String? _seed(String part) => switch (seed) {
    null => null,
    final value => '$value:$part',
  };

  @override
  Widget build(BuildContext context) {
    final label = child;
    if (label == null) {
      return _semantics(
        SeparatorRule(variant: variant, orientation: orientation, seed: seed),
      );
    }
    final theme = LooseleafTheme.of(context);
    final text = DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 14,
        cssLineHeight: 1,
        fontWeight: FontWeight.w700,
        color: theme.colors.inkMuted,
      ),
      child: label,
    );
    Widget rule(String part) => Expanded(
      child: ExcludeSemantics(
        child: SeparatorRule(
          variant: variant,
          orientation: orientation,
          seed: _seed(part),
        ),
      ),
    );
    final children = [rule('a'), text, rule('b')];
    return _semantics(switch (orientation) {
      SeparatorOrientation.horizontal => Row(
        spacing: Spacing.d12,
        children: children,
      ),
      SeparatorOrientation.vertical => Column(
        spacing: Spacing.d12,
        children: children,
      ),
    }, labelled: true);
  }

  Widget _semantics(Widget child, {bool labelled = false}) {
    if (decorative && !labelled) return ExcludeSemantics(child: child);
    if (decorative) return child;
    return Semantics(container: true, child: child);
  }
}
