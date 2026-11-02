import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/overlay/overlay.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// Builds a part of the popup; [close] closes it.
typedef DatePickerPopupBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback close,
    );

/// The field both date pickers share: a select-like pencil box you can
/// type a date in, with a calendar button in its end cell, or (when not
/// [typeable]) one button showing the date; and the popup under it
/// holding the presets and the calendar.
///
/// Typed text is read when you press Enter or leave the field: [onCommit]
/// says whether it could be read, and an unreadable date draws the red box
/// until the next edit. ArrowDown opens the popup, Escape closes it and
/// returns focus to the calendar button; Escape with unsent text drops it.
///
/// Mirrors `PickerShell` in upstream `src/components/ui/date-picker.tsx`.
class DatePickerShell extends StatefulWidget {
  const DatePickerShell({
    super.key,
    required this.text,
    required this.onCommit,
    required this.calendar,
    required this.placeholder,
    this.presets,
    this.typeable = true,
    this.disabled = false,
    this.readOnly = false,
    this.invalid = false,
    this.open,
    this.onOpenChange,
    this.calendarLabel = 'Choose date',
    this.invalidMessage = 'Enter a date we can read.',
    this.seed,
    this.semanticLabel,
    this.autofocus = false,
    this.forcedStates = const {},
  });

  /// The chosen value as text; empty when none.
  final String text;

  /// Reads typed text; returns whether it could.
  final bool Function(String typed) onCommit;

  /// The calendar in the popup.
  final DatePickerPopupBuilder calendar;

  /// The presets before the calendar.
  final DatePickerPopupBuilder? presets;

  /// Graphite text while empty.
  final String placeholder;

  /// A field to type in; false makes the whole field one button.
  final bool typeable;

  final bool disabled;

  /// Shows the value; no typing, no popup.
  final bool readOnly;

  /// Red pencil, on top of an unreadable typed date.
  final bool invalid;

  /// Opens the popup from outside; null leaves it to the field.
  final bool? open;

  final ValueChanged<bool>? onOpenChange;

  /// The calendar button's and the popup's accessible name.
  final String calendarLabel;

  /// What screen readers hear while the typed date cannot be read.
  final String invalidMessage;

  /// Pins the hand.
  final String? seed;

  /// The field's accessible name.
  final String? semanticLabel;

  final bool autofocus;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<DatePickerShell> createState() => _DatePickerShellState();
}

class _DatePickerShellState extends State<DatePickerShell> with InkSeed {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final Object _tapGroup = Object();
  late final TextEditingController _text = TextEditingController(
    text: widget.text,
  );
  final FocusNode _input = FocusNode(debugLabel: 'date picker input');
  final FocusNode _button = FocusNode(debugLabel: 'date picker button');
  bool _innerOpen = false;
  bool _drafting = false;
  bool _bad = false;
  bool _hovered = false;

  bool get _open => widget.open ?? _innerOpen;
  bool get _inert => widget.disabled || widget.readOnly;

