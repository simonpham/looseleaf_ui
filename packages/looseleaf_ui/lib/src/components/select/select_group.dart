import 'package:flutter/widgets.dart';

/// Groups [SelectItem]s under a [SelectLabel], announced as one group.
///
/// Mirrors `SelectGroup` in upstream `src/components/ui/select.tsx`.
class SelectGroup extends StatelessWidget {
  const SelectGroup({super.key, required this.children});

  /// The label, items and separators.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}
