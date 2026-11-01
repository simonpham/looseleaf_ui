import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/envelope/envelope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The button over a whole [EnvelopeFront]: tap, Enter or Space opens and
/// closes the envelope. It shows nothing but a focus outline; [label] is
/// its accessible name, and should say what opening does. Use it as a
/// direct child of an [EnvelopeFront]; a sealed envelope disables it.
///
/// Mirrors `EnvelopeTrigger` in upstream `src/components/ui/envelope.tsx`.
class EnvelopeTrigger extends StatelessWidget {
  const EnvelopeTrigger({
    super.key,
    this.label = defaultLabel,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// Upstream's default name.
  static const String defaultLabel = 'Open the letter';

  /// The accessible name, like "Read the letter from Ada".
  final String label;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    final envelope = EnvelopeScope.maybeOf(context);
    final disabled = envelope?.disabled ?? false;
    final focus = LooseleafTheme.of(context).colors.focus;
    return Positioned.fill(
      child: Semantics(
        container: true,
        button: true,
        enabled: !disabled,
        expanded: envelope?.open ?? false,
        label: label,
        child: InkInteraction(
          enabled: !disabled,
          onActivate: envelope?.toggle,
          states: forcedStates,
          focusNode: focusNode,
          autofocus: autofocus,
          disabledMouseCursor: SystemMouseCursors.forbidden,
          builder: (context, states) => DecoratedBox(
            decoration: BoxDecoration(
              border: switch (states.contains(InkState.focused)) {
                true => Border.all(color: focus, width: Spacing.d2),
                false => null,
              },
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
