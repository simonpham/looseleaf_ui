import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/code_block/code_block.dart';
import 'package:looseleaf_ui/src/components/icon/icon.dart';
import 'package:looseleaf_ui/src/surface/surface.dart';
import 'package:looseleaf_ui/src/theme/theme.dart';

enum _CopyState { idle, copied, failed }

/// The copy button of a [CodeBlockHeader]: a small ghost button typed
/// `copy` that puts the code (a diff's result) on the clipboard, then turns
/// into a tick and `copied` for 1.8 s, or `press Ctrl+C` when the clipboard
/// refuses. A polite live region says "Copied" or "Could not copy".
///
/// Mirrors `CodeBlockCopy` in upstream `src/components/ui/code-block.tsx`.
class CodeBlockCopy extends StatefulWidget {
  const CodeBlockCopy({
    super.key,
    this.child,
    this.onCopied,
    this.seed,
    this.focusNode,
    this.forcedStates = const {},
  });

  /// Replaces the icon and the word.
  final Widget? child;

  /// Called after each copy with whether the clipboard took the text.
  final ValueChanged<bool>? onCopied;

  /// Pins the button's hand.
  final String? seed;

  final FocusNode? focusNode;

  /// States shown whatever the input, for state grids and goldens.
  final Set<InkState> forcedStates;

  /// How long the tick stays.
  static const Duration settle = Duration(milliseconds: 1800);

  @override
  State<CodeBlockCopy> createState() => _CodeBlockCopyState();
}

class _CodeBlockCopyState extends State<CodeBlockCopy> {
  _CopyState _state = _CopyState.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _copy(String text) async {
    final copied = await Clipboard.setData(
      ClipboardData(text: text),
    ).then((_) => true, onError: (Object _) => false);
    if (!mounted) return;
    widget.onCopied?.call(copied);
    _timer?.cancel();
    _timer = Timer(CodeBlockCopy.settle, () {
      if (mounted) setState(() => _state = _CopyState.idle);
    });
    setState(() {
      _state = switch (copied) {
        true => _CopyState.copied,
        false => _CopyState.failed,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = LooseleafTheme.of(context);
    final scope = CodeBlockScope.of(context);
    final muted = theme.colors.inkMuted;
    final word = switch (_state) {
      _CopyState.idle => 'copy',
      _CopyState.copied => 'copied',
      _CopyState.failed => 'press Ctrl+C',
    };
    final status = switch (_state) {
      _CopyState.idle => '',
      _CopyState.copied => 'Copied',
      _CopyState.failed => 'Could not copy',
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(
          variant: ButtonVariant.ghost,
          size: ButtonSize.xs,
          seed: widget.seed ?? '${scope.seed}|copy',
          focusNode: widget.focusNode,
          forcedStates: widget.forcedStates,
          semanticLabel: 'Copy code',
          onPressed: () => unawaited(_copy(scope.model.text)),
          leading: switch (widget.child) {
            null => InkIcon(
              switch (_state) {
                _CopyState.copied => 'check',
                _ => 'copy',
              },
              color: muted,
            ),
            _ => null,
          },
          child: ExcludeSemantics(
            child:
                widget.child ??
                Text(
                  word,
                  style: theme.typography
                      .face(
                        KevinSansFace.type,
                        cssSize: 14,
                        cssLineHeight: 20 / 14,
                        color: muted,
                      )
                      .copyWith(letterSpacing: 14 * 0.025),
                ),
          ),
        ),
        Semantics(
          container: true,
          liveRegion: true,
          label: status,
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }
}
