import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_label.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A run of rows under an optional [heading]; it hides when the search
/// leaves none of its rows.
///
/// Mirrors `ComboboxGroup` in upstream `src/components/ui/combobox.tsx`
/// (cmdk's group with its heading).
class ComboboxGroup extends StatefulWidget {
  const ComboboxGroup({super.key, required this.children, this.heading});

  /// The rows, usually [ComboboxItem]s.
  final List<Widget> children;

  /// The small type heading above the rows.
  final String? heading;

  @override
  State<ComboboxGroup> createState() => _ComboboxGroupState();
}

class _ComboboxGroupState extends State<ComboboxGroup> {
  final Object _identity = Object();

  @override
  Widget build(BuildContext context) {
    final scope = ComboboxScope.of(context);
    final heading = widget.heading;
    return Offstage(
      offstage: !scope.controller.groupVisible(_identity),
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.d4),
          child: ComboboxScope(
            controller: scope.controller,
            revision: scope.revision,
            inContent: scope.inContent,
            group: _identity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (heading != null) ComboboxLabel(child: Text(heading)),
                ...widget.children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
