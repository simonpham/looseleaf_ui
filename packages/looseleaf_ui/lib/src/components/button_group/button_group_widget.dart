import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button_group/button_group.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Buttons, inputs and [ButtonGroupText] cells joined in one row (or
/// column): members stretch to the same height and share their seams, so
/// the edge between two outline buttons is drawn once. Put a
/// [ButtonGroupSeparator] between filled buttons. Nested groups sit 8 px
/// apart. Wrap a member in [Expanded] to let it fill the row, like an input.
///
/// ```dart
/// ButtonGroup(
///   semanticLabel: 'Range',
///   children: [
///     Button(variant: ButtonVariant.outline, child: Text('Years')),
///     Button(variant: ButtonVariant.outline, child: Text('Months')),
///   ],
/// )
/// ```
///
/// Mirrors `ButtonGroup` in upstream `src/components/ui/button-group.tsx`.
class ButtonGroup extends StatelessWidget {
  const ButtonGroup({
    super.key,
    required this.children,
    this.orientation = SeparatorOrientation.horizontal,
    this.semanticLabel,
  });

  /// The members.
  final List<Widget> children;

  /// A row or a column.
  final SeparatorOrientation orientation;

  /// The group's accessible name, upstream's `aria-label`.
  final String? semanticLabel;

  Axis get _axis => switch (orientation) {
    SeparatorOrientation.horizontal => Axis.horizontal,
    SeparatorOrientation.vertical => Axis.vertical,
  };

  static bool _isSeparator(Widget child) => child is ButtonGroupSeparator;

  static Widget _inner(Widget child) => switch (child) {
    Flexible(:final child) => child,
    _ => child,
  };

  Widget _member(int index) {
    final child = children[index];
    final inner = _inner(child);
    if (_isSeparator(inner) || inner is ButtonGroup) return child;
    final next = switch (index + 1 < children.length) {
      true => _inner(children[index + 1]),
      false => null,
    };
    final seam = ButtonGroupSeam(
      axis: _axis,
      clipStart: index > 0,
      clipEnd: next is ButtonGroupSeparator,
      child: inner,
    );
    return switch (child) {
      Flexible(:final flex, :final fit) => Flexible(
        flex: flex,
        fit: fit,
        child: seam,
      ),
      _ => seam,
    };
  }

  @override
  Widget build(BuildContext context) {
    final nested = children.any((child) => _inner(child) is ButtonGroup);
    final gap = switch (nested) {
      true => Spacing.d8,
      false => 0.0,
    };
    final members = [for (var i = 0; i < children.length; i++) _member(i)];
    final group = switch (_axis) {
      Axis.horizontal => IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: members,
        ),
      ),
      Axis.vertical => IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: gap,
          children: members,
        ),
      ),
    };
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: semanticLabel,
      child: group,
    );
  }
}
