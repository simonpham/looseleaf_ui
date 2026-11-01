import 'package:flutter/widgets.dart';
import 'package:looseleaf_ink/looseleaf_ink.dart';
import 'package:looseleaf_ui/src/components/button/button.dart';
import 'package:looseleaf_ui/src/components/signature_pad/signature_pad.dart';

/// Empties the signature in the current mode; when typing, focus returns
/// to the name field.
///
/// Mirrors `SignaturePadClear` in upstream
/// `src/components/ui/signature-pad.tsx`.
class SignaturePadClear extends StatelessWidget {
  const SignaturePadClear({super.key, this.child, this.onPressed, this.seed});

  /// The label; "Clear" when null.
  final Widget? child;

  /// Called before clearing.
  final VoidCallback? onPressed;
  final String? seed;

  @override
  Widget build(BuildContext context) {
    final scope = SignaturePadScope.of(context);
    final typing = scope.mode == SignatureMode.type;
    final hasSignature = switch (typing) {
      true => scope.typed.isNotEmpty,
      false => scope.strokes.isNotEmpty,
    };
    return Button(
      variant: ButtonVariant.ghost,
      size: ButtonSize.sm,
      disabled: scope.disabled || scope.readOnly || !hasSignature,
      seed: seed,
      onPressed: () {
        onPressed?.call();
        scope.clear();
        if (typing) scope.typedFocusNode.requestFocus();
      },
      child: child ?? const Text('Clear'),
    );
  }
}
