import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs_scope.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One tab of a [TabsList]: bold hand text on a drawn index tab. The
/// active one is filled with highlighter and, as a folder tab, lifted 2 px
/// (moved 2 px towards the panel when vertical).
///
/// Mirrors `TabsTrigger` in upstream `src/components/ui/tabs.tsx`.
class TabsTrigger extends StatefulWidget {
  const TabsTrigger({
    super.key,
    required this.value,
    required this.child,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The [TabsContent] this tab opens.
  final String value;

  /// The label; icons in it are 16.
  final Widget child;
  final bool disabled;

  /// Pins the hand: the same seed always draws the same tab.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<TabsTrigger> createState() => _TabsTriggerState();
}

class _TabsTriggerState extends State<TabsTrigger> with InkSeed {
  FocusNode? _ownFocusNode;
  late InkRovingEntry _entry = InkRovingEntry(_focusNode);
  InkRovingFocusState? _roving;

  /// `h-9 compact:h-8 calm:h-7`.
  static const _height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final roving = InkRovingFocus.maybeOf(context);
    if (identical(roving, _roving)) return;
    _roving?.unregister(_entry);
    _roving = roving;
    roving?.register(_entry);
  }

  @override
  void didUpdateWidget(TabsTrigger oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(_entry.focusNode, _focusNode)) return;
    _roving?.unregister(_entry);
    _entry = InkRovingEntry(_focusNode);
    _roving?.register(_entry);
  }

  @override
  void dispose() {
    _roving?.unregister(_entry);
    _ownFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = TabsScope.maybeOf(context);
    final variant =
        TabsListScope.maybeOf(context)?.variant ?? TabsVariant.folder;
    final orientation = tabs?.orientation ?? TabsOrientation.horizontal;
    final active = tabs?.value == widget.value;
    final disabled = widget.disabled;
    void select() => tabs?.select(widget.value);
    final entry = _entry;
    if (entry.active != active || entry.enabled == disabled) {
      entry
        ..active = active
        ..enabled = !disabled;
      _roving?.markChanged();
    }
    entry.onArrive = switch (tabs?.activationMode) {
      TabsActivationMode.automatic => select,
      _ => null,
    };
    final params = TabsParams(
      variant: variant,
      orientation: orientation,
      disabled: disabled,
    );
    final source = RecipeInkSource(tabsRecipe, params, json: params.toJson());
    return Semantics(
      container: true,
      role: SemanticsRole.tab,
      selected: active,
      enabled: !disabled,
      child: InkInteraction(
        enabled: !disabled,
        onActivate: select,
        states: {...widget.forcedStates, if (active) InkState.checked},
        focusNode: _focusNode,
        autofocus: widget.autofocus,
        builder: (context, states) => _body(
          context,
          source,
          states,
          variant: variant,
          orientation: orientation,
          active: active,
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    InkSource source,
    Set<InkState> states, {
    required TabsVariant variant,
    required TabsOrientation orientation,
    required bool active,
  }) {
    final theme = LooseleafTheme.of(context);
    final colors = theme.colors;
    final calm = theme.density == LooseleafDensity.calm;
    final vertical = orientation == TabsOrientation.vertical;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final color = switch ((
      widget.disabled,
      active || states.contains(InkState.hovered),
    )) {
      (true, _) => colors.pencilText,
      (false, true) => colors.ink,
      (false, false) => colors.inkMuted,
    };
    final lift = switch ((variant, active, vertical, rtl)) {
      (TabsVariant.folder, true, false, _) => const Offset(0, -Spacing.d2),
      (TabsVariant.folder, true, true, false) => const Offset(Spacing.d2, 0),
      (TabsVariant.folder, true, true, true) => const Offset(-Spacing.d2, 0),
      _ => Offset.zero,
    };
    return TweenAnimationBuilder<Offset>(
      tween: Tween(end: lift),
      duration: InkMotion.of(context, InkMotion.hover),
      curve: InkMotion.settle,
      builder: (context, offset, child) =>
          Transform.translate(offset: offset, child: child),
      child: InkContent(
        style: theme.typography.face(
          KevinSansFace.hand,
          cssSize: switch (calm) {
            true => 14,
            false => 15,
          },
          cssLineHeight: switch (calm) {
            true => 20 / 14,
            false => null,
          },
          fontWeight: FontWeight.w700,
          color: color,
        ),
        iconSize: Spacing.d16,
        wrap: false,
        child: InkSurface(
          source: source,
          seed: inkSeed(widget.seed),
          states: states,
          still: true,
          child: SizedBox(
            height: _height.of(context),
            child: Padding(
              padding: EdgeInsets.only(
                left: Spacing.d16,
                right: Spacing.d16,
                top: switch (vertical) {
                  true => Spacing.d2,
                  false => Spacing.d4,
                },
              ),
              child: Align(
                widthFactor: 1,
                alignment: switch (vertical) {
                  true => AlignmentDirectional.centerStart,
                  false => AlignmentDirectional.center,
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
