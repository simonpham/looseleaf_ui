import 'dart:ui' show SemanticsRole;

import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/folder/folder.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/tabs/tabs.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// One tab of a [FolderTabs]: bold hand text on a paper tab of the
/// folder's stock, 36 px high (32 compact, 28 calm). The open tab stands
/// 4 px taller and runs into the body; the others sit lower and shaded and
/// catch a sheen on hover. A disabled tab is a dashed pencil ghost, skipped
/// by the arrows. Keyboard focus draws a 2 px focus outline.
///
/// Mirrors `FolderTab` in upstream `src/components/ui/folder.tsx`.
class FolderTab extends StatefulWidget {
  const FolderTab({
    super.key,
    required this.value,
    required this.child,
    this.disabled = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The [FolderContent] this tab opens.
  final String value;

  /// The label, usually a [Text].
  final Widget child;

  /// Drawn as a dashed ghost, skipped by the keyboard, no input.
  final bool disabled;

  /// Pins the tab's paper.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<FolderTab> createState() => _FolderTabState();
}

class _FolderTabState extends State<FolderTab> with InkSeed {
  FocusNode? _ownFocusNode;
  late InkRovingEntry _entry = InkRovingEntry(_focusNode);
  InkRovingFocusState? _roving;

  static const _height = ByDensity(
    comfortable: Spacing.d36,
    compact: Spacing.d32,
    calm: Spacing.d28,
  );

  static const _inline = ByDensity(
    comfortable: Spacing.d24,
    compact: Spacing.d20,
    calm: Spacing.d16,
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
  void didUpdateWidget(FolderTab oldWidget) {
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
    final folder = FolderScope.maybeOf(context);
    final active = folder?.value == widget.value;
    final disabled = widget.disabled;
    void select() => folder?.select(widget.value);
    final entry = _entry;
    if (entry.active != active || entry.enabled == disabled) {
      entry
        ..active = active
        ..enabled = !disabled;
      _roving?.markChanged();
    }
    entry.onArrive = switch (folder?.activationMode) {
      TabsActivationMode.automatic => select,
      _ => null,
    };
    final params = FolderTabParams(
      stock: folder?.stock ?? StockName.kraft,
      disabled: disabled,
    );
    final source = RecipeInkSource(
      folderTabRecipe,
      params,
      json: params.toJson(),
    );
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
        disabledMouseCursor: SystemMouseCursors.forbidden,
        builder: (context, states) => _body(context, source, states, active),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    InkSource source,
    Set<InkState> states,
    bool active,
  ) {
    final theme = LooseleafTheme.of(context);
    final focused = states.contains(InkState.focused);
    final shown = switch (active) {
      true => states.difference(const {InkState.hovered}),
      false => states,
    };
    return InkContent(
      style: theme.typography.face(
        KevinSansFace.hand,
        cssSize: 15,
        fontWeight: FontWeight.w700,
        color: switch (widget.disabled) {
          true => theme.colors.pencilText,
          false => theme.colors.ink,
        },
      ),
      wrap: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          InkSurface(
            source: source,
            seed: inkSeed(widget.seed),
            states: shown,
            still: true,
            child: SizedBox(
              height: _height.of(context),
              child: Padding(
                padding: EdgeInsets.only(
                  left: _inline.of(context),
                  right: _inline.of(context),
                  top: switch (active) {
                    true => Spacing.d2,
                    false => Spacing.d4,
                  },
                ),
                child: Align(widthFactor: 1, child: widget.child),
              ),
            ),
          ),
          if (focused)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colors.focus,
                      width: Spacing.d2,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
