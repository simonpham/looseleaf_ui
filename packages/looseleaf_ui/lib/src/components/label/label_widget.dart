import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/label/label.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A form label in bold Kevin Sans Hand: `font-hand text-[15px]
/// leading-none font-bold`, graphite when its field is [disabled].
///
/// Give it the field's [focusNode] and tapping the words focuses the field,
/// like `<Label htmlFor>`. [required] adds a drawn red star; it is
/// decorative, so mark the field itself as required for screen readers.
///
/// ```dart
/// Label(focusNode: emailFocus, required: true, child: const Text('Email'))
/// ```
///
/// Mirrors upstream `src/components/ui/label.tsx`.
class Label extends StatefulWidget {
  const Label({
    super.key,
    required this.child,
    this.focusNode,
    this.onPressed,
    this.required = false,
    this.disabled = false,
    this.seed,
  });

  /// The words, usually a [Text].
  final Widget child;

  /// The field this labels: a tap on the label focuses it.
  final FocusNode? focusNode;

  /// Called on tap, after [focusNode] is focused; for labels that toggle
  /// their control, like a checkbox's.
  final VoidCallback? onPressed;

  /// Draws the red required star after the words.
  final bool required;

  /// Graphite text and no input, for a disabled field
  /// (`peer-disabled:text-pencil-text`).
  final bool disabled;

  /// Pins the star's hand.
  final String? seed;

  @override
  State<Label> createState() => _LabelState();
}

class _LabelState extends State<Label> with InkSeed {
  void _onTap() {
    widget.focusNode?.requestFocus();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final label = InkContent(
      style: theme.typography.label(
        color: switch (widget.disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.ink,
        },
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d4,
        children: [
          Flexible(child: widget.child),
          if (widget.required)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d1),
              child: LabelRequiredMark(seed: inkSeed(widget.seed)),
            ),
        ],
      ),
    );
    final tappable = widget.focusNode != null || widget.onPressed != null;
    if (widget.disabled || !tappable) return label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: _onTap,
      child: label,
    );
  }
}