  @override
  void initState() {
    super.initState();
    _input.addListener(_onInputFocus);
    _button.addListener(_onFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  void didUpdateWidget(DatePickerShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text == widget.text) return;
    _drafting = false;
    _bad = false;
    _text.text = widget.text;
  }

  void _onFocus() => setState(() {});

  void _onInputFocus() {
    if (!_input.hasFocus) _commit();
    setState(() {});
  }

  @override
  void dispose() {
    _input
      ..removeListener(_onInputFocus)
      ..dispose();
    _button
      ..removeListener(_onFocus)
      ..dispose();
    _text.dispose();
    super.dispose();
  }

  void _setOpen(bool next) {
    if (next && _inert) return;
    if (next == _open) return;
    if (widget.open == null) setState(() => _innerOpen = next);
    widget.onOpenChange?.call(next);
  }

  void _close() {
    _setOpen(false);
    _button.requestFocus();
  }

  bool _commit() {
    if (!_drafting) return true;
    if (_text.text == widget.text) {
      setState(() => _drafting = false);
      return true;
    }
    final ok = widget.onCommit(_text.text);
    setState(() {
      _bad = !ok;
      if (ok) _drafting = false;
    });
    return ok;
  }

  KeyEventResult _onKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape && _open) {
      _close();
      return KeyEventResult.handled;
    }
    if (_input.hasFocus &&
        (key == LogicalKeyboardKey.enter ||
            key == LogicalKeyboardKey.numpadEnter)) {
      _commit();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown && !_inert) {
      _setOpen(true);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape && _drafting && !_open) {
      setState(() {
        _drafting = false;
        _bad = false;
      });
      _text.text = widget.text;
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _onPopupKey(KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.escape) {
      return KeyEventResult.ignored;
    }
    _close();
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final shell = widget;
    final invalid = (shell.invalid || _bad) && !shell.disabled;
    final params = SelectParams(disabled: shell.disabled, invalid: invalid);
    final enabled = !shell.disabled;
    final focused = _input.hasFocus || _button.hasFocus;
    final states = {
      ...shell.forcedStates,
      if (!enabled) InkState.disabled,
      if (invalid) InkState.invalid,
      if (_open) InkState.open,
      if (enabled && _hovered) InkState.hovered,
      if (enabled && focused) InkState.focused,
    };
    final source = RecipeInkSource(
      datePickerRecipe,
      params,
      json: params.toJson(),
    );
    final field = switch (shell.typeable) {
      true => _typed(theme, source, states, invalid: invalid),
      false => _buttonField(theme, source, states, invalid: invalid),
    };
    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: _popup,
      child: CompositedTransformTarget(
        link: _link,
        child: TapRegion(groupId: _tapGroup, child: field),
      ),
    );
  }

  Widget _typed(
    LooseleafThemeData theme,
    InkSource source,
    Set<InkState> states, {
    required bool invalid,
  }) {
    final shell = widget;
    final calm = theme.density == LooseleafDensity.calm;
    final cell = switch (calm) {
      true => Spacing.d24,
      false => Spacing.d28,
    };
    return Semantics(
      hint: switch (_bad) {
        true => shell.invalidMessage,
        false => null,
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: DefaultTextStyle.merge(
          style: InputMetrics.text(theme, disabled: shell.disabled),
          child: InkSurface(
            source: source,
            seed: inkSeed(shell.seed),
            states: states,
            still: true,
            child: SizedBox(
              height: InputMetrics.height.resolve(theme.density),
              child: Focus(
                canRequestFocus: false,
                skipTraversal: true,
                onKeyEvent: (_, event) => _onKey(event),
                child: Row(
                  children: [
                    Expanded(
                      child: InputControl(
                        controller: _text,
                        focusNode: _input,
                        placeholder: shell.placeholder,
                        disabled: shell.disabled,
                        readOnly: shell.readOnly,
                        autofocus: shell.autofocus,
                        semanticLabel: shell.semanticLabel,
                        padding: EdgeInsetsDirectional.only(
                          start: Spacing.d12,
                          end: switch (invalid) {
                            true => InputMetrics.invalidEnd,
                            false => Spacing.d4,
                          },
                        ),
                        onChanged: (_) => setState(() {
                          _drafting = true;
                          _bad = false;
                        }),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: Spacing.d2,
                      ),
                      child: SizedBox.square(
                        dimension: cell,
                        child: InkTriggerSemantics(
                          expanded: _open,
                          child: Button(
                            variant: ButtonVariant.ghost,
                            size: ButtonSize.iconSm,
                            disabled: _inert,
                            focusNode: _button,
                            semanticLabel: shell.calendarLabel,
                            onPressed: () => _setOpen(!_open),
                            child: const InkIcon('calendar', size: Spacing.d16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buttonField(
    LooseleafThemeData theme,
    InkSource source,
    Set<InkState> states, {
    required bool invalid,
  }) {
    final shell = widget;
    final empty = shell.text.isEmpty;
    final colors = theme.colors;
    return Semantics(
      container: true,
      button: true,
      expanded: _open,
      enabled: !_inert,
      label: shell.semanticLabel,
      child: InkInteraction(
        enabled: !_inert,
        onActivate: () => _setOpen(!_open),
        states: states,
        focusNode: _button,
        autofocus: shell.autofocus,
        mouseCursor: SystemMouseCursors.basic,
        disabledMouseCursor: SystemMouseCursors.forbidden,
        builder: (context, interactive) => InkContent(
          style: InputMetrics.text(theme, disabled: _inert).copyWith(
            color: switch ((_inert, empty)) {
              (true, _) => colors.pencilText,
              (false, true) => colors.placeholder,
              (false, false) => colors.inputInk,
            },
          ),
          wrap: false,
          child: InkSurface(
            source: source,
            seed: inkSeed(shell.seed),
            states: interactive,
            still: true,
            child: SizedBox(
              height: InputMetrics.height.resolve(theme.density),
              child: Padding(
                padding: const EdgeInsetsDirectional.only(start: Spacing.d12),
                child: Row(
                  spacing: Spacing.d8,
                  children: [
                    Expanded(
                      child: Text(
                        switch (empty) {
                          true => shell.placeholder,
                          false => shell.text,
                        },
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: Spacing.d32,
                      child: Center(
                        child: InkIcon(
                          'calendar',
                          size: Spacing.d16,
                          color: colors.inkSoft,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _popup(BuildContext context) {
    if (!_open) return const SizedBox.shrink();
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final presets = widget.presets;
    final wide = MediaQuery.sizeOf(context).width >= 640;
    final parts = [
      if (presets != null) presets(context, _close),
      widget.calendar(context, _close),
    ];
    return Align(
      alignment: AlignmentDirectional.topStart,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: switch (rtl) {
          true => Alignment.bottomRight,
          false => Alignment.bottomLeft,
        },
        followerAnchor: switch (rtl) {
          true => Alignment.topRight,
          false => Alignment.topLeft,
        },
        offset: const Offset(0, Spacing.d8),
        child: TapRegion(
          groupId: _tapGroup,
          onTapOutside: (_) => _setOpen(false),
          child: Focus(
            canRequestFocus: false,
            skipTraversal: true,
            onKeyEvent: (_, event) => _onPopupKey(event),
            child: Semantics(
              container: true,
              explicitChildNodes: true,
              scopesRoute: true,
              namesRoute: true,
              label: widget.calendarLabel,
              child: PaperPopup(
                seed: '${inkSeed(widget.seed)}|popup',
                tilt: false,
                child: switch (wide) {
                  true => IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: parts,
                    ),
                  ),
                  false => IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: parts,
                    ),
                  ),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
