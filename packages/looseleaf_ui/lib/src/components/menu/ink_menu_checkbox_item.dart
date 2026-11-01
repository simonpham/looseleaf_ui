import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// A toggle row: a pencil box at the start, ticked in blue felt while
/// [value] is true (null is half checked). Choosing it calls [onChanged]
/// with the other value, then [onSelect], and closes the menu unless
/// [closeOnSelect] is false.
///
/// Mirrors the `*MenuCheckboxItem` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuCheckboxItem extends StatelessWidget {
  const InkMenuCheckboxItem({
    super.key,
    required this.child,
    required this.value,
    this.onChanged,
    this.onSelect,
    this.closeOnSelect = true,
    this.trailing,
    this.disabled = false,
    this.textValue,
    this.focusNode,
  });

  /// The row's text.
  final Widget child;

  /// Whether it is ticked; null is half checked.
  final bool? value;

  /// Called with the new value when it is toggled.
  final ValueChanged<bool>? onChanged;

  /// Runs when the row is chosen.
  final VoidCallback? onSelect;

  /// Whether choosing it closes the menu.
  final bool closeOnSelect;

  /// What sits at the end, like a shortcut.
  final Widget? trailing;

  /// Pencil-gray, skipped by the arrows, cannot be chosen.
  final bool disabled;

  /// The text typeahead matches; [child]'s when it is a [Text].
  final String? textValue;

  /// The row's focus node.
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) => InkMenuItemHost(
    disabled: disabled,
    textValue: textValue ?? InkMenuEntry.textOf(child),
    focusNode: focusNode,
    closeOnActivate: closeOnSelect,
    role: SemanticsRole.menuItemCheckbox,
    checked: value ?? false,
    mixed: value == null,
    onActivate: (_) {
      onChanged?.call(value != true);
      onSelect?.call();
    },
    builder: (context, highlighted, focusVisible) => InkMenuRow(
      highlighted: highlighted,
      focusVisible: focusVisible,
      disabled: disabled,
      trailing: trailing,
      indicator: InkMenuIndicator(
        kind: InkMenuIndicatorKind.check,
        on: value ?? true,
      ),
      child: child,
    ),
  );
}
