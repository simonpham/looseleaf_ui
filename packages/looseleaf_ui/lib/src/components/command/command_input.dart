import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/command/command.dart';
import 'package:looseleaf_ui/src/components/foundation/foundation.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/frame/frame.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The palette's search box: a magnifier and blue-felt text over an inked
/// rule that turns into a blue brush line while focused. Typing filters
/// the list; the arrows, Home, End and Enter drive it. After each change a
/// polite status tells screen readers how many rows match
/// ([resultsLabel]).
///
/// The search is the command's own, or yours with [value] and
/// [onValueChange].
///
/// Mirrors `CommandInput` in upstream `src/components/ui/command.tsx`.
class CommandInput extends StatefulWidget {
  const CommandInput({
    super.key,
    this.placeholder,
    this.value,
    this.onValueChange,
    this.disabled = false,
    this.autofocus = true,
    this.seed,
    this.semanticLabel,
    this.resultsLabel = defaultResultsLabel,
  });

  /// "No results", "1 result", "3 results".
  static String defaultResultsLabel(int count) => switch (count) {
    0 => 'No results',
    1 => '1 result',
    _ => '$count results',
  };

  /// Graphite text while empty.
  final String? placeholder;

  /// The search; the command keeps its own when null.
  final String? value;

  /// Called as the search changes.
  final ValueChanged<String>? onValueChange;

  /// Graphite and not editable.
  final bool disabled;

  /// Takes focus on mount.
  final bool autofocus;

  /// Pins the rule.
  final String? seed;

  /// The accessible name.
  final String? semanticLabel;

  /// What the status says for a count of matching rows.
  final String Function(int count) resultsLabel;

  @override
  State<CommandInput> createState() => _CommandInputState();
}

class _CommandInputState extends State<CommandInput> with InkSeed {
  CommandController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = CommandScope.of(context);
    if (identical(controller, _controller)) return;
    _controller?.inputFocus.removeListener(_onFocus);
    _controller = controller;
    controller.inputFocus.addListener(_onFocus);
    _syncValue(controller);
  }

  @override
  void didUpdateWidget(CommandInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller case final controller?) _syncValue(controller);
  }

  void _syncValue(CommandController controller) {
    final value = widget.value;
    if (value == null || value == controller.text.text) return;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || value == controller.text.text) return;
      controller.text.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    });
  }

  void _onFocus() => setState(() {});

  @override
  void dispose() {
    _controller?.inputFocus.removeListener(_onFocus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = CommandScope.of(context);
    final theme = LooseleafTheme.of(context);
    const params = NoParams();
    final search = controller.search;
    return InkSurface(
      source: RecipeInkSource(
        commandInputRecipe,
        params,
        json: params.toJson(),
      ),
      seed: inkSeed(widget.seed),
      states: {
        if (controller.inputFocus.hasFocus && !widget.disabled)
          InkState.focused,
        if (widget.disabled) InkState.disabled,
      },
      still: true,
      child: SizedBox(
        height: CommandMetrics.inputHeight.of(context),
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
                  onKeyEvent: (_, event) => controller.handleKey(event),
                  child: DefaultTextStyle.merge(
                    style: CommandMetrics.text(
                      theme,
                      color: switch (widget.disabled) {
                        true => theme.colors.pencilText,
                        false => theme.colors.inputInk,
                      },
                    ),
                    child: InputControl(
                      controller: controller.text,
                      focusNode: controller.inputFocus,
                      placeholder: widget.placeholder,
                      disabled: widget.disabled,
                      autofocus: widget.autofocus,
                      semanticLabel: widget.semanticLabel,
                      padding: EdgeInsets.zero,
                      onChanged: widget.onValueChange,
                    ),
                  ),
                ),
              ),
              Semantics(
                liveRegion: true,
                label: switch (search.isEmpty) {
                  true => '',
                  false => widget.resultsLabel(controller.count),
                },
                child: const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
