import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle_metrics.dart';
import 'package:looseleaf_ui/src/components/toggle/toggle_surface.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';

/// A two-state button: a whisper box (or an inked one for
/// [ToggleVariant.outline]) that a highlighter fills when pressed on.
///
/// Tapping it, Enter or Space call [onChanged] with the opposite of
/// [value]; without a [value] it keeps its own, starting at
/// [defaultValue]. Its content is an icon, a word, or a [leading] icon and a
/// word.
///
/// ```dart
/// Toggle(
///   value: bold,
///   onChanged: (value) => setState(() => bold = value),
///   semanticLabel: 'Bold',
///   child: const Icon(boldIcon),
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/toggle.tsx`.
class Toggle extends StatefulWidget {
  const Toggle({
    super.key,
    required this.child,
    this.value,
    this.defaultValue = false,
    this.leading,
    this.onChanged,
    this.variant = ToggleVariant.primary,
    this.size = ToggleSize.regular,
    this.tone,
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// Pressed on (upstream `pressed`, `data-state=on`). Null leaves the
  /// toggle to keep its own state, starting at [defaultValue].
  final bool? value;

  /// The state a toggle without [value] starts in (upstream
  /// `defaultPressed`).
  final bool defaultValue;

  /// Called with the next value on tap, Enter and Space. A null callback
  /// does not disable the toggle; [disabled] does.
  final ValueChanged<bool>? onChanged;

  final ToggleVariant variant;
  final ToggleSize size;

  /// The fill when on: highlighter ([ToggleTone.hi], the default) or
  /// marker.
  final ToggleTone? tone;

  /// Graphite content, no input, out of the tab order.
  final bool disabled;

  /// Red pencil (upstream `aria-invalid`).
  final bool invalid;

  /// The content: an icon or a word.
  final Widget child;

  /// An icon before a word [child].
  final Widget? leading;

  /// Pins the hand: the same seed always draws the same box.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name, for icon toggles.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<Toggle> createState() => _ToggleState();
}

class _ToggleState extends State<Toggle> with InkSeed {
  late bool _own = widget.defaultValue;

  bool get _value => widget.value ?? _own;

  void _toggle() {
    final next = !_value;
    if (widget.value == null) setState(() => _own = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final toggle = widget;
    final value = _value;
    return Semantics(
      container: true,
      button: true,
      toggled: value,
      enabled: !toggle.disabled,
      label: toggle.semanticLabel,
      child: InkInteraction(
        enabled: !toggle.disabled,
        onActivate: _toggle,
        states: {
          ...toggle.forcedStates,
          if (value) InkState.checked,
          if (toggle.invalid) InkState.invalid,
        },
        focusNode: toggle.focusNode,
        autofocus: toggle.autofocus,
        builder: (context, states) => ToggleSurface(
          params: ToggleParams(
            variant: toggle.variant,
            disabled: toggle.disabled,
            tone: toggle.tone,
            invalid: toggle.invalid,
          ),
          seed: inkSeed(toggle.seed),
          states: states,
          size: toggle.size,
          leading: toggle.leading,
          child: toggle.child,
        ),
      ),
    );
  }
}
