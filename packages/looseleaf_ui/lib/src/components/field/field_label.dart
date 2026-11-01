import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/field/field.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/label/label.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A field's label: bold 15 px, red when the [Field] is invalid, graphite
/// when it is disabled. A tap focuses [focusNode] and calls [onPressed]
/// (toggle a checkbox there), like `<label htmlFor>`.
///
/// Around a whole [Field] it becomes a choice card: a pencil box that
/// darkens on hover and takes a highlighter wash and a felt box when
/// [checked]; a tap anywhere on it calls [onPressed].
///
/// ```dart
/// FieldLabel(
///   checked: plan == 'studio',
///   onPressed: () => setPlan('studio'),
///   child: Field(
///     orientation: FieldOrientation.horizontal,
///     children: [
///       FieldContent(children: [FieldTitle(Text('Studio'))]),
///       RadioGroupItem(value: 'studio'),
///     ],
///   ),
/// )
/// ```
///
/// Mirrors `FieldLabel` in upstream `src/components/ui/field.tsx`.
class FieldLabel extends StatefulWidget {
  const FieldLabel({
    super.key,
    required this.child,
    this.focusNode,
    this.onPressed,
    this.required = false,
    this.card,
    this.checked = false,
    this.seed,
    this.forcedStates = const {},
  });

  /// The words, or a whole [Field] for a choice card.
  final Widget child;

  /// The control this labels: a tap focuses it.
  final FocusNode? focusNode;

  /// Called on tap, after [focusNode] is focused.
  final VoidCallback? onPressed;

  /// Draws the red required star after the words.
  final bool required;

  /// Draws the choice card; by default when [child] is a [Field].
  final bool? card;

  /// Whether the card's control is checked: the highlighter wash.
  final bool checked;

  /// Pins the card's and the star's hand.
  final String? seed;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  /// The label color inside the nearest [Field]: red when invalid,
  /// graphite when disabled, ink otherwise.
  static Color colorIn(BuildContext context) {
    final colors = LooseleafTheme.of(context).colors;
    final field = FieldScope.maybeOf(context);
    if (field == null) return colors.ink;
    if (field.invalid) return colors.red;
    if (field.disabled) return colors.pencilText;
    return colors.ink;
  }

  @override
  State<FieldLabel> createState() => _FieldLabelState();
}

class _FieldLabelState extends State<FieldLabel> with InkSeed {
  var _hovered = false;

  bool get _card => widget.card ?? widget.child is Field;

  bool get _disabled => FieldScope.maybeOf(context)?.disabled ?? false;

  void _onTap() {
    widget.focusNode?.requestFocus();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_card) return _choiceCard(context);
    final theme = LooseleafTheme.of(context);
    final label = InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        cssLineHeight: 1.375,
        fontWeight: FontWeight.w700,
        color: FieldLabel.colorIn(context),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: Spacing.d8,
        children: [
          Flexible(child: widget.child),
          if (widget.required)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.d3),
              child: LabelRequiredMark(seed: inkSeed(widget.seed)),
            ),
        ],
      ),
    );
    final tappable = widget.focusNode != null || widget.onPressed != null;
    if (_disabled || !tappable) return label;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTap: _onTap,
      child: label,
    );
  }

  Widget _choiceCard(BuildContext context) {
    const params = NoParams();
    final states = {
      ...widget.forcedStates,
      if (_hovered) InkState.hovered,
      if (widget.checked) InkState.checked,
    };
    final card = InkSurface(
      source: RecipeInkSource(fieldChoiceRecipe, params),
      seed: inkSeed(widget.seed),
      states: states,
      still: true,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.d16),
        child: widget.child,
      ),
    );
    if (_disabled) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: _onTap,
        child: card,
      ),
    );
  }
}
