import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/typography/typography.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The page title: big bold script with a hand rule under it.
///
/// ```dart
/// const H1(child: Text('Notes on keeping a notebook'))
/// ```
///
/// Mirrors `H1` in upstream `src/components/ui/typography.tsx`.
class H1 extends StatelessWidget {
  const H1({super.key, required this.child, this.rule = true});

  final Widget child;

  /// Draws the rule under the heading.
  final bool rule;

  @override
  Widget build(BuildContext context) =>
      RuledHeading(style: TypographyStyle.h1, rule: rule, child: child);
}

/// A section heading: bold script with a hand rule under it.
///
/// Mirrors `H2` in upstream `src/components/ui/typography.tsx`.
class H2 extends StatelessWidget {
  const H2({super.key, required this.child, this.rule = true});

  final Widget child;

  /// Draws the rule under the heading.
  final bool rule;

  @override
  Widget build(BuildContext context) =>
      RuledHeading(style: TypographyStyle.h2, rule: rule, child: child);
}

/// A heading in [style] with an optional [HeadingRule]: the body of [H1]
/// and [H2].
class RuledHeading extends StatelessWidget {
  const RuledHeading({
    super.key,
    required this.style,
    required this.rule,
    required this.child,
  });

  final TypographyStyle style;
  final bool rule;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = TypographyText(style: style, header: true, child: child);
    if (!rule) return text;
    return DefaultTextStyle.merge(
      style: style.resolve(LooseleafTheme.of(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [text, const HeadingRule()],
      ),
    );
  }
}
