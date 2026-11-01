import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The pressable part of a sticky note's tick box: a 32 px round checkbox
/// over the drawn box, tinted on hover, ringed in focus blue for the
/// keyboard. Tap and Space call [onChanged] with the opposite of [value].
/// A `StickyNote` places it when given `onDoneChange`.
///
/// Mirrors `sticky-note-check` in upstream `src/components/ui/sticky-note.tsx`.
class StickyNoteCheck extends StatelessWidget {
  const StickyNoteCheck({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Whether the note is done.
  final bool value;

  /// Called with the opposite of [value].
  final ValueChanged<bool> onChanged;

  /// The checkbox's accessible name.
  final String label;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input: for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    return Semantics(
      container: true,
      checked: value,
      label: label,
      child: InkInteraction(
        onActivate: () => onChanged(!value),
        activation: InkActivation.toggle,
        states: forcedStates,
        focusNode: focusNode,
        autofocus: autofocus,
        builder: (context, states) => DecoratedBox(
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: switch (states.contains(InkState.focused)) {
                true => BorderSide(
                  color: colors.focus,
                  width: Spacing.d2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
                false => BorderSide.none,
              },
            ),
            color: switch (states.contains(InkState.hovered)) {
              true => colors.ink.withValues(alpha: 0.1),
              false => null,
            },
          ),
          child: const SizedBox.square(dimension: Spacing.d32),
        ),
      ),
    );
  }
}
