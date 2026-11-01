import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A label tag's title in the script face, 26.4 px bold, leading none.
///
/// Mirrors `LabelTagTitle` in upstream `src/components/ui/label-tag.tsx`.
class LabelTagTitle extends StatelessWidget {
  const LabelTagTitle(this.child, {super.key, this.cssSize = 26.4});

  /// The title, usually a [Text].
  final Widget child;

  /// The CSS font size; upstream's `text-[1.65rem]`.
  final double cssSize;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.script,
        cssSize: cssSize,
        cssLineHeight: 1,
        fontWeight: FontWeight.w700,
        color: theme.colors.ink,
      ),
      child: child,
    );
  }
}
