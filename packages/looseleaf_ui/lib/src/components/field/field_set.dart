import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/components/radio_group/radio_group.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A set of fields under a [FieldLegend]: 24 px apart (16 in calm), 12 when
/// it holds a radio group. A [FieldDescription] right after the legend
/// tucks up under it.
///
/// Mirrors `FieldSet` in upstream `src/components/ui/field.tsx`.
class FieldSet extends StatelessWidget {
  const FieldSet({super.key, required this.children, this.semanticLabel});

  /// A legend, descriptions, groups and fields.
  final List<Widget> children;

  /// The set's accessible name, when it has no legend.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final density = LooseleafTheme.of(context).density;
    final choices = children.any((child) => child is InkRadioGroup);
    final gap = switch ((choices, density)) {
      (true, _) => Spacing.d12,
      (false, LooseleafDensity.calm) => Spacing.d16,
      (false, _) => Spacing.d24,
    };
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: FieldStack(
        gap: (index, before, after) => switch ((before, after)) {
          (FieldLegend(), FieldDescription()) => Spacing.d6,
          (FieldLegend(), _) => Spacing.d12,
          _ => gap,
        },
        children: children,
      ),
    );
  }
}
