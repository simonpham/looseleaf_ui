import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A field's title when it is not a label (inside a choice card): bold
/// 15 px, graphite when the field is disabled, red when invalid.
///
/// Mirrors `FieldTitle` in upstream `src/components/ui/field.tsx`.
class FieldTitle extends StatelessWidget {
  const FieldTitle(this.child, {super.key});

  /// The title, usually a [Text].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    return DefaultTextStyle.merge(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        cssLineHeight: 1.375,
        fontWeight: FontWeight.w700,
        color: FieldLabel.colorIn(context),
      ),
      child: child,
    );
  }
}
