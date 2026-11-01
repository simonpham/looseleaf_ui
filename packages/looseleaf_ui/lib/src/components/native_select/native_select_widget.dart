import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_list.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_metrics.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_option.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select_typeahead.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A plain select in a hand-drawn frame with a drawn chevron: the box
/// shows the chosen option's words, or a graphite [placeholder].
///
/// Flutter has no platform select, so the list is drawn under the box. It
/// behaves like a native one: Enter, Space or a tap opens it; the arrows,
/// Home and End move the highlight, Enter or Space choose, Escape closes,
/// and typed letters jump to options. On the closed box the arrows and
/// typed letters change the value directly. The box is as wide as its
/// longest option.
///
/// ```dart
/// NativeSelect<String>(
///   value: country,
///   placeholder: 'Choose a country',
///   onChanged: (value) => setState(() => country = value),
///   options: const [
///     NativeSelectOption(value: 'is', label: 'Iceland'),
///     NativeSelectOption(value: 'pt', label: 'Portugal'),
///   ],
/// )
/// ```
///
/// Mirrors upstream `src/components/ui/native-select.tsx`.
class NativeSelect<T> extends StatefulWidget {
  const NativeSelect({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.placeholder,
    this.size = NativeSelectSize.regular,
    this.disabled = false,
    this.invalid = false,
    this.seed,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// The chosen value; null shows the [placeholder].
  final T? value;

  /// [NativeSelectOption]s and [NativeSelectOptGroup]s.
  final List<NativeSelectEntry<T>> options;

  /// Called with the chosen option's value.
  final ValueChanged<T>? onChanged;

  /// Graphite words while nothing is chosen (upstream's empty-value
  /// option).
  final String? placeholder;

  final NativeSelectSize size;

  /// The dashed box, graphite words, no input.
  final bool disabled;

  /// The red-pencil box and the `!` (upstream `aria-invalid`).
  final bool invalid;

  /// Pins the hand.
  final String? seed;

  final FocusNode? focusNode;
  final bool autofocus;

  /// The accessible name.
  final String? semanticLabel;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  @override
  State<NativeSelect<T>> createState() => _NativeSelectState<T>();
}

class _NativeSelectState<T> extends State<NativeSelect<T>> with InkSeed {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _listFocus = FocusNode(debugLabel: 'NativeSelect list');
  final NativeSelectTypeahead _typeahead = NativeSelectTypeahead();
  FocusNode? _ownFocusNode;
  int _highlighted = -1;
  double _width = 0;

  FocusNode get _focusNode =>
      widget.focusNode ?? (_ownFocusNode ??= FocusNode());

  List<NativeSelectOption<T>> get _flat =>
      flattenNativeSelectEntries(widget.options);

  int get _selectedIndex =>
      _flat.indexWhere((option) => option.value == widget.value);

  @override
  void dispose() {
    _listFocus.dispose();
    _ownFocusNode?.dispose();
    super.dispose();
  }

  void _open() {
    if (widget.disabled || _portal.isShowing) return;
    _width = context.size?.width ?? 0;
    final selected = _selectedIndex;
    setState(() {
      _highlighted = switch (selected < 0) {
        true => _step(-1, 1),
        false => selected,
      };
    });
    _portal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _listFocus.requestFocus();
    });
  }

  void _toggle() {
    if (_portal.isShowing) return _close();
    _open();
  }

  void _close() {
    if (!_portal.isShowing) return;
    _portal.hide();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _choose(int index) {
    final options = _flat;
    if (index < 0 || index >= options.length) return;
    final option = options[index];
    if (option.disabled) return;
    if (option.value != widget.value) widget.onChanged?.call(option.value);
  }

  int _step(int from, int direction) {
    final options = _flat;
    var index = from + direction;
    while (index >= 0 && index < options.length) {
      if (!options[index].disabled) return index;
      index += direction;
    }
    return from;
  }

  int _edge(bool last) {
    final options = _flat;
    return switch (last) {
      true => _step(options.length, -1),
      false => _step(-1, 1),
    };
  }

  int? _typed(KeyEvent event, int current) {
    final char = event.character;
    if (char == null || char.trim().isEmpty || char.length != 1) return null;
    final options = _flat;
    return _typeahead.find(
      char,
      [for (final option in options) option.label],
      current,
      enabled: (index) => !options[index].disabled,
    );
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) return KeyEventResult.ignored;
    final current = _selectedIndex;
    final key = event.logicalKey;
    final next = switch (key) {
      LogicalKeyboardKey.arrowDown || LogicalKeyboardKey.arrowRight => _step(
        current,
        1,
      ),
      LogicalKeyboardKey.arrowUp || LogicalKeyboardKey.arrowLeft => _step(
        math.max(current, 0),
        -1,
      ),
      LogicalKeyboardKey.home => _edge(false),
      LogicalKeyboardKey.end => _edge(true),
      _ => _typed(event, current),
    };
    if (next == null) return KeyEventResult.ignored;
    _choose(next);
    return KeyEventResult.handled;
  }

