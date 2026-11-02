import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/checkbox/checkbox.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/components/radio_group/radio_group.dart';
import 'package:looseleaf_ui/src/components/toggle_group/toggle_group.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One labeled control: a [FieldLabel], the control, [FieldDescription]s
/// and a [FieldError], 12 px apart. Vertical stacks them at full width;
/// horizontal puts the label (or a [FieldContent]) beside a switch or
/// checkbox; responsive switches with its [FieldGroup]'s width. A
/// horizontal field of controls alone (a row of buttons) wraps onto more
/// lines when it runs out of room.
///
/// [invalid] turns the label and text red (mark the control `invalid`
/// too); [disabled] turns the label graphite. Field is layout and words:
/// nothing is drawn but the controls.
///
/// ```dart
/// Field(children: [
///   FieldLabel(focusNode: nameFocus, child: Text('Name')),
///   Input(focusNode: nameFocus, placeholder: 'Field notes'),
///   FieldDescription(Text('Shows on the spine.')),
/// ])
/// ```
///
/// Mirrors `Field` in upstream `src/components/ui/field.tsx`.
class Field extends StatelessWidget {
  const Field({
    super.key,
    required this.children,
    this.orientation = FieldOrientation.vertical,
    this.invalid = false,
    this.disabled = false,
  });

  /// The label, control, descriptions and error.
  final List<Widget> children;

  final FieldOrientation orientation;

  /// Upstream's `data-invalid`: red text.
  final bool invalid;

  /// Upstream's `data-disabled`: a graphite label.
  final bool disabled;

  /// `nth-last-2:-mt-1`: a description right before the error.
  static const double _descriptionPull = Spacing.d4;

  bool _horizontal(BuildContext context) => switch (orientation) {
    FieldOrientation.vertical => false,
    FieldOrientation.horizontal => true,
    FieldOrientation.responsive =>
      FieldGroupScope.maybeOf(context)?.wide ?? false,
  };

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final body = switch (_horizontal(context)) {
      true => _row(),
      false => _column(),
    };
    return FieldScope(
      invalid: invalid,
      disabled: disabled,
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        child: switch (invalid) {
          true => DefaultTextStyle.merge(
            style: TextStyle(color: colors.red),
            child: body,
          ),
          false => body,
        },
      ),
    );
  }

  Widget _column() => FieldStack(
    gap: (index, before, after) => switch (before) {
      FieldDescription() when index == children.length - 1 =>
        Spacing.d12 - _descriptionPull,
      _ => Spacing.d12,
    },
    children: [
      for (final child in children)
        switch (child) {
          ToggleGroup() => Align(
            alignment: AlignmentDirectional.centerStart,
            child: child,
          ),
          _ => child,
        },
    ],
  );

  Widget _row() {
    final withContent = children.any((child) => child is FieldContent);
    final withText = children.any(
      (child) => child is FieldLabel || child is FieldContent,
    );
    if (!withText) {
      return Wrap(
        spacing: Spacing.d12,
        runSpacing: Spacing.d12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
    }
    return Row(
      crossAxisAlignment: switch (withContent) {
        true => CrossAxisAlignment.start,
        false => CrossAxisAlignment.center,
      },
      spacing: Spacing.d12,
      children: [
        for (final child in children)
          switch (child) {
            FieldLabel() || FieldContent() => Expanded(child: child),
            Checkbox() || InkRadioGroupItem() when withContent => Padding(
              padding: const EdgeInsets.only(top: Spacing.d1),
              child: child,
            ),
            _ => child,
          },
      ],
    );
  }
}
