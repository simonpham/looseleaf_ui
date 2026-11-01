import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';

/// Switches between drawing and typing the signature: "Type instead" or
/// "Draw instead", pressed while typing.
///
/// Mirrors `SignaturePadModeToggle` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignaturePadModeToggle extends StatelessWidget {
  const SignaturePadModeToggle({
    super.key,
    this.child,
    this.onPressed,
    this.seed,
  });

  /// The label; "Type instead" or "Draw instead" when null.
  final Widget? child;

  /// Called before switching.
  final VoidCallback? onPressed;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = SignaturePadScope.of(context);
    final typing = scope.mode == SignatureMode.type;
    return Semantics(
      toggled: typing,
      child: Button(
        variant: ButtonVariant.link,
        size: ButtonSize.sm,
        disabled: scope.disabled || scope.readOnly,
        seed: seed,
        onPressed: () {
          onPressed?.call();
          scope.onModeChanged(switch (typing) {
            true => SignatureMode.draw,
            false => SignatureMode.type,
          });
        },
        child:
            child ??
            Text(switch (typing) {
              true => 'Draw instead',
              false => 'Type instead',
            }),
      ),
    );
  }
}
