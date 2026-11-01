import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_addon.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_scope.dart';
import 'package:looseleaf_ui/src/components/input_group/input_group_textarea.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One drawn box around a text control and its addons: icons, text,
/// buttons, a counter, a header line.
///
/// [children] are an [InputGroupInput] or [InputGroupTextarea] plus any
/// [InputGroupAddon]s; the addons go where their `align` says, whatever
/// their order. The box draws the control's states: focus (when the control
/// has focus), [invalid] (red pencil) and [disabled] (dashes). Tapping an
/// addon outside its buttons focuses the control. It fills the width it is
/// given.
///
/// ```dart
/// InputGroup(
///   children: [
///     const InputGroupAddon(child: InkIcon('search')),
///     const InputGroupInput(placeholder: 'Search…'),
///     InputGroupAddon(
///       align: InputGroupAlign.inlineEnd,
///       child: InputGroupText(child: Text('12 results')),
///     ),
///   ],
/// )
/// ```
///
/// Upstream sets `aria-invalid` and `disabled` on the control; here the
/// group takes them and hands them to its control.
///
/// Mirrors `InputGroup` in upstream `src/components/ui/input-group.tsx`.
class InputGroup extends StatefulWidget {
  const InputGroup({
    super.key,
    required this.children,
    this.focusNode,
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The control and its addons.
  final List<Widget> children;

  /// The control's focus node; the group keeps its own when null.
  final FocusNode? focusNode;

  /// Disables the control, its text and buttons (upstream `disabled` on
  /// the control or `data-disabled` on the group).
  final bool disabled;

  /// The red-pencil box (upstream `aria-invalid` on the control).
  final bool invalid;

  /// Pins the hand.
  final String? seed;

  /// The group's accessible name.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<InputGroup> createState() => _InputGroupState();
}

class _InputGroupState extends State<InputGroup> with InkSeed {
  FocusNode? _ownFocusNode;
  bool _hovered = false;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(InputGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.focusNode ?? _ownFocusNode;
    if (old == _focusNode) return;
    old?.removeListener(_onFocus);
    _focusNode.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocus);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  List<Widget> _aligned(InputGroupAlign align) => [
    for (final child in widget.children)
      if (child is InputGroupAddon && child.align == align) child,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final group = widget;
    final controls = [
      for (final child in group.children)
        if (child is! InputGroupAddon) child,
    ];
    final aligns = {
      for (final child in group.children)
        if (child is InputGroupAddon) child.align,
    };
    final blocks =
        aligns.contains(InputGroupAlign.blockStart) ||
        aligns.contains(InputGroupAlign.blockEnd);
    final grows = blocks || controls.any((c) => c is InputGroupTextarea);
    final enabled = !group.disabled;
    final height = InputMetrics.height.resolve(theme.density);
    final line = Row(
      crossAxisAlignment: switch (grows) {
        true => CrossAxisAlignment.start,
        false => CrossAxisAlignment.center,
      },
      children: [
        ..._aligned(InputGroupAlign.inlineStart),
        for (final control in controls) Expanded(child: control),
        ..._aligned(InputGroupAlign.inlineEnd),
      ],
    );
    final body = switch (blocks) {
      true => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._aligned(InputGroupAlign.blockStart),
          line,
          ..._aligned(InputGroupAlign.blockEnd),
        ],
      ),
      false => line,
    };
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: group.semanticLabel,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InputGroupScope(
          focusNode: _focusNode,
          disabled: group.disabled,
          invalid: group.invalid,
          aligns: aligns,
          child: DefaultTextStyle.merge(
            style: InputMetrics.text(theme, disabled: group.disabled),
            child: InkSurface(
              source: RecipeInkSource(
                inputGroupRecipe,
                const NoParams(),
                json: const NoParams().toJson(),
              ),
              seed: inkSeed(group.seed),
              states: {
                ...group.forcedStates,
                if (!enabled) InkState.disabled,
                if (group.invalid) InkState.invalid,
                if (enabled && _hovered) InkState.hovered,
                if (enabled && _focusNode.hasFocus) InkState.focused,
              },
              still: true,
              child: switch (grows) {
                true => ConstrainedBox(
                  constraints: BoxConstraints(minHeight: height),
                  child: body,
                ),
                false => SizedBox(height: height, child: body),
              },
            ),
          ),
        ),
      ),
    );
  }
}
