import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/calendar/calendar_metrics.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/native_select/native_select.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// A month or year select in a [Calendar]'s caption: the value in script
/// in a pencil box (`calendarDropdownRecipe`) with a small chevron, and a
/// list on a slip of paper under it.
///
/// Arrow keys on the closed box step the value like a native select;
/// Enter, Space or a tap open the list, where arrows move, Enter picks
/// and Escape closes.
///
/// Mirrors `CalendarDropdown` in upstream `src/components/ui/calendar.tsx`.
class CalendarDropdown extends StatefulWidget {
  const CalendarDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    this.disabled = false,
    this.semanticLabel,
    this.seed,
    this.forcedStates = const {},
  });

  /// The chosen option's value.
  final int value;

  /// The choices; disabled ones are graphite and skipped.
  final List<NativeSelectOption<int>> options;

  final ValueChanged<int> onChanged;

  /// The box in graphite, no input.
  final bool disabled;

  /// The accessible name ("Choose the Month").
  final String? semanticLabel;

  /// Pins the box.
  final String? seed;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<CalendarDropdown> createState() => _CalendarDropdownState();
}

class _CalendarDropdownState extends State<CalendarDropdown> with InkSeed {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final FocusNode _focusNode = FocusNode(debugLabel: 'CalendarDropdown');
  final FocusNode _listFocus = FocusNode(debugLabel: 'CalendarDropdown list');
  final GlobalKey _highlightedKey = GlobalKey();
  int _highlighted = 0;

  int get _selected =>
      widget.options.indexWhere((option) => option.value == widget.value);

  @override
  void dispose() {
    _focusNode.dispose();
    _listFocus.dispose();
    super.dispose();
  }

  int _step(int from, int direction) {
    final options = widget.options;
    var index = from + direction;
    while (index >= 0 && index < options.length) {
      if (!options[index].disabled) return index;
      index += direction;
    }
    return from;
  }

  void _open() {
    if (widget.disabled || _portal.isShowing) return;
    setState(() => _highlighted = _selected);
    _portal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _listFocus.requestFocus();
      _reveal();
    });
  }

  void _reveal() {
    final target = _highlightedKey.currentContext;
    if (target == null) return;
    unawaited(
      Scrollable.ensureVisible(target, alignment: 0.5, duration: Duration.zero),
    );
  }

  void _close() {
    if (!_portal.isShowing) return;
    _portal.hide();
    setState(() {});
    _focusNode.requestFocus();
  }

  void _choose(int index) {
    final options = widget.options;
    if (index < 0 || index >= options.length) return;
    final option = options[index];
    if (option.disabled || option.value == widget.value) return;
    widget.onChanged(option.value);
  }

  KeyEventResult _onTriggerKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent || widget.disabled) return KeyEventResult.ignored;
    final next = switch (event.logicalKey) {
      LogicalKeyboardKey.arrowDown => _step(_selected, 1),
      LogicalKeyboardKey.arrowUp => _step(_selected, -1),
      _ => null,
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
      LogicalKeyboardKey.home => _step(-1, 1),
      LogicalKeyboardKey.end => _step(widget.options.length, -1),
      _ => null,
    };
    if (next == null) return KeyEventResult.ignored;
    setState(() => _highlighted = next);
    WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    return KeyEventResult.handled;
  }

  TextStyle _style(LooseleafThemeData theme, Color color) =>
      theme.typography.face(
        KevinSansFace.script,
        cssSize: CalendarMetrics.dropdownSize,
        cssLineHeight: 1,
        fontWeight: FontWeight.w600,
        color: color,
      );

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final dropdown = widget;
    final params = CalendarDropdownParams(disabled: dropdown.disabled);
    final selected = _selected;
    final label = switch (selected < 0) {
      true => '',
      false => dropdown.options[selected].label,
    };
    return Semantics(
      container: true,
      button: true,
      expanded: _portal.isShowing,
      enabled: !dropdown.disabled,
      label: dropdown.semanticLabel,
      value: label,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(
          groupId: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (context) => _popup(theme),
            child: Focus(
              canRequestFocus: false,
              skipTraversal: true,
              onKeyEvent: _onTriggerKey,
              child: InkInteraction(
                enabled: !dropdown.disabled,
                onActivate: _open,
                states: dropdown.forcedStates,
                focusNode: _focusNode,
                disabledMouseCursor: SystemMouseCursors.forbidden,
                builder: (context, states) => InkSurface(
                  source: RecipeInkSource(
                    calendarDropdownRecipe,
                    params,
                    json: params.toJson(),
                  ),
                  seed: inkSeed(dropdown.seed),
                  states: states,
                  still: true,
                  child: _box(theme, label),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(LooseleafThemeData theme, String label) {
    final colors = theme.colors;
    final disabled = widget.disabled;
    return SizedBox(
      height: CalendarMetrics.dropdownHeight.resolve(theme.density),
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Padding(
            padding: CalendarMetrics.dropdownPadding,
            child: ExcludeSemantics(
              child: Text(
                label,
                maxLines: 1,
                style: _style(theme, switch (disabled) {
                  true => colors.pencilText,
                  false => colors.ink,
                }),
              ),
            ),
          ),
          PositionedDirectional(
            end: CalendarMetrics.dropdownChevronEnd,
            child: ExcludeSemantics(
              child: InkIcon(
                'chevron-down',
                size: CalendarMetrics.dropdownChevron,
                color: switch (disabled) {
                  true => colors.pencilText,
                  false => colors.inkSoft,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _popup(LooseleafThemeData theme) {
    final direction = Directionality.of(context);
    final style = theme.typography.face(KevinSansFace.hand, cssLineHeight: 1.5);
    return CompositedTransformFollower(
      link: _link,
      targetAnchor: AlignmentDirectional.bottomStart.resolve(direction),
      followerAnchor: AlignmentDirectional.topStart.resolve(direction),
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
              constraints: const BoxConstraints(
                maxHeight: NativeSelectMetrics.listMaxHeight,
              ),
              child: IntrinsicWidth(
                child: PaperPopup(
                  seed: '${inkSeed(widget.seed)}|list',
                  tilt: false,
                  child: SingleChildScrollView(
                    padding: NativeSelectMetrics.listPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final (index, option) in widget.options.indexed)
                          _option(theme, style, option, index),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _option(
    LooseleafThemeData theme,
    TextStyle style,
    NativeSelectOption<int> option,
    int index,
  ) {
    final colors = theme.colors;
    final lit = index == _highlighted && !option.disabled;
    return Semantics(
      key: switch (index == _highlighted) {
        true => _highlightedKey,
        false => null,
      },
      button: true,
      selected: option.value == widget.value,
      enabled: !option.disabled,
      child: MouseRegion(
        onEnter: switch (option.disabled) {
          true => null,
          false => (_) => setState(() => _highlighted = index),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: switch (option.disabled) {
            true => null,
            false => () {
              _choose(index);
              _close();
            },
          },
          child: ColoredBox(
            color: switch (lit) {
              true => colors.hiSelect,
              false => colors.hiSelect.withValues(alpha: 0),
            },
            child: Padding(
              padding: NativeSelectMetrics.optionPadding,
              child: Text(
                option.label,
                style: style.copyWith(
                  color: switch (option.disabled) {
                    true => colors.pencilText,
                    false => colors.ink,
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
