import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/select/select.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A typewriter-set kicker above a [SelectGroup], in muted ink.
///
/// Mirrors `SelectLabel` in upstream `src/components/ui/select.tsx`.
class SelectLabel extends StatelessWidget {
  const SelectLabel(this.child, {super.key});

  /// The label.
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: SelectMetrics.labelPadding,
    child: DefaultTextStyle.merge(
      style: SelectMetrics.labelStyle(LooseleafTheme.of(context)),
      child: Semantics(header: true, child: child),
    ),
  );
}
