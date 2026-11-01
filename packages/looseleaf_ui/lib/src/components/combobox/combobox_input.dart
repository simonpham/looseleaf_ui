import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_anchor.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_clear.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_controller.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_metrics.dart';
import 'package:looseleaf_ui/src/components/combobox/combobox_scope.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The combobox's text input. Inside [ComboboxContent] it is the popup's
/// search box: a magnifier and a ruled line, focused when the popup opens.
/// On its own it is the field: a select-like pencil box you type in, with
/// an optional [showClear] x and an up-down button ([showTrigger]); the
/// arrows open the list, Enter chooses, Escape closes.
///
/// Mirrors `ComboboxInput` in upstream `src/components/ui/combobox.tsx`.
class ComboboxInput extends StatelessWidget {
  const ComboboxInput({
    super.key,
    this.placeholder,
    this.showTrigger = true,
    this.showClear = false,
    this.seed,
    this.autofocus = false,
    this.semanticLabel,
    this.forcedStates = const {},
  });

  /// Graphite text while empty.
  final String? placeholder;

  /// The field's up-down button.
  final bool showTrigger;

  /// The field's clear x, while something is chosen.
  final bool showClear;

  /// Pins the hand.
  final String? seed;

  /// Focuses the field on mount; the search box always takes focus.
  final bool autofocus;

  /// The accessible name.
  final String? semanticLabel;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  Widget build(BuildContext context) {
    if (ComboboxScope.of(context).inContent) {
      return _Search(
        placeholder: placeholder,
        seed: seed,
        semanticLabel: semanticLabel,
      );
    }
    return _Field(config: this);
  }
}

KeyEventResult Function(FocusNode, KeyEvent) _keys(
  ComboboxController controller,
) =>
    (_, event) => controller.handleKey(event);

class _Search extends StatefulWidget {
  const _Search({this.placeholder, this.seed, this.semanticLabel});

  final String? placeholder;
  final String? seed;
  final String? semanticLabel;

  @override
  State<_Search> createState() => _SearchState();
}

class _SearchState extends State<_Search> with InkSeed {
  ComboboxController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ComboboxScope.of(context).controller;
    if (identical(controller, _controller)) return;
    _controller?.inputFocus.removeListener(_onFocus);
    _controller = controller;
    controller.inputFocus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _controller?.inputFocus.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    const params = NoParams();
    return InkSurface(
      source: RecipeInkSource(
        commandInputRecipe,
        params,
        json: params.toJson(),
      ),
      seed: inkSeed(widget.seed),
      states: {if (controller.inputFocus.hasFocus) InkState.focused},
      still: true,
      child: SizedBox(
        height: ComboboxMetrics.searchHeight.resolve(theme.density),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.d12),
          child: Row(
            spacing: Spacing.d8,
            children: [
              InkIcon('search', size: Spacing.d18, color: theme.colors.inkSoft),
              Expanded(
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: _keys(controller),
                  child: DefaultTextStyle.merge(
                    style: ComboboxMetrics.text(
                      theme,
                      color: theme.colors.inputInk,
                    ),
                    child: InputControl(
                      controller: controller.text,
                      focusNode: controller.inputFocus,
                      placeholder: widget.placeholder,
                      autofocus: true,
                      semanticLabel: widget.semanticLabel,
                      padding: EdgeInsets.zero,
                      onChanged: controller.type,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatefulWidget {
  const _Field({required this.config});

  final ComboboxInput config;

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> with InkSeed {
  ComboboxController? _controller;
  bool _hovered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = ComboboxScope.of(context).controller;
    if (identical(controller, _controller)) return;
    _controller?.inputFocus.removeListener(_onFocus);
    _controller = controller
      ..fieldMode = ComboboxFieldMode.single
      ..valueChanged();
    controller.inputFocus.addListener(_onFocus);
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _controller
      ?..inputFocus.removeListener(_onFocus)
      ..fieldMode = ComboboxFieldMode.none;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final controller = ComboboxScope.of(context).controller;
    final theme = LooseleafTheme.of(context);
    final disabled = controller.disabled;
    final invalid = controller.invalid && !disabled;
    final params = SelectParams(disabled: disabled, invalid: invalid);
    final enabled = !disabled;
    return Semantics(
      expanded: controller.open,
      child: ComboboxAnchor(
        controller: controller,
        child: MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: DefaultTextStyle.merge(
            style: ComboboxMetrics.text(
              theme,
              color: switch (disabled) {
                true => theme.colors.pencilText,
                false => theme.colors.inputInk,
              },
            ),
            child: InkSurface(
              source: RecipeInkSource(
                comboboxTriggerRecipe,
                params,
                json: params.toJson(),
              ),
              seed: inkSeed(config.seed),
              states: {
                ...config.forcedStates,
                if (!enabled) InkState.disabled,
                if (invalid) InkState.invalid,
                if (controller.open) InkState.open,
                if (enabled && _hovered) InkState.hovered,
                if (enabled && controller.inputFocus.hasFocus) InkState.focused,
              },
              still: true,
              child: SizedBox(
                height: ComboboxMetrics.height.resolve(theme.density),
                child: Row(
                  children: [
                    Expanded(
                      child: Focus(
                        canRequestFocus: false,
                        skipTraversal: true,
                        onKeyEvent: _keys(controller),
                        child: InputControl(
                          controller: controller.text,
                          focusNode: controller.inputFocus,
                          placeholder: config.placeholder,
                          disabled: disabled,
                          readOnly: controller.readOnly,
                          autofocus: config.autofocus,
                          semanticLabel: config.semanticLabel,
                          padding: EdgeInsetsDirectional.only(
                            start: Spacing.d12,
                            end: switch (config.showClear) {
                              true => Spacing.d4,
                              false => Spacing.d12,
                            },
                          ),
                          onChanged: controller.type,
                        ),
                      ),
                    ),
                    if (config.showClear)
                      const Padding(
                        padding: EdgeInsetsDirectional.only(end: Spacing.d2),
                        child: ComboboxClear(),
                      ),
                    if (config.showTrigger) _toggle(controller, theme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(ComboboxController controller, LooseleafThemeData theme) {
    final off = controller.disabled || controller.readOnly;
    return Semantics(
      button: true,
      label: 'Toggle options',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: off,
        onTap: switch (off) {
          true => null,
          false => () {
            controller.setOpen(!controller.open);
            controller.inputFocus.requestFocus();
          },
        },
        child: Padding(
          padding: const EdgeInsetsDirectional.only(end: Spacing.d2),
          child: SizedBox.square(
            dimension: Spacing.d28,
            child: Center(
              child: InkIcon(
                'chevrons-up-down',
                size: Spacing.d16,
                color: switch (off) {
                  true => theme.colors.pencilText,
                  false => theme.colors.inkSoft,
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