  KeyEventResult _onListKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape || key == LogicalKeyboardKey.tab) {
      _close();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.space) {
      _choose(_highlighted);
      _close();
      return KeyEventResult.handled;
    }
    final next = switch (key) {
      LogicalKeyboardKey.arrowDown => _step(_highlighted, 1),
      LogicalKeyboardKey.arrowUp => _step(_highlighted, -1),
      LogicalKeyboardKey.home || LogicalKeyboardKey.pageUp => _edge(false),
      LogicalKeyboardKey.end || LogicalKeyboardKey.pageDown => _edge(true),
      _ => _typed(event, _highlighted),
    };
    if (next == null) return KeyEventResult.ignored;
    setState(() => _highlighted = next);
    return KeyEventResult.handled;
  }

  TextStyle _style(LooseleafThemeData theme) => theme.typography.face(
    KevinSansFace.hand,
    cssSize: widget.size.cssFontSize(theme.density),
    cssLineHeight: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final select = widget;
    final params = SelectParams(
      disabled: select.disabled,
      invalid: select.invalid,
    );
    final options = _flat;
    final selected = _selectedIndex;
    final label = switch (selected < 0) {
      true => select.placeholder,
      false => options[selected].label,
    };
    return Semantics(
      container: true,
      button: true,
      expanded: _portal.isShowing,
      enabled: !select.disabled,
      label: select.semanticLabel,
      value: label,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (context) => _popup(context, theme),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: _onTriggerKey,
              child: InkInteraction(
                enabled: !select.disabled,
                onActivate: _toggle,
                states: {
                  ...select.forcedStates,
                  if (select.invalid) InkState.invalid,
                },
                focusNode: _focusNode,
                autofocus: select.autofocus,
                mouseCursor: SystemMouseCursors.basic,
                disabledMouseCursor: SystemMouseCursors.forbidden,
                builder: (context, states) => _trigger(
                  theme,
                  RecipeInkSource(
                    nativeSelectRecipe,
                    params,
                    json: params.toJson(),
                  ),
                  states,
                  options,
                  selected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _trigger(
    LooseleafThemeData theme,
    InkSource source,
    Set<InkState> states,
    List<NativeSelectOption<T>> options,
    int selected,
  ) {
    final select = widget;
    final style = _style(theme).copyWith(
      color: switch ((select.disabled, selected < 0)) {
        (true, _) => theme.colors.pencilText,
        (false, true) => theme.colors.placeholder,
        (false, false) => theme.colors.inputInk,
      },
    );
    final labels = [?select.placeholder, for (final o in options) o.label];
    final shown = switch (selected < 0) {
      true => 0,
      false =>
        selected +
            switch (select.placeholder) {
              null => 0,
              _ => 1,
            },
    };
    return InkSurface(
      source: source,
      seed: inkSeed(select.seed),
      states: states,
      still: true,
      child: SizedBox(
        height: select.size.height.resolve(theme.density),
        child: Stack(
          alignment: AlignmentDirectional.centerStart,
          children: [
            Padding(
              padding: NativeSelectMetrics.padding.copyWith(
                end: switch (select.invalid) {
                  true => NativeSelectMetrics.invalidEnd,
                  false => NativeSelectMetrics.padding.end,
                },
              ),
              child: DefaultTextStyle(
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: ExcludeSemantics(
                  child: Stack(
                    alignment: AlignmentDirectional.centerStart,
                    children: [
                      for (final (index, text) in labels.indexed)
                        Visibility(
                          visible: index == shown,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Text(text),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              end: NativeSelectMetrics.chevronEnd,
              child: ExcludeSemantics(
                child: InkIcon(
                  'chevron-down',
                  size: NativeSelectMetrics.chevron,
                  color: switch (select.disabled) {
                    true => theme.colors.pencilText,
                    false => theme.colors.inkSoft,
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _popup(BuildContext context, LooseleafThemeData theme) =>
      CompositedTransformFollower(
        link: _link,
        targetAnchor: AlignmentDirectional.bottomStart.resolve(
          Directionality.of(context),
        ),
        followerAnchor: AlignmentDirectional.topStart.resolve(
          Directionality.of(context),
        ),
        offset: const Offset(0, NativeSelectMetrics.popupGap),
        child: Align(
          alignment: AlignmentDirectional.topStart,
          child: TapRegion(
            groupId: _link,
            onTapOutside: (_) => _close(),
            child: Focus(
              focusNode: _listFocus,
              onKeyEvent: _onListKey,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: _width,
                  maxHeight: NativeSelectMetrics.listMaxHeight,
                ),
                child: IntrinsicWidth(
                  child: PaperPopup(
                    seed: '${inkSeed(widget.seed)}|popup',
                    tilt: false,
                    child: NativeSelectList<T>(
                      entries: widget.options,
                      value: widget.value,
                      highlighted: _highlighted,
                      style: _style(theme),
                      onHighlight: (index) =>
                          setState(() => _highlighted = index),
                      onSelect: (index) {
                        _choose(index);
                        _close();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
