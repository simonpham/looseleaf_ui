import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/radio_group/radio_group_scope.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A set of [RadioGroupItem]s of which one is checked.
///
/// The group is one Tab stop (the checked item, else the first); the arrow
/// keys move to the next item and check it, looping at the ends, and Space
/// checks the focused one. Items stack with a 12 px gap, or wrap in a row
/// with 24 px between them when [direction] is [Axis.horizontal].
///
/// ```dart
/// RadioGroup<String>(
///   value: plan,
///   onChanged: (value) => setState(() => plan = value),
///   children: const [
///     RadioGroupItem(value: 'free', label: Text('Free')),
///     RadioGroupItem(value: 'pro', label: Text('Pro')),
///   ],
/// )
/// ```
///
/// Mirrors `RadioGroup` in upstream `src/components/ui/radio-group.tsx`.
class RadioGroup<T> extends StatelessWidget {
  const RadioGroup({
    super.key,
    required this.value,
    required this.children,
    this.onChanged,
    this.direction = Axis.vertical,
    this.disabled = false,
    this.invalid = false,
    this.semanticLabel,
  });

  /// The checked value, or null when none is.
  final T? value;

  /// Called with an item's value when it is checked.
  final ValueChanged<T>? onChanged;

  /// The items, usually [RadioGroupItem]s of [T].
  final List<Widget> children;

  /// Stacked (`grid gap-3`) or in a wrapping row (`flex-wrap gap-x-6`).
  final Axis direction;

  /// Disables every item.
  final bool disabled;

  /// Draws every item in red pencil (upstream `aria-invalid` on the group).
  final bool invalid;

  /// The group's accessible name.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    explicitChildNodes: true,
    label: semanticLabel,
    child: RadioGroupScope<T>(
      value: value,
      onChanged: onChanged,
      disabled: disabled,
      invalid: invalid,
      child: InkRovingFocus(
        child: switch (direction) {
          Axis.vertical => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: Spacing.d12,
            children: children,
          ),
          Axis.horizontal => Wrap(
            spacing: Spacing.d24,
            runSpacing: Spacing.d12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: children,
          ),
        },
      ),
    ),
  );
}
