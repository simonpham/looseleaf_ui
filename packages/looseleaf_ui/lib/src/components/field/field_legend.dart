import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A [FieldSet]'s heading: the script face at 25.6 px, or a bold 15 px
/// label.
///
/// Mirrors `FieldLegend` in upstream `src/components/ui/field.tsx`.
class FieldLegend extends StatelessWidget {
  const FieldLegend(
    this.child, {
    super.key,
    this.variant = FieldLegendVariant.legend,
  });

  /// The heading, usually a [Text].
  final Widget child;

  final FieldLegendVariant variant;

  @override
  Widget build(BuildContext context) {
    final typography = LooseleafTheme.of(context).typography;
    return Semantics(
      header: true,
      child: DefaultTextStyle.merge(
        style: switch (variant) {
          FieldLegendVariant.legend => typography.face(
            KevinSansFace.script,
            cssSize: 25.6,
            cssLineHeight: 1,
            fontWeight: FontWeight.w700,
          ),
          FieldLegendVariant.label => typography.face(
            KevinSansFace.hand,
            cssSize: 15,
            fontWeight: FontWeight.w700,
          ),
        },
        child: child,
      ),
    );
  }
}
