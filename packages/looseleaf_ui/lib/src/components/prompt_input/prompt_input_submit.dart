import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/components/prompt_input/prompt_input.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

/// The send button: a marker-filled square with a paper plane that flies
/// off when a message goes; pencilled in until there is something to send.
/// While a request is busy it is an outline stop button; when the request
/// ends with focus on it, focus goes back to the textarea.
///
/// Mirrors `PromptInputSubmit` in upstream
/// `src/components/ui/prompt-input.tsx`.
class PromptInputSubmit extends StatefulWidget {
  const PromptInputSubmit({
    super.key,
    this.child,
    this.onPressed,
    this.seed,
    this.forcedStates = const {},
  });

  /// Replaces the plane or stop icon.
  final Widget? child;

  /// Called before sending or stopping.
  final VoidCallback? onPressed;

  /// Pins the button's hand.
  final String? seed;

  /// States shown whatever the input, for goldens.
  final Set<InkState> forcedStates;

  @override
  State<PromptInputSubmit> createState() => _PromptInputSubmitState();
}

class _PromptInputSubmitState extends State<PromptInputSubmit> {
  final FocusNode _focus = FocusNode(debugLabel: 'PromptInputSubmit');
  bool? _wasStopping;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = PromptInputModel.of(context);
    final stopping = model.busy;
    if (_wasStopping == true && !stopping && _focus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) => model.focus());
    }
    _wasStopping = stopping;
    return Button(
      size: ButtonSize.icon,
      variant: switch (stopping) {
        true => ButtonVariant.outline,
        false => ButtonVariant.primary,
      },
      semanticLabel: switch (stopping) {
        true => 'Stop generating',
        false => 'Send message',
      },
      disabled: !stopping && (model.disabled || model.empty),
      seed: widget.seed,
      focusNode: _focus,
      forcedStates: widget.forcedStates,
      onPressed: () {
        widget.onPressed?.call();
        if (stopping) {
          model.stop();
          return;
        }
        model.submit();
      },
      child:
          widget.child ??
          PromptInputPlane(
            flight: model.flight,
            child: InkIcon(
              switch (stopping) {
                true => 'square',
                false => 'send',
              },
              size: Spacing.d18,
            ),
          ),
    );
  }
}
