import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/accordion/accordion_scope.dart';
import 'package:looseleaf_ui/src/components/collapsible/collapsible.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The heading row that opens and shuts its [AccordionItem]: bold hand
/// text and a chevron that turns over. Hover swipes a highlighter across;
/// keyboard focus draws a felt ring round the row.
///
/// Enter and Space toggle; ArrowDown, ArrowUp, Home and End move between
/// the accordion's triggers.
///
/// Mirrors `AccordionTrigger` in upstream `src/components/ui/accordion.tsx`.
class AccordionTrigger extends StatefulWidget {
  const AccordionTrigger({
    super.key,
    required this.child,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
    this.padding,
    this.minHeight,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  });

  final Widget child;

  /// The room round the row; `py-3.5` (`compact:py-2.5`, `calm:py-2`) when
  /// null.
  final EdgeInsetsGeometry? padding;

  /// The row's least height (upstream `min-h-*`).
  final double? minHeight;

  /// Where the label and chevron sit in a row taller than they are:
  /// [CrossAxisAlignment.start] (upstream's default), or
  /// [CrossAxisAlignment.end] to sit them on the bottom line of ruled
  /// paper (`items-end`).
  final CrossAxisAlignment crossAxisAlignment;

  /// Pins the hand: the same seed always draws the same swipe and ring.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<AccordionTrigger> createState() => _AccordionTriggerState();
}

class _AccordionTriggerState extends State<AccordionTrigger> with InkSeed {
  FocusNode? _ownNode;
  AccordionTriggers? _triggers;
  int? _index;

  FocusNode get _node =>
      widget.focusNode ??
      (_ownNode ??= FocusNode(debugLabel: 'AccordionTrigger'));

  /// `py-3.5 compact:py-2.5 calm:py-2`.
  static const _padding = ByDensity(
    comfortable: Spacing.d14,
    compact: Spacing.d10,
    calm: Spacing.d8,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final triggers = AccordionScope.maybeOf(context)?.triggers;
    final index = AccordionSlot.maybeOf(context)?.index;
    if (triggers == _triggers && index == _index) return;
    if (_index case final old?) _triggers?.unregister(old, _node);
    _triggers = triggers;
    _index = index;
    if (index != null) triggers?.register(index, _node);
  }

  @override
  void dispose() {
    if (_index case final index?) _triggers?.unregister(index, _node);
    _ownNode?.dispose();
    super.dispose();
  }

  Map<ShortcutActivator, VoidCallback> get _keys => {
    const SingleActivator(LogicalKeyboardKey.arrowDown): () =>
        _triggers?.move(_node, 1),
    const SingleActivator(LogicalKeyboardKey.arrowUp): () =>
        _triggers?.move(_node, -1),
    const SingleActivator(LogicalKeyboardKey.home): () =>
        _triggers?.edge(last: false),
    const SingleActivator(LogicalKeyboardKey.end): () =>
        _triggers?.edge(last: true),
  };

  @override
  Widget build(BuildContext context) {
    final item = AccordionItemScope.maybeOf(context);
    final accordion = AccordionScope.maybeOf(context);
    final disabled = item?.disabled ?? false;
    final open = item?.open ?? false;
    final params = AccordionTriggerParams(disabled: disabled);
    final source = RecipeInkSource(
      accordionTriggerRecipe,
      params,
      json: params.toJson(),
    );
    return Semantics(
      header: true,
      child: Semantics(
        container: true,
        button: true,
        expanded: open,
        enabled: !disabled,
        child: CallbackShortcuts(
          bindings: _keys,
          child: InkInteraction(
            enabled: !disabled,
            onActivate: () {
              if (item case final scope?) accordion?.toggle(scope.value);
            },
            states: {...widget.forcedStates, if (open) InkState.open},
            focusNode: _node,
            autofocus: widget.autofocus,
            builder: (context, states) =>
                _body(context, source, states, open: open, disabled: disabled),
          ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    InkSource source,
    Set<InkState> states, {
    required bool open,
    required bool disabled,
  }) {
    final theme = LooseleafTheme.of(context);
    final calm = theme.density == LooseleafDensity.calm;
    final vertical = _padding.of(context);
    final padding = widget.padding ?? EdgeInsets.symmetric(vertical: vertical);
    final chevronRoom = switch (widget.crossAxisAlignment) {
      CrossAxisAlignment.start => const EdgeInsets.only(top: Spacing.d4),
      CrossAxisAlignment.end => const EdgeInsets.only(bottom: Spacing.d6),
      _ => EdgeInsets.zero,
    };
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: switch (calm) {
          true => 15,
          false => 16,
        },
        cssLineHeight: switch (calm) {
          true => null,
          false => 1.5,
        },
        fontWeight: FontWeight.w700,
        color: switch (disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.ink,
        },
      ),
      iconSize: Spacing.d16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -Spacing.d8,
            right: -Spacing.d8,
            top: 0,
            bottom: 0,
            child: InkSurface(
              source: source,
              seed: inkSeed(widget.seed),
              states: states,
              still: true,
              swipeOnHover: true,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight ?? 0),
            child: Padding(
              padding: padding,
              child: Row(
                crossAxisAlignment: widget.crossAxisAlignment,
                spacing: Spacing.d16,
                children: [
                  Expanded(child: widget.child),
                  Padding(
                    padding: chevronRoom,
                    child: CollapsibleIndicator(open: open),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
