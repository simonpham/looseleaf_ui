import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A label and its description stacked 6 px apart, beside the control of a
/// horizontal [Field], taking the room left.
///
/// Mirrors `FieldContent` in upstream `src/components/ui/field.tsx`.
class FieldContent extends StatelessWidget {
  const FieldContent({super.key, required this.children});

  /// The label, title and descriptions.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: Spacing.d6,
    children: children,
  );
}
