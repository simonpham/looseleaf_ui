import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/menu/menu.dart';

/// One choice of an [InkMenuRadioGroup]: a pencil ring at the start, with a
/// bold felt dot while it is the group's value. Choosing it hands [value]
/// to the group, then calls [onSelect], and closes the menu unless
/// [closeOnSelect] is false.
///
/// Mirrors the `*MenuRadioItem` parts of upstream `dropdown-menu.tsx`,
/// `context-menu.tsx` and `menubar.tsx`.
class InkMenuRadioItem extends StatelessWidget {
  const InkMenuRadioItem({
    super.key,
    required this.value,
    required this.child,
    this.onSelect,
    this.closeOnSelect = true,
    this.trailing,
    this.disabled = false,
    this.textValue,
    this.focusNode,
  });

  /// The value this row stands for.
  final String value;

  /// The row's text.
  final Widget child;

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
  Widget build(BuildContext context) {
    final group = InkMenuRadioScope.maybeOf(context);
    final chosen = group?.value == value;
    return InkMenuItemHost(
      disabled: disabled,
      textValue: textValue ?? InkMenuEntry.textOf(child),
      focusNode: focusNode,
      closeOnActivate: closeOnSelect,
      role: SemanticsRole.menuItemRadio,
      checked: chosen,
      onActivate: (_) {
        group?.onChanged?.call(value);
        onSelect?.call();
      },
      builder: (context, highlighted, focusVisible) => InkMenuRow(
        highlighted: highlighted,
        focusVisible: focusVisible,
        disabled: disabled,
        trailing: trailing,
        indicator: InkMenuIndicator(
          kind: InkMenuIndicatorKind.radio,
          on: chosen,
        ),
        child: child,
      ),
    );
  }
}
