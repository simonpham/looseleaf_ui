import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ui/src/components/input/input.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The handwriting: blue script on the line, growing from [minRows] to
/// [maxRows] rows, then scrolling. Enter sends, Shift+Enter breaks the line
/// (Ctrl/Cmd+Enter sends with [PromptInputSubmitOn.modEnter]); while
/// suggestions are open, arrows move, Enter or Tab picks, Escape closes.
/// Keys typed while composing (an IME) are left alone.
///
/// Mirrors `PromptInputTextarea` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputTextarea extends StatelessWidget {
  const PromptInputTextarea({
    super.key,
    this.placeholder = 'what are we making?',
    this.minRows = 1,
    this.maxRows = 8,
    this.autofocus = false,
    this.semanticLabel = 'Message',
  });

  /// Graphite text shown while empty.
  final String placeholder;

  final int minRows;
  final int maxRows;
  final bool autofocus;

  /// The accessible name.
  final String semanticLabel;

  KeyEventResult _onKey(PromptInputModel model, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    if (model.controller.value.composing.isValid) {
      return KeyEventResult.ignored;
    }
    final keyboard = HardwareKeyboard.instance;
    final key = event.logicalKey;
    final enter =
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter;
    if (model.optionsOpen) {
      if (key == LogicalKeyboardKey.arrowDown) return _handled(model.move(1));
      if (key == LogicalKeyboardKey.arrowUp) return _handled(model.move(-1));
      if (key == LogicalKeyboardKey.escape) {
        return _handled(model.dismissTrigger());
      }
      final pick =
          (enter && !keyboard.isShiftPressed) || key == LogicalKeyboardKey.tab;
      if (pick && model.pickActive()) return KeyEventResult.handled;
    }
    if (!enter || keyboard.isShiftPressed) return KeyEventResult.ignored;
    final mod = keyboard.isControlPressed || keyboard.isMetaPressed;
    final sends = switch (model.submitOn) {
      PromptInputSubmitOn.enter => !mod && !keyboard.isAltPressed,
      PromptInputSubmitOn.modEnter => mod,
    };
    if (!sends) return KeyEventResult.ignored;
    if (event is! KeyRepeatEvent) model.submit();
    return KeyEventResult.handled;
  }

  static KeyEventResult _handled(void _) => KeyEventResult.handled;

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    final theme = LooseleafTheme.of(context);
    final (size, line) = switch (theme.density) {
      LooseleafDensity.comfortable => (26.4, Spacing.d32),
      LooseleafDensity.compact => (24.0, Spacing.d32),
      LooseleafDensity.calm => (21.6, Spacing.d28),
    };
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      onKeyEvent: (node, event) => _onKey(model, event),
      child: DefaultTextStyle.merge(
        style: theme.typography.face(
          KevinSansFace.script,
          cssSize: size,
          cssLineHeight: line / size,
          color: theme.colors.inkYou,
        ),
        child: InputControl(
          controller: model.controller,
          focusNode: model.focusNode,
          placeholder: placeholder,
          disabled: model.disabled,
          readOnly: model.lockWhileStreaming && model.busy,
          autofocus: autofocus,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: minRows,
          maxLines: maxRows,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.d4,
            vertical: Spacing.d6,
          ),
          alignment: AlignmentDirectional.topStart,
          semanticLabel: semanticLabel,
        ),
      ),
    );
  }
}
